BEGIN;

CREATE FUNCTION studyu_private.nutrition_availability_is_valid(
    p_nutrition jsonb
)
RETURNS boolean LANGUAGE plpgsql IMMUTABLE SET search_path = ''
AS $$
DECLARE
  v_key text;
BEGIN
  FOREACH v_key IN ARRAY ARRAY['unavailableNutrients', 'partialNutrients'] LOOP
    IF p_nutrition ? v_key THEN
      IF jsonb_typeof(p_nutrition->v_key) IS DISTINCT FROM 'array' THEN
        RETURN false;
      END IF;
      IF EXISTS (SELECT 1 FROM jsonb_array_elements(p_nutrition->v_key) AS item
                 WHERE jsonb_typeof(item) IS DISTINCT FROM 'string') THEN
        RETURN false;
      END IF;
    END IF;
  END LOOP;
  RETURN true;
END;
$$;

CREATE FUNCTION studyu_private.nutrition_snapshot_foods(p_food jsonb)
RETURNS SETOF jsonb LANGUAGE sql IMMUTABLE SET search_path = ''
AS $$
  WITH RECURSIVE foods(food) AS (
    SELECT p_food
    UNION ALL
    SELECT component
    FROM foods, LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(food->'componentSnapshots') = 'array'
        THEN food->'componentSnapshots' ELSE '[]'::jsonb END
    ) AS component
  ) SELECT food FROM foods;
$$;

CREATE FUNCTION studyu_private.nutrition_recall_foods(p_result jsonb)
RETURNS SETOF jsonb LANGUAGE sql IMMUTABLE SET search_path = ''
AS $$
  SELECT food
  FROM jsonb_array_elements(
    CASE WHEN jsonb_typeof(p_result #> '{result,meals}') = 'array'
      THEN p_result #> '{result,meals}' ELSE '[]'::jsonb END
  ) AS meal,
  LATERAL jsonb_array_elements(
    CASE WHEN jsonb_typeof(meal->'foods') = 'array'
      THEN meal->'foods' ELSE '[]'::jsonb END
  ) AS food;
$$;

CREATE FUNCTION studyu_private.nutrition_assert_snapshot_owner(
    p_subject_id uuid, p_food jsonb, p_mutating_food_id uuid DEFAULT null
) RETURNS void LANGUAGE plpgsql SET search_path = ''
AS $$
DECLARE
  v_food jsonb;
  v_food_id uuid;
  v_version_id uuid;
  v_version record;
BEGIN
  FOR v_food IN SELECT * FROM studyu_private.nutrition_snapshot_foods(p_food) LOOP
    v_food_id := (v_food->>'foodId')::uuid;
    v_version_id := (v_food->>'foodVersionId')::uuid;
    IF p_mutating_food_id IS NOT NULL AND v_food_id = p_mutating_food_id
       AND v_food = p_food THEN CONTINUE; END IF;

    SELECT version.food_id, definition.subject_id INTO v_version
    FROM public.nutrition_food_version AS version
    JOIN public.nutrition_food_definition AS definition ON definition.id = version.food_id
    WHERE version.id = v_version_id;
    IF FOUND THEN
      IF v_version.subject_id IS DISTINCT FROM p_subject_id THEN
        RAISE EXCEPTION 'nutrition definition subject is not owned by caller' USING ERRCODE = '42501';
      END IF;
      IF v_version.food_id IS DISTINCT FROM v_food_id THEN
        RAISE EXCEPTION 'nutrition food version does not match food' USING ERRCODE = '22023';
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM public.nutrition_food_definition
      WHERE id = v_food_id AND subject_id IS DISTINCT FROM p_subject_id
    ) THEN
      RAISE EXCEPTION 'nutrition definition subject is not owned by caller' USING ERRCODE = '42501';
    END IF;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION public.nutrition_food_snapshot_is_valid(
    p_snapshot jsonb
) RETURNS boolean
LANGUAGE plpgsql
STABLE
SET search_path = ''
AS $$
DECLARE
  v_key text;
  v_component jsonb;
  v_component_snapshot jsonb;
