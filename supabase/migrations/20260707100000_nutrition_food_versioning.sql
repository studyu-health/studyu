BEGIN;

CREATE TABLE public.nutrition_food_definition (
    id uuid PRIMARY KEY,
    subject_id uuid NOT NULL REFERENCES public.study_subject (
        id
    ) ON DELETE CASCADE,
    kind text NOT NULL CHECK (kind IN ('food', 'meal')),
    current_version_id uuid NOT NULL,
    library_visible boolean NOT NULL DEFAULT false,
    deleted_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.nutrition_food_version (
    id uuid PRIMARY KEY,
    food_id uuid NOT NULL REFERENCES public.nutrition_food_definition (
        id
    ) ON DELETE CASCADE,
    version_number integer NOT NULL CHECK (version_number > 0),
    snapshot jsonb NOT NULL,
    mutation_id uuid NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (food_id, version_number),
    UNIQUE (food_id, mutation_id)
);

ALTER TABLE public.nutrition_food_definition
ADD CONSTRAINT nutrition_food_definition_current_version_id_fkey
FOREIGN KEY (current_version_id) REFERENCES public.nutrition_food_version (id)
DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE public.nutrition_food_mutation (
    subject_id uuid NOT NULL REFERENCES public.study_subject (
        id
    ) ON DELETE CASCADE,
    mutation_id uuid NOT NULL,
    response jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (subject_id, mutation_id)
);

ALTER TABLE public.nutrition_food_definition ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nutrition_food_version ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nutrition_food_mutation ENABLE ROW LEVEL SECURITY;

CREATE POLICY nutrition_food_definition_select ON public.nutrition_food_definition
FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.study_subject AS subject
        WHERE
            subject.id = nutrition_food_definition.subject_id
            AND subject.user_id = auth.uid()
    )
);

CREATE POLICY nutrition_food_version_select ON public.nutrition_food_version
FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.nutrition_food_definition AS definition
        INNER JOIN
            public.study_subject AS subject
            ON definition.subject_id = subject.id
        WHERE
            definition.id = nutrition_food_version.food_id
            AND subject.user_id = auth.uid()
    )
);

