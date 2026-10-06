BEGIN;

-- Intent is transient. Stored snapshots must not authorize an older serializer.
ALTER TABLE studyu_private.nutrition_maintenance_context
DROP CONSTRAINT nutrition_maintenance_context_operation_check;
ALTER TABLE studyu_private.nutrition_maintenance_context
ADD CONSTRAINT nutrition_maintenance_context_operation_check
CHECK (operation IN ('advance', 'mutation', 'delete', 'availability'));

-- BEFORE INSERT also runs for UPSERT. Bind its intent to the exact update payload.
CREATE TABLE studyu_private.nutrition_recall_write_intent (
    transaction_id bigint NOT NULL,
    subject_id uuid NOT NULL,
    completed_at timestamptz NOT NULL,
    task_id text NOT NULL,
    intervention_id text NOT NULL,
    result jsonb NOT NULL,
    PRIMARY KEY (transaction_id, subject_id, completed_at)
);
ALTER TABLE studyu_private.nutrition_recall_write_intent ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE studyu_private.nutrition_recall_write_intent
FROM public, anon, authenticated, service_role;

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
  SELECT nested
  FROM jsonb_array_elements(
    CASE WHEN jsonb_typeof(p_result #> '{result,meals}') = 'array'
      THEN p_result #> '{result,meals}' ELSE '[]'::jsonb END
  ) AS meal,
  LATERAL jsonb_array_elements(
    CASE WHEN jsonb_typeof(meal->'foods') = 'array'
      THEN meal->'foods' ELSE '[]'::jsonb END
  ) AS food,
  LATERAL studyu_private.nutrition_snapshot_foods(food) AS nested;
$$;

CREATE FUNCTION studyu_private.nutrition_has_availability(p_food jsonb)
RETURNS boolean LANGUAGE sql IMMUTABLE SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM studyu_private.nutrition_snapshot_foods(p_food) AS food
    WHERE COALESCE(food #> '{nutrition,unavailableNutrients}', '[]'::jsonb) <> '[]'::jsonb
       OR COALESCE(food #> '{nutrition,partialNutrients}', '[]'::jsonb) <> '[]'::jsonb
  );
$$;

CREATE FUNCTION studyu_private.nutrition_assert_food_availability(
    p_subject_id uuid, p_food jsonb, p_supported boolean,
    p_mutating_food_id uuid DEFAULT null
) RETURNS void LANGUAGE plpgsql SET search_path = ''
AS $$
DECLARE
  v_food jsonb;
  v_food_id uuid;
  v_version_id uuid;
  v_version record;
  v_definition record;
BEGIN
  FOR v_food IN SELECT * FROM studyu_private.nutrition_snapshot_foods(p_food) LOOP
    IF NOT studyu_private.nutrition_availability_is_valid(v_food->'nutrition') THEN
      RAISE EXCEPTION 'invalid nutrition availability metadata' USING ERRCODE = '22023';
    END IF;
    IF NOT p_supported AND studyu_private.nutrition_has_availability(v_food) THEN
      RAISE EXCEPTION 'nutrition availability write intent is required' USING ERRCODE = '22023';
    END IF;

    -- Legacy entries can have identifiers which are not stored definition UUIDs.
    v_food_id := null;
    v_version_id := null;
    BEGIN
      v_food_id := (v_food->>'foodId')::uuid;
    EXCEPTION WHEN invalid_text_representation THEN NULL;
    END;
    BEGIN
      v_version_id := (v_food->>'foodVersionId')::uuid;
    EXCEPTION WHEN invalid_text_representation THEN NULL;
    END;
    IF p_mutating_food_id IS NOT NULL AND v_food_id = p_mutating_food_id
       AND v_food = p_food THEN CONTINUE; END IF;

    SELECT version.food_id, definition.subject_id, version.snapshot
    INTO v_version
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
      IF NOT p_supported AND studyu_private.nutrition_has_availability(v_version.snapshot) THEN
        RAISE EXCEPTION 'nutrition availability write intent is required' USING ERRCODE = '22023';
      END IF;
    ELSE
      -- A missing/provisional version cannot bypass a metadata-bearing definition.
      SELECT definition.subject_id, version.snapshot INTO v_definition
      FROM public.nutrition_food_definition AS definition
      JOIN public.nutrition_food_version AS version ON version.id = definition.current_version_id
      WHERE definition.id = v_food_id;
      IF FOUND THEN
        IF v_definition.subject_id IS DISTINCT FROM p_subject_id THEN
          RAISE EXCEPTION 'nutrition definition subject is not owned by caller' USING ERRCODE = '42501';
        END IF;
        IF NOT p_supported AND studyu_private.nutrition_has_availability(v_definition.snapshot) THEN
          RAISE EXCEPTION 'nutrition availability write intent is required' USING ERRCODE = '22023';
        END IF;
      END IF;
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


CREATE FUNCTION public.guard_nutrition_food_version_availability()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_food jsonb;
  v_subject_id uuid;
  v_supported boolean;
BEGIN
  FOR v_food IN SELECT * FROM studyu_private.nutrition_snapshot_foods(NEW.snapshot) LOOP
    IF NOT studyu_private.nutrition_availability_is_valid(v_food->'nutrition') THEN
      RAISE EXCEPTION 'invalid nutrition availability metadata' USING ERRCODE = '22023';
    END IF;
  END LOOP;
  IF NEW.snapshot ? 'nutritionAvailabilityWriteIntent' AND
     NEW.snapshot->>'nutritionAvailabilityWriteIntent' IS DISTINCT FROM 'explicit-v1' THEN
    RAISE EXCEPTION 'invalid nutrition availability write intent' USING ERRCODE = '22023';
  END IF;
  SELECT subject_id INTO v_subject_id FROM public.nutrition_food_definition WHERE id = NEW.food_id;
  v_supported := COALESCE(NEW.snapshot->>'nutritionAvailabilityWriteIntent' = 'explicit-v1', false)
    OR EXISTS (SELECT 1 FROM studyu_private.nutrition_maintenance_context
               WHERE transaction_id = txid_current() AND subject_id = v_subject_id
                 AND operation = 'availability');
  NEW.snapshot := NEW.snapshot - 'nutritionAvailabilityWriteIntent';
  IF TG_OP = 'UPDATE' AND NEW.snapshot IS NOT DISTINCT FROM OLD.snapshot
     AND NEW.food_id IS NOT DISTINCT FROM OLD.food_id AND NEW.id IS NOT DISTINCT FROM OLD.id THEN
    RETURN NEW;
  END IF;
  IF NEW.snapshot->>'foodId' IS DISTINCT FROM NEW.food_id::text OR
     NEW.snapshot->>'foodVersionId' IS DISTINCT FROM NEW.id::text THEN
    RAISE EXCEPTION 'nutrition food version does not match food' USING ERRCODE = '22023';
  END IF;
  IF NOT v_supported AND (
    (TG_OP = 'UPDATE' AND studyu_private.nutrition_has_availability(OLD.snapshot)) OR
    (TG_OP = 'INSERT' AND EXISTS (
      SELECT 1 FROM public.nutrition_food_definition AS definition
      JOIN public.nutrition_food_version AS version ON version.id = definition.current_version_id
      WHERE definition.id = NEW.food_id AND studyu_private.nutrition_has_availability(version.snapshot)
    ))
  ) THEN
    RAISE EXCEPTION 'nutrition availability write intent is required' USING ERRCODE = '22023';
  END IF;
  PERFORM studyu_private.nutrition_assert_food_availability(v_subject_id, NEW.snapshot, v_supported, NEW.food_id);
  RETURN NEW;
END;
$$;
CREATE TRIGGER guard_nutrition_food_version_availability
BEFORE INSERT OR UPDATE ON public.nutrition_food_version
FOR EACH ROW EXECUTE FUNCTION public.guard_nutrition_food_version_availability();

CREATE FUNCTION public.guard_nutrition_progress_availability()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_supported boolean;
  v_food jsonb;
BEGIN
  IF NEW.result_type IS DISTINCT FROM 'DailyRecall' THEN RETURN NEW; END IF;
  -- Check ownership before reading referenced versions through this definer.
  IF current_setting('role', true) IS DISTINCT FROM 'service_role' AND NOT EXISTS (
    SELECT 1 FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = NEW.subject_id
      AND operation IN ('advance', 'mutation')
  ) AND NOT EXISTS (
    SELECT 1 FROM public.study_subject WHERE id = NEW.subject_id AND user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'nutrition progress subject is not owned by caller' USING ERRCODE = '42501';
  END IF;
  IF NEW.result ? 'nutritionAvailabilityWriteIntent' AND
     NEW.result->>'nutritionAvailabilityWriteIntent' IS DISTINCT FROM 'explicit-v1' THEN
    RAISE EXCEPTION 'invalid nutrition availability write intent' USING ERRCODE = '22023';
  END IF;
  v_supported := COALESCE(NEW.result->>'nutritionAvailabilityWriteIntent' = 'explicit-v1', false)
    OR EXISTS (SELECT 1 FROM studyu_private.nutrition_maintenance_context
               WHERE transaction_id = txid_current() AND subject_id = NEW.subject_id
                 AND operation = 'availability')
    OR EXISTS (SELECT 1 FROM studyu_private.nutrition_recall_write_intent
               WHERE transaction_id = txid_current() AND subject_id = NEW.subject_id
                 AND completed_at = NEW.completed_at AND task_id = NEW.task_id
                 AND intervention_id = NEW.intervention_id
                 AND result = NEW.result - 'nutritionAvailabilityWriteIntent');
  IF TG_OP = 'INSERT' AND NEW.result->>'nutritionAvailabilityWriteIntent' = 'explicit-v1' THEN
    INSERT INTO studyu_private.nutrition_recall_write_intent
    VALUES (txid_current(), NEW.subject_id, NEW.completed_at, NEW.task_id,
            NEW.intervention_id, NEW.result - 'nutritionAvailabilityWriteIntent')
    ON CONFLICT (transaction_id, subject_id, completed_at) DO UPDATE
      SET task_id = EXCLUDED.task_id, intervention_id = EXCLUDED.intervention_id,
          result = EXCLUDED.result;
  END IF;
  NEW.result := NEW.result - 'nutritionAvailabilityWriteIntent';

  FOR v_food IN SELECT * FROM studyu_private.nutrition_recall_foods(NEW.result) LOOP
    IF NOT studyu_private.nutrition_availability_is_valid(v_food->'nutrition') THEN
      RAISE EXCEPTION 'invalid nutrition availability metadata' USING ERRCODE = '22023';
    END IF;
  END LOOP;
  -- Clock maintenance can update a row without changing its recall.
  IF TG_OP = 'UPDATE' AND NEW.result IS NOT DISTINCT FROM OLD.result THEN RETURN NEW; END IF;
  IF TG_OP = 'UPDATE' AND NOT v_supported AND EXISTS (
    SELECT 1 FROM studyu_private.nutrition_recall_foods(OLD.result) AS food
    WHERE studyu_private.nutrition_has_availability(food)
  ) THEN
    RAISE EXCEPTION 'nutrition availability write intent is required' USING ERRCODE = '22023';
  END IF;
  FOR v_food IN SELECT * FROM studyu_private.nutrition_recall_foods(NEW.result) LOOP
    PERFORM studyu_private.nutrition_assert_food_availability(NEW.subject_id, v_food, v_supported);
  END LOOP;
  RETURN NEW;
END;
$$;
CREATE TRIGGER guard_nutrition_progress_availability
BEFORE INSERT OR UPDATE ON public.subject_progress
FOR EACH ROW EXECUTE FUNCTION public.guard_nutrition_progress_availability();

CREATE FUNCTION public.clear_nutrition_progress_availability_intent()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  DELETE FROM studyu_private.nutrition_recall_write_intent
  WHERE transaction_id = txid_current();
  RETURN null;
END;
$$;
-- Statement cleanup also covers INSERT ON CONFLICT DO NOTHING.
CREATE TRIGGER clear_nutrition_progress_availability_intent
AFTER INSERT OR UPDATE ON public.subject_progress
FOR EACH STATEMENT EXECUTE FUNCTION public.clear_nutrition_progress_availability_intent();

-- Keep the previous ownership, revision, idempotency, and day-context checks.
ALTER FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) RENAME TO apply_nutrition_food_mutation_without_availability;
ALTER FUNCTION public.apply_nutrition_food_mutation_without_availability(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) SET SCHEMA studyu_private;
REVOKE ALL ON FUNCTION studyu_private.apply_nutrition_food_mutation_without_availability(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) FROM public, anon, authenticated, service_role;

CREATE FUNCTION public.apply_nutrition_food_mutation(
    p_subject_id uuid, p_mutation_id uuid, p_food_id uuid,
    p_expected_version_id uuid, p_snapshot jsonb,
    p_deleted boolean DEFAULT false, p_historical_target jsonb DEFAULT null,
    p_propagate_study_day integer DEFAULT null,
    p_library_visible boolean DEFAULT null,
    p_historical_entry_id text DEFAULT null
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_supported boolean;
  v_snapshot jsonb;
  v_definition record;
  v_response jsonb;
BEGIN
  IF p_subject_id IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.study_subject WHERE id = p_subject_id AND
      (current_setting('role', true) = 'service_role' OR user_id = auth.uid())
  ) THEN
    RAISE EXCEPTION 'nutrition definition subject is not owned by caller' USING ERRCODE = '42501';
  END IF;
  IF p_snapshot ? 'nutritionAvailabilityWriteIntent' AND
     p_snapshot->>'nutritionAvailabilityWriteIntent' IS DISTINCT FROM 'explicit-v1' THEN
    RAISE EXCEPTION 'invalid nutrition availability write intent' USING ERRCODE = '22023';
  END IF;
  v_supported := COALESCE(p_snapshot->>'nutritionAvailabilityWriteIntent' = 'explicit-v1', false);
  v_snapshot := CASE WHEN jsonb_typeof(p_snapshot) = 'object'
    THEN p_snapshot - 'nutritionAvailabilityWriteIntent' ELSE p_snapshot END;
  PERFORM pg_advisory_xact_lock(hashtextextended(p_food_id::text, 1));
  SELECT definition.subject_id, version.snapshot INTO v_definition
  FROM public.nutrition_food_definition AS definition
  JOIN public.nutrition_food_version AS version ON version.id = definition.current_version_id
  WHERE definition.id = p_food_id;
  IF FOUND THEN
    IF v_definition.subject_id IS DISTINCT FROM p_subject_id THEN
      RAISE EXCEPTION 'nutrition definition subject is not owned by caller' USING ERRCODE = '42501';
    END IF;
    IF NOT v_supported AND studyu_private.nutrition_has_availability(v_definition.snapshot) THEN
      RAISE EXCEPTION 'nutrition availability write intent is required' USING ERRCODE = '22023';
    END IF;
  END IF;
  PERFORM studyu_private.nutrition_assert_food_availability(
    p_subject_id, v_snapshot, v_supported, p_food_id
  );
  IF v_supported THEN
    INSERT INTO studyu_private.nutrition_maintenance_context
    VALUES (txid_current(), p_subject_id, 'availability');
  END IF;
  v_response := studyu_private.apply_nutrition_food_mutation_without_availability(
    p_subject_id, p_mutation_id, p_food_id, p_expected_version_id, v_snapshot,
    p_deleted, p_historical_target, p_propagate_study_day,
    p_library_visible, p_historical_entry_id
  );
  IF v_supported THEN
    DELETE FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = p_subject_id AND operation = 'availability';
  END IF;
  RETURN v_response;
END;
$$;

REVOKE ALL ON FUNCTION studyu_private.nutrition_availability_is_valid(jsonb),
studyu_private.nutrition_snapshot_foods(jsonb),
studyu_private.nutrition_recall_foods(jsonb),
studyu_private.nutrition_has_availability(jsonb),
studyu_private.nutrition_assert_food_availability(uuid, jsonb, boolean, uuid),
public.guard_nutrition_food_version_availability(),
public.guard_nutrition_progress_availability(),
public.clear_nutrition_progress_availability_intent()
FROM public, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) FROM public, anon;
GRANT EXECUTE ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) TO authenticated, service_role;

COMMIT;