BEGIN
  IF NOT studyu_private.nutrition_availability_is_valid(p_snapshot->'nutrition') THEN
    RETURN false;
  END IF;
  IF jsonb_typeof(p_snapshot) IS DISTINCT FROM 'object' THEN RETURN false; END IF;

  FOREACH v_key IN ARRAY ARRAY[
    'id', 'foodId', 'foodVersionId', 'name', 'unit', 'createdAt'
  ] LOOP
    IF jsonb_typeof(p_snapshot->v_key) IS DISTINCT FROM 'string'
       OR NULLIF(p_snapshot->>v_key, '') IS NULL THEN
      RETURN false;
    END IF;
  END LOOP;
  IF (p_snapshot->>'foodId') !~* '^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$'
     OR (p_snapshot->>'foodVersionId') !~* '^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$' THEN
    RETURN false;
  END IF;
  FOREACH v_key IN ARRAY ARRAY[
    'entryType', 'portionEstimationMethod', 'portionState', 'source'
  ] LOOP
    IF jsonb_typeof(p_snapshot->v_key) IS DISTINCT FROM 'string' THEN RETURN false; END IF;
  END LOOP;
  IF p_snapshot->>'entryType' NOT IN (
      'singleIngredient', 'meal', 'brandedProduct', 'manualCustom'
    ) OR p_snapshot->>'portionEstimationMethod' NOT IN (
      'householdMeasure', 'photograph', 'standardUnit', 'userWeighted', 'unknown'
    ) OR p_snapshot->>'portionState' NOT IN ('raw', 'cooked', 'asServed')
    OR p_snapshot->>'source' NOT IN ('openfoodfacts', 'usda', 'mealdb', 'manual') THEN
    RETURN false;
  END IF;
  FOREACH v_key IN ARRAY ARRAY[
    'amount', 'servingSizeGrams', 'confidenceScore'
  ] LOOP
    IF jsonb_typeof(p_snapshot->v_key) IS DISTINCT FROM 'number' THEN RETURN false; END IF;
  END LOOP;
  IF (p_snapshot->>'amount')::numeric <= 0
     OR (p_snapshot->>'servingSizeGrams')::numeric < 0
     OR (p_snapshot->>'confidenceScore')::numeric NOT BETWEEN 0 AND 1 THEN
    RETURN false;
  END IF;
  IF jsonb_typeof(p_snapshot->'originalValues') IS DISTINCT FROM 'object' THEN
    RETURN false;
  END IF;

  FOREACH v_key IN ARRAY ARRAY[
    'brandName', 'description', 'portionReference', 'foodCode', 'externalId',
    'templateId', 'parentEntryId'
  ] LOOP
    IF p_snapshot ? v_key AND jsonb_typeof(p_snapshot->v_key) NOT IN ('string', 'null') THEN
      RETURN false;
    END IF;
  END LOOP;
  FOREACH v_key IN ARRAY ARRAY['yieldFactor', 'ediblePortion'] LOOP
    IF p_snapshot ? v_key AND jsonb_typeof(p_snapshot->v_key) NOT IN ('number', 'null') THEN
      RETURN false;
    END IF;
  END LOOP;

  BEGIN
    IF p_snapshot->>'createdAt' !~
       '^[0-9]{4}-[0-9]{2}-[0-9]{2}[Tt ][0-9]{2}:[0-9]{2}:[0-9]{2}([.][0-9]{1,6})?([Zz]|[+-][0-9]{2}:?[0-9]{2})?$' THEN
      RETURN false;
    END IF;
    PERFORM (p_snapshot->>'createdAt')::timestamptz;
    IF p_snapshot ? 'modifiedAt' AND jsonb_typeof(p_snapshot->'modifiedAt') <> 'null' THEN
      IF jsonb_typeof(p_snapshot->'modifiedAt') IS DISTINCT FROM 'string'
         OR p_snapshot->>'modifiedAt' !~
            '^[0-9]{4}-[0-9]{2}-[0-9]{2}[Tt ][0-9]{2}:[0-9]{2}:[0-9]{2}([.][0-9]{1,6})?([Zz]|[+-][0-9]{2}:?[0-9]{2})?$' THEN
        RETURN false;
      END IF;
      PERFORM (p_snapshot->>'modifiedAt')::timestamptz;
    END IF;
  EXCEPTION WHEN others THEN
    RETURN false;
  END;

  IF jsonb_typeof(p_snapshot->'nutrition') IS DISTINCT FROM 'object' THEN RETURN false; END IF;
  FOREACH v_key IN ARRAY ARRAY[
    'energyKcal', 'protein', 'carbs', 'fat', 'sugars', 'fiber',
    'saturatedFat', 'transFat', 'cholesterol', 'sodium', 'waterContent'
  ] LOOP
    IF jsonb_typeof(p_snapshot->'nutrition'->v_key) IS DISTINCT FROM 'number' THEN
      RETURN false;
    END IF;
  END LOOP;
  IF jsonb_typeof(p_snapshot #> '{nutrition,micros}') IS DISTINCT FROM 'object' THEN
    RETURN false;
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_each(p_snapshot #> '{nutrition,micros}')
    WHERE jsonb_typeof(value) <> 'number'
  ) THEN
    RETURN false;
  END IF;

  IF p_snapshot ? 'preparationDetails'
     AND jsonb_typeof(p_snapshot->'preparationDetails') <> 'null' THEN
    IF jsonb_typeof(p_snapshot->'preparationDetails') IS DISTINCT FROM 'object' THEN
      RETURN false;
    END IF;
    FOREACH v_key IN ARRAY ARRAY['rawWeight', 'cookedWeight', 'yieldFactor'] LOOP
      IF jsonb_typeof(p_snapshot->'preparationDetails'->v_key) IS DISTINCT FROM 'number' THEN
        RETURN false;
      END IF;
    END LOOP;
    IF jsonb_typeof(p_snapshot #> '{preparationDetails,preparationMethod}') IS DISTINCT FROM 'string'
       OR jsonb_typeof(p_snapshot #> '{preparationDetails,retentionFactors}') IS DISTINCT FROM 'object' THEN
      RETURN false;
    END IF;
    IF EXISTS (
      SELECT 1 FROM jsonb_each(p_snapshot #> '{preparationDetails,retentionFactors}')
      WHERE jsonb_typeof(value) <> 'number'
    ) THEN
      RETURN false;
    END IF;
  END IF;

  IF p_snapshot ? 'componentFoods' AND jsonb_typeof(p_snapshot->'componentFoods') <> 'null' THEN
    IF jsonb_typeof(p_snapshot->'componentFoods') IS DISTINCT FROM 'array' THEN
      RETURN false;
    END IF;
    IF EXISTS (
      SELECT 1
      FROM jsonb_array_elements(p_snapshot->'componentFoods') AS component
      WHERE jsonb_typeof(component) IS DISTINCT FROM 'object'
         OR jsonb_typeof(component->'id') IS DISTINCT FROM 'string'
         OR NULLIF(component->>'id', '') IS NULL
         OR jsonb_typeof(component->'parentEntryId') IS DISTINCT FROM 'string'
         OR NULLIF(component->>'parentEntryId', '') IS NULL
         OR jsonb_typeof(component->'foodId') IS DISTINCT FROM 'string'
         OR NULLIF(component->>'foodId', '') IS NULL
         OR jsonb_typeof(component->'amount') IS DISTINCT FROM 'number'
         OR jsonb_typeof(component->'unit') IS DISTINCT FROM 'string'
         OR NULLIF(component->>'unit', '') IS NULL
         OR (component ? 'sortOrder' AND jsonb_typeof(component->'sortOrder') NOT IN ('number', 'null'))
    ) THEN
      RETURN false;
    END IF;
  END IF;
  IF p_snapshot ? 'componentSnapshots'
     AND jsonb_typeof(p_snapshot->'componentSnapshots') <> 'null' THEN
    IF jsonb_typeof(p_snapshot->'componentSnapshots') IS DISTINCT FROM 'array' THEN
      RETURN false;
    END IF;
    IF EXISTS (
      SELECT 1
      FROM jsonb_array_elements(p_snapshot->'componentSnapshots') AS component
      WHERE NOT public.nutrition_food_snapshot_is_valid(component)
    ) THEN
      RETURN false;
    END IF;
  END IF;

  IF p_snapshot->>'entryType' = 'meal' THEN
    IF jsonb_typeof(p_snapshot->'componentFoods') IS DISTINCT FROM 'array'
       OR jsonb_typeof(p_snapshot->'componentSnapshots') IS DISTINCT FROM 'array'
       OR jsonb_array_length(p_snapshot->'componentFoods') <>
          jsonb_array_length(p_snapshot->'componentSnapshots') THEN
      RETURN false;
    END IF;
    FOR v_component, v_component_snapshot IN
      SELECT foods.value, snapshots.value
      FROM jsonb_array_elements(p_snapshot->'componentFoods')
        WITH ORDINALITY AS foods(value, ordinality)
      INNER JOIN jsonb_array_elements(p_snapshot->'componentSnapshots')
        WITH ORDINALITY AS snapshots(value, ordinality)
        USING (ordinality)
    LOOP
      IF v_component->>'foodId' IS DISTINCT FROM v_component_snapshot->>'foodId' THEN
        RETURN false;
      END IF;
    END LOOP;
  END IF;

  RETURN true;
END;
$$;


CREATE FUNCTION studyu_private.guard_nutrition_food_version()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_subject_id uuid;
BEGIN
  IF NOT public.nutrition_food_snapshot_is_valid(NEW.snapshot) THEN
    RAISE EXCEPTION 'invalid nutrition food snapshot' USING ERRCODE = '22023';
  END IF;
  IF NEW.snapshot->>'foodId' IS DISTINCT FROM NEW.food_id::text OR
     NEW.snapshot->>'foodVersionId' IS DISTINCT FROM NEW.id::text THEN
    RAISE EXCEPTION 'nutrition food version does not match food' USING ERRCODE = '22023';
  END IF;
  SELECT subject_id INTO v_subject_id FROM public.nutrition_food_definition WHERE id = NEW.food_id;
  PERFORM studyu_private.nutrition_assert_snapshot_owner(v_subject_id, NEW.snapshot, NEW.food_id);
  RETURN NEW;
END;
$$;

CREATE TRIGGER guard_nutrition_food_version
BEFORE INSERT OR UPDATE ON public.nutrition_food_version
FOR EACH ROW EXECUTE FUNCTION studyu_private.guard_nutrition_food_version();

REVOKE ALL ON FUNCTION studyu_private.nutrition_availability_is_valid(jsonb),
studyu_private.nutrition_snapshot_foods(jsonb),
studyu_private.nutrition_recall_foods(jsonb),
studyu_private.nutrition_assert_snapshot_owner(uuid, jsonb, uuid),
studyu_private.guard_nutrition_food_version()
FROM PUBLIC, anon, authenticated, service_role;

COMMIT;