CREATE FUNCTION public.nutrition_scale_json_numbers(
    p_value jsonb,
    p_factor numeric
) RETURNS jsonb
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public
AS $$
BEGIN
  RETURN CASE jsonb_typeof(p_value)
    WHEN 'number' THEN to_jsonb((p_value #>> '{}')::numeric * p_factor)
    WHEN 'object' THEN (
      SELECT COALESCE(
        jsonb_object_agg(key, public.nutrition_scale_json_numbers(value, p_factor)),
        '{}'::jsonb
      )
      FROM jsonb_each(p_value)
    )
    WHEN 'array' THEN (
      SELECT COALESCE(
        jsonb_agg(public.nutrition_scale_json_numbers(value, p_factor)),
        '[]'::jsonb
      )
      FROM jsonb_array_elements(p_value)
    )
    ELSE p_value
  END;
END;
$$;

-- Direct definition matches only. Saved-meal component snapshots remain immutable.
-- Logged occurrences own identity, quantity, placement, and timestamps; all
-- reusable food, serving, nutrition, composition, and source metadata comes
-- from the definition snapshot.
CREATE FUNCTION public.nutrition_replace_food_snapshots(
    p_result jsonb,
    p_food_id uuid,
    p_snapshot jsonb,
    p_entry_id text DEFAULT null
) RETURNS jsonb
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT jsonb_set(
    p_result,
    '{result,meals}',
    COALESCE((
      SELECT jsonb_agg(
        jsonb_set(
          meal,
          '{foods}',
          COALESCE((
            SELECT jsonb_agg(
              CASE WHEN food->>'foodId' = p_food_id::text
                AND (p_entry_id IS NULL OR food->>'id' = p_entry_id) THEN
                jsonb_set(
                  p_snapshot,
                  '{nutrition}',
                  public.nutrition_scale_json_numbers(
                    p_snapshot->'nutrition',
                    CASE
                      WHEN (p_snapshot->>'amount')::numeric > 0
                        THEN (food->>'amount')::numeric / (p_snapshot->>'amount')::numeric
                      ELSE 1
                    END
                  ),
                  true
                ) || jsonb_build_object(
                  'id', food->'id',
                  'amount', food->'amount',
                  'templateId', food->'templateId',
                  'createdAt', food->'createdAt',
                  'modifiedAt', food->'modifiedAt',
                  'parentEntryId', food->'parentEntryId'
                )
              ELSE food END
              ORDER BY ordinality
            )
            FROM jsonb_array_elements(COALESCE(meal->'foods', '[]'::jsonb))
              WITH ORDINALITY AS foods(food, ordinality)
          ), '[]'::jsonb),
          true
        )
        ORDER BY meal_ordinality
      )
      FROM jsonb_array_elements(COALESCE(p_result #> '{result,meals}', '[]'::jsonb))
        WITH ORDINALITY AS meals(meal, meal_ordinality)
    ), '[]'::jsonb),
    true
  );
$$;

CREATE FUNCTION public.nutrition_food_occurrence_count(
    p_result jsonb,
    p_food_id uuid,
    p_entry_id text DEFAULT null
) RETURNS integer
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT count(*)::integer
  FROM jsonb_array_elements(COALESCE(p_result #> '{result,meals}', '[]'::jsonb)) AS meal,
       jsonb_array_elements(COALESCE(meal->'foods', '[]'::jsonb)) AS food
  WHERE food->>'foodId' = p_food_id::text
    AND (p_entry_id IS NULL OR food->>'id' = p_entry_id);
$$;

CREATE FUNCTION public.nutrition_result_has_food(
    p_result jsonb,
    p_food_id uuid,
    p_entry_id text DEFAULT null
) RETURNS boolean
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT public.nutrition_food_occurrence_count(
    p_result, p_food_id, p_entry_id
  ) > 0;
$$;

CREATE FUNCTION public.nutrition_food_snapshot_is_valid(
    p_snapshot jsonb
) RETURNS boolean
LANGUAGE plpgsql
STABLE
SET search_path = public
AS $$
DECLARE
  v_key text;
  v_component jsonb;
  v_component_snapshot jsonb;
BEGIN
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

CREATE FUNCTION public.nutrition_subject_current_day(
    p_subject public.study_subject
) RETURNS integer
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
  SELECT (
    (now() AT TIME ZONE 'UTC')::date
    - (p_subject.started_at AT TIME ZONE 'UTC')::date
  )::integer;
$$;

CREATE FUNCTION public.guard_nutrition_subject_clock()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.id IS DISTINCT FROM OLD.id THEN
    RAISE EXCEPTION 'study subject clock and identity are immutable'
      USING ERRCODE = '22023';
  END IF;
  IF current_setting('studyu.nutrition_maintenance', true) =
      'advance:' || OLD.id::text THEN
    RETURN NEW;
  END IF;
  IF NEW.started_at IS DISTINCT FROM OLD.started_at OR
     NEW.study_id IS DISTINCT FROM OLD.study_id OR
     NEW.user_id IS DISTINCT FROM OLD.user_id THEN
    RAISE EXCEPTION 'study subject clock and identity are immutable'
      USING ERRCODE = '22023';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER guard_nutrition_subject_clock
BEFORE UPDATE ON public.study_subject
FOR EACH ROW EXECUTE FUNCTION public.guard_nutrition_subject_clock();

CREATE FUNCTION public.guard_nutrition_progress_mutation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_subject public.study_subject%ROWTYPE;
  v_subject_id uuid := CASE WHEN TG_OP = 'DELETE' THEN OLD.subject_id ELSE NEW.subject_id END;
  v_old_day integer;
  v_new_day integer;
  v_current_day integer;
  v_maintenance text :=
      current_setting('studyu.nutrition_maintenance', true);
BEGIN
  IF (TG_OP = 'UPDATE' AND v_maintenance IN (
        'advance:' || v_subject_id::text,
        'mutation:' || v_subject_id::text
      )) OR
     (TG_OP = 'DELETE' AND
      v_maintenance = 'delete:' || v_subject_id::text) THEN
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
  END IF;

  IF (TG_OP = 'INSERT' AND NEW.result_type IS DISTINCT FROM 'DailyRecall') OR
     (TG_OP = 'UPDATE' AND
      OLD.result_type IS DISTINCT FROM 'DailyRecall' AND
      NEW.result_type IS DISTINCT FROM 'DailyRecall') OR
     (TG_OP = 'DELETE' AND OLD.result_type IS DISTINCT FROM 'DailyRecall') THEN
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
  END IF;

  SELECT * INTO v_subject
  FROM public.study_subject
  WHERE id = v_subject_id AND user_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'nutrition progress subject is not owned by caller'
      USING ERRCODE = '42501';
  END IF;
  v_current_day := public.nutrition_subject_current_day(v_subject);

  BEGIN
    IF TG_OP <> 'INSERT' AND OLD.result_type = 'DailyRecall' THEN
      v_old_day := (OLD.result #>> '{result,studyDaySnapshot}')::integer;
    END IF;
    IF TG_OP <> 'DELETE' AND NEW.result_type = 'DailyRecall' THEN
      v_new_day := (NEW.result #>> '{result,studyDaySnapshot}')::integer;
    END IF;
  EXCEPTION WHEN invalid_text_representation THEN
    RAISE EXCEPTION 'invalid nutrition progress study day'
      USING ERRCODE = '22023';
  END;

  IF TG_OP = 'INSERT' AND NEW.result_type = 'DailyRecall' THEN
    IF v_new_day IS NULL OR v_new_day NOT IN (v_current_day - 1, v_current_day) THEN
      RAISE EXCEPTION 'nutrition recall study day is not writable'
        USING ERRCODE = '22023';
    END IF;
  ELSIF TG_OP = 'UPDATE' AND
        (OLD.result_type = 'DailyRecall' OR NEW.result_type = 'DailyRecall') THEN
    IF OLD.result_type IS DISTINCT FROM 'DailyRecall' OR
       NEW.result_type IS DISTINCT FROM 'DailyRecall' OR
       NEW.subject_id IS DISTINCT FROM OLD.subject_id OR
       v_old_day IS NULL OR
       v_new_day IS DISTINCT FROM v_old_day OR
       v_old_day NOT IN (v_current_day - 1, v_current_day) THEN
      RAISE EXCEPTION 'nutrition recall study day is not writable'
        USING ERRCODE = '22023';
    END IF;
  ELSIF TG_OP = 'DELETE' AND OLD.result_type = 'DailyRecall' AND
        (v_old_day IS NULL OR v_old_day NOT IN (v_current_day - 1, v_current_day)) THEN
    RAISE EXCEPTION 'nutrition recall study day is not writable'
      USING ERRCODE = '22023';
  END IF;

  RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$;

CREATE TRIGGER guard_nutrition_progress_mutation
BEFORE INSERT OR UPDATE OR DELETE ON public.subject_progress
FOR EACH ROW EXECUTE FUNCTION public.guard_nutrition_progress_mutation();

CREATE FUNCTION public.advance_owned_study_subject_day(
    p_subject_id uuid,
    p_days integer
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_completed_at timestamptz;
  v_previous_maintenance text :=
      current_setting('studyu.nutrition_maintenance', true);
  v_is_service_role boolean :=
      current_setting('role', true) = 'service_role';
BEGIN
  IF p_subject_id IS NULL OR p_days IS DISTINCT FROM 1 OR NOT EXISTS (
    SELECT 1 FROM public.study_subject
    WHERE id = p_subject_id
      AND (v_is_service_role OR user_id = auth.uid())
  ) THEN
    RAISE EXCEPTION 'invalid study subject day advance'
      USING ERRCODE = '22023';
  END IF;
  PERFORM set_config(
    'studyu.nutrition_maintenance', 'advance:' || p_subject_id::text, true
  );
  FOR v_completed_at IN
    SELECT completed_at
    FROM public.subject_progress
    WHERE subject_id = p_subject_id
    ORDER BY completed_at
  LOOP
    UPDATE public.subject_progress
    SET completed_at = v_completed_at - interval '1 day'
    WHERE subject_id = p_subject_id AND completed_at = v_completed_at;
  END LOOP;
  UPDATE public.study_subject
  SET started_at = started_at - interval '1 day'
  WHERE id = p_subject_id;
  PERFORM set_config(
    'studyu.nutrition_maintenance', COALESCE(v_previous_maintenance, ''), true
  );
END;
$$;

CREATE FUNCTION public.delete_owned_subject_progress(
    p_subject_id uuid
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_previous_maintenance text :=
      current_setting('studyu.nutrition_maintenance', true);
  v_is_service_role boolean :=
      current_setting('role', true) = 'service_role';
BEGIN
  IF p_subject_id IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.study_subject
    WHERE id = p_subject_id
      AND (v_is_service_role OR user_id = auth.uid())
  ) THEN
    RAISE EXCEPTION 'study subject is not owned by caller'
      USING ERRCODE = '42501';
  END IF;
  PERFORM set_config(
    'studyu.nutrition_maintenance', 'delete:' || p_subject_id::text, true
  );
  DELETE FROM public.subject_progress WHERE subject_id = p_subject_id;
  PERFORM set_config(
    'studyu.nutrition_maintenance', COALESCE(v_previous_maintenance, ''), true
  );
END;
$$;

CREATE FUNCTION public.apply_nutrition_food_mutation(
    p_subject_id uuid,
    p_mutation_id uuid,
    p_food_id uuid,
    p_expected_version_id uuid,
    p_snapshot jsonb,
    p_deleted boolean DEFAULT false,
    p_historical_target jsonb DEFAULT null,
    p_propagate_study_day integer DEFAULT null,
    p_library_visible boolean DEFAULT null,
    p_historical_entry_id text DEFAULT null
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_subject public.study_subject%ROWTYPE;
  v_definition public.nutrition_food_definition%ROWTYPE;
  v_current_study_day integer;
  v_version_id uuid := gen_random_uuid();
  v_version_number integer;
  v_snapshot jsonb := p_snapshot;
  v_component jsonb;
  v_component_snapshot jsonb;
  v_component_food_id uuid;
  v_component_version_id uuid;
  v_component_definition public.nutrition_food_definition%ROWTYPE;
  v_target public.subject_progress%ROWTYPE;
  v_target_count integer;
  v_progress jsonb := '[]'::jsonb;
  v_progress_row jsonb;
  v_selected_historical_update_count integer := 0;
  v_today_update_count integer := 0;
  v_response jsonb;
  v_previous_maintenance text :=
      current_setting('studyu.nutrition_maintenance', true);
  v_is_service_role boolean :=
      current_setting('role', true) = 'service_role';
BEGIN
  SELECT * INTO v_subject
  FROM public.study_subject
  WHERE id = p_subject_id
    AND (v_is_service_role OR user_id = auth.uid());
  IF NOT FOUND THEN
    RAISE EXCEPTION 'nutrition definition subject is not owned by caller'
      USING ERRCODE = '42501';
  END IF;
  v_current_study_day := public.nutrition_subject_current_day(v_subject);

  IF p_mutation_id IS NULL THEN
    RAISE EXCEPTION 'invalid nutrition mutation payload' USING ERRCODE = '22023';
  END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended(p_subject_id::text || p_mutation_id::text, 0));
  SELECT response INTO v_response
  FROM public.nutrition_food_mutation
  WHERE subject_id = p_subject_id AND mutation_id = p_mutation_id;
  IF FOUND THEN RETURN v_response; END IF;

  IF p_food_id IS NULL OR p_snapshot IS NULL OR
      p_snapshot->>'foodId' IS DISTINCT FROM p_food_id::text OR
      NOT public.nutrition_food_snapshot_is_valid(p_snapshot) THEN
    RAISE EXCEPTION 'invalid nutrition mutation payload' USING ERRCODE = '22023';
  END IF;
  IF (p_historical_target IS NULL AND (
        p_historical_entry_id IS NOT NULL OR
        p_propagate_study_day IS NOT NULL
      )) OR
      (p_historical_target IS NOT NULL AND (
        p_deleted OR
        NULLIF(p_historical_entry_id, '') IS NULL OR
        (
          p_propagate_study_day IS NOT NULL AND
          p_propagate_study_day IS DISTINCT FROM v_current_study_day
        ) OR
        (p_historical_target->>'studyDaySnapshot')::integer IS DISTINCT FROM
            v_current_study_day - 1
      )) THEN
    RAISE EXCEPTION 'historical nutrition recall is no longer editable'
      USING ERRCODE = '22023';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended(p_food_id::text, 1));
  SELECT * INTO v_definition
  FROM public.nutrition_food_definition
  WHERE id = p_food_id AND subject_id = p_subject_id
  FOR UPDATE;

  IF FOUND THEN
    IF p_expected_version_id IS NULL OR (
      v_definition.current_version_id <> p_expected_version_id AND NOT (
        v_definition.deleted_at IS NOT NULL AND
        p_historical_target IS NOT NULL AND
        EXISTS (
          SELECT 1 FROM public.nutrition_food_version
          WHERE id = p_expected_version_id AND food_id = p_food_id
        )
      )
    ) THEN
      RAISE EXCEPTION 'stale nutrition definition version' USING ERRCODE = '40001';
    END IF;
    v_version_number := (
      SELECT COALESCE(MAX(version_number), 0) + 1
      FROM public.nutrition_food_version WHERE food_id = p_food_id
    );
  ELSE
    IF p_expected_version_id IS NOT NULL THEN
      RAISE EXCEPTION 'nutrition definition does not exist' USING ERRCODE = 'P0002';
    END IF;
    v_version_number := 1;
    INSERT INTO public.nutrition_food_definition (
      id, subject_id, kind, current_version_id, library_visible
    ) VALUES (
      p_food_id,
      p_subject_id,
      CASE WHEN p_snapshot->>'entryType' = 'meal' THEN 'meal' ELSE 'food' END,
      v_version_id,
      COALESCE(p_library_visible, false)
    );
  END IF;

  IF p_historical_target IS NOT NULL AND
      jsonb_typeof(v_snapshot->'componentSnapshots') = 'array' THEN
    FOR v_component IN
      SELECT DISTINCT ON (component->>'foodId') component
      FROM jsonb_array_elements(v_snapshot->'componentSnapshots')
        WITH ORDINALITY AS components(component, ordinality)
      ORDER BY component->>'foodId', ordinality DESC
    LOOP
      BEGIN
        v_component_food_id := (v_component->>'foodId')::uuid;
        v_component_version_id := (v_component->>'foodVersionId')::uuid;
      EXCEPTION WHEN invalid_text_representation THEN
        RAISE EXCEPTION 'invalid nutrition mutation payload'
          USING ERRCODE = '22023';
      END;

      PERFORM pg_advisory_xact_lock(
        hashtextextended(v_component_food_id::text, 1)
      );
      SELECT * INTO v_component_definition
      FROM public.nutrition_food_definition
      WHERE id = v_component_food_id
      FOR UPDATE;

      IF FOUND THEN
        IF v_component_definition.subject_id <> p_subject_id THEN
          RAISE EXCEPTION 'nutrition component definition is not owned by subject'
            USING ERRCODE = '42501';
        END IF;
        SELECT version.id INTO v_component_version_id
        FROM public.nutrition_food_version AS version
        WHERE version.id = v_component_version_id
          AND version.food_id = v_component_food_id;
        IF NOT FOUND THEN
          v_component_version_id := v_component_definition.current_version_id;
        END IF;
      ELSE
        v_component_version_id := gen_random_uuid();
        v_component_snapshot := jsonb_set(
          v_component,
          '{foodVersionId}',
          to_jsonb(v_component_version_id::text),
          true
        );
        INSERT INTO public.nutrition_food_definition (
          id, subject_id, kind, current_version_id, library_visible
        ) VALUES (
          v_component_food_id,
          p_subject_id,
          CASE WHEN v_component->>'entryType' = 'meal' THEN 'meal' ELSE 'food' END,
          v_component_version_id,
          false
        );
        INSERT INTO public.nutrition_food_version (
          id, food_id, version_number, snapshot, mutation_id
        ) VALUES (
          v_component_version_id,
          v_component_food_id,
          1,
          v_component_snapshot,
          p_mutation_id
        );
      END IF;

      v_snapshot := jsonb_set(
        v_snapshot,
        '{componentSnapshots}',
        (
          SELECT jsonb_agg(
            CASE WHEN component->>'foodId' = v_component_food_id::text
              THEN jsonb_set(
                component,
                '{foodVersionId}',
                to_jsonb(v_component_version_id::text),
                true
              )
              ELSE component
            END
            ORDER BY ordinality
          )
          FROM jsonb_array_elements(v_snapshot->'componentSnapshots')
            WITH ORDINALITY AS components(component, ordinality)
        ),
        true
      );
    END LOOP;
  END IF;

  v_snapshot := jsonb_set(
    v_snapshot,
    '{foodVersionId}',
    to_jsonb(v_version_id::text),
    true
  );
  INSERT INTO public.nutrition_food_version (
    id, food_id, version_number, snapshot, mutation_id
  ) VALUES (
    v_version_id, p_food_id, v_version_number, v_snapshot, p_mutation_id
  );
  UPDATE public.nutrition_food_definition
  SET current_version_id = v_version_id,
      deleted_at = CASE WHEN p_deleted THEN now() ELSE NULL END,
      library_visible = COALESCE(p_library_visible, library_visible),
      updated_at = now()
  WHERE id = p_food_id;

  PERFORM set_config(
    'studyu.nutrition_maintenance', 'mutation:' || p_subject_id::text, true
  );

  IF p_historical_target IS NOT NULL THEN
    SELECT count(*) INTO v_target_count
    FROM public.subject_progress
    WHERE subject_id = p_subject_id
      AND task_id = p_historical_target->>'taskId'
      AND intervention_id = p_historical_target->>'interventionId'
      AND completed_at = (p_historical_target->>'completedAt')::timestamptz
      AND result_type = 'DailyRecall'
      AND result->>'periodId' = p_historical_target->>'periodId'
      AND (result #>> '{result,studyDaySnapshot}')::integer =
          (p_historical_target->>'studyDaySnapshot')::integer;
    IF v_target_count <> 1 THEN
      RAISE EXCEPTION 'historical nutrition recall target is missing or ambiguous'
        USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_target
    FROM public.subject_progress
    WHERE subject_id = p_subject_id
      AND task_id = p_historical_target->>'taskId'
      AND intervention_id = p_historical_target->>'interventionId'
      AND completed_at = (p_historical_target->>'completedAt')::timestamptz
      AND result_type = 'DailyRecall'
      AND result->>'periodId' = p_historical_target->>'periodId'
      AND (result #>> '{result,studyDaySnapshot}')::integer =
          (p_historical_target->>'studyDaySnapshot')::integer
    FOR UPDATE;
    IF NOT public.nutrition_result_has_food(
      v_target.result, p_food_id, p_historical_entry_id
    ) THEN
      RAISE EXCEPTION 'historical target entry does not contain food definition'
        USING ERRCODE = 'P0002';
    END IF;
    UPDATE public.subject_progress
    SET result = public.nutrition_replace_food_snapshots(
      result, p_food_id, v_snapshot, p_historical_entry_id
    )
    WHERE completed_at = v_target.completed_at AND subject_id = v_target.subject_id
    RETURNING to_jsonb(public.subject_progress.*) INTO v_progress_row;
    GET DIAGNOSTICS v_selected_historical_update_count = ROW_COUNT;
    v_progress := v_progress || jsonb_build_array(v_progress_row);
  END IF;

  IF p_propagate_study_day IS NOT NULL THEN
    WITH updated AS (
      UPDATE public.subject_progress
      SET result = public.nutrition_replace_food_snapshots(result, p_food_id, v_snapshot)
      WHERE subject_id = p_subject_id
        AND result_type = 'DailyRecall'
        AND (result #>> '{result,studyDaySnapshot}')::integer = v_current_study_day
        AND public.nutrition_result_has_food(result, p_food_id)
      RETURNING
        to_jsonb(public.subject_progress.*) AS row,
        public.nutrition_food_occurrence_count(result, p_food_id) AS occurrence_count
    )
    SELECT
      v_progress || COALESCE(jsonb_agg(row), '[]'::jsonb),
      COALESCE(sum(occurrence_count), 0)::integer
    INTO v_progress, v_today_update_count
    FROM updated;
  END IF;

  SELECT jsonb_build_object(
    'definition', jsonb_build_object(
      'id', definition.id,
      'subjectId', definition.subject_id,
      'kind', definition.kind,
      'currentVersionId', definition.current_version_id,
      'deletedAt', definition.deleted_at,
      'snapshot', v_snapshot,
      'createdAt', definition.created_at,
      'updatedAt', definition.updated_at
    ),
    'progress', v_progress,
    'selectedHistoricalUpdateCount', v_selected_historical_update_count,
    'todayUpdateCount', v_today_update_count
  ) INTO v_response
  FROM public.nutrition_food_definition AS definition
  WHERE definition.id = p_food_id;

  PERFORM set_config(
    'studyu.nutrition_maintenance', COALESCE(v_previous_maintenance, ''), true
  );
  INSERT INTO public.nutrition_food_mutation (subject_id, mutation_id, response)
  VALUES (p_subject_id, p_mutation_id, v_response);
  RETURN v_response;
END;
$$;

REVOKE ALL ON FUNCTION public.nutrition_scale_json_numbers(jsonb, numeric)
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.nutrition_subject_current_day(
    public.study_subject
)
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.guard_nutrition_subject_clock()
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.guard_nutrition_progress_mutation()
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.advance_owned_study_subject_day(uuid, integer)
FROM public, anon;
GRANT EXECUTE ON FUNCTION public.advance_owned_study_subject_day(uuid, integer)
TO authenticated, service_role;
REVOKE ALL ON FUNCTION public.delete_owned_subject_progress(uuid)
FROM public, anon;
GRANT EXECUTE ON FUNCTION public.delete_owned_subject_progress(uuid)
TO authenticated, service_role;
REVOKE ALL ON FUNCTION public.nutrition_food_snapshot_is_valid(jsonb)
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.nutrition_replace_food_snapshots(
    jsonb, uuid, jsonb, text
)
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.nutrition_food_occurrence_count(
    jsonb, uuid, text
)
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.nutrition_result_has_food(jsonb, uuid, text)
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) FROM public, anon;
GRANT EXECUTE ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) TO authenticated, service_role;
GRANT SELECT ON TABLE public.nutrition_food_definition,
public.nutrition_food_version TO authenticated, service_role;
GRANT ALL ON TABLE public.nutrition_food_definition,
public.nutrition_food_version,
public.nutrition_food_mutation TO service_role;

COMMIT;
