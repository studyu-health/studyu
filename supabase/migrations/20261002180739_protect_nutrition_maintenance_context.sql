BEGIN;

-- Custom settings are caller-controlled. Only the RPC owner can authorize maintenance.
CREATE SCHEMA IF NOT EXISTS studyu_private;
REVOKE ALL ON SCHEMA studyu_private FROM public,
anon,
authenticated,
service_role;
CREATE TABLE studyu_private.nutrition_maintenance_context (
    transaction_id bigint NOT NULL,
    subject_id uuid NOT NULL,
    operation text NOT NULL CHECK (
        operation IN ('advance', 'mutation', 'delete')
    ),
    PRIMARY KEY (transaction_id, subject_id, operation)
);
ALTER TABLE studyu_private.nutrition_maintenance_context ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE studyu_private.nutrition_maintenance_context
FROM public, anon, authenticated, service_role;

ALTER FUNCTION public.advance_owned_study_subject_day(uuid, integer)
SET SCHEMA studyu_private;
ALTER FUNCTION public.delete_owned_subject_progress(uuid)
SET SCHEMA studyu_private;
ALTER FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) SET SCHEMA studyu_private;
REVOKE ALL ON FUNCTION studyu_private.advance_owned_study_subject_day(
    uuid, integer
)
FROM public, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION studyu_private.delete_owned_subject_progress(uuid)
FROM public, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION studyu_private.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) FROM public, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION public.guard_nutrition_subject_clock()
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
  IF EXISTS (
    SELECT 1 FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = OLD.id
      AND operation = 'advance'
  ) THEN
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

CREATE OR REPLACE FUNCTION public.guard_nutrition_progress_mutation()
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
BEGIN
  IF EXISTS (
    SELECT 1 FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = v_subject_id
      AND ((TG_OP = 'UPDATE' AND operation IN ('advance', 'mutation'))
        OR (TG_OP = 'DELETE' AND operation = 'delete'))
  ) THEN
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

CREATE FUNCTION public.advance_owned_study_subject_day(
    p_subject_id uuid, p_days integer
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF p_subject_id IS NULL THEN
    RAISE EXCEPTION 'invalid study subject day advance' USING ERRCODE = '22023';
  END IF;
  INSERT INTO studyu_private.nutrition_maintenance_context
  VALUES (txid_current(), p_subject_id, 'advance');
  PERFORM studyu_private.advance_owned_study_subject_day(p_subject_id, p_days);
  DELETE FROM studyu_private.nutrition_maintenance_context
  WHERE transaction_id = txid_current() AND subject_id = p_subject_id
    AND operation = 'advance';
END;
$$;

CREATE FUNCTION public.delete_owned_subject_progress(p_subject_id uuid)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF p_subject_id IS NULL THEN
    RAISE EXCEPTION 'study subject is not owned by caller' USING ERRCODE = '42501';
  END IF;
  INSERT INTO studyu_private.nutrition_maintenance_context
  VALUES (txid_current(), p_subject_id, 'delete');
  PERFORM studyu_private.delete_owned_subject_progress(p_subject_id);
  DELETE FROM studyu_private.nutrition_maintenance_context
  WHERE transaction_id = txid_current() AND subject_id = p_subject_id
    AND operation = 'delete';
END;
$$;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;

CREATE FUNCTION studyu_private.nutrition_upgrade_legacy_food(p_food jsonb)
RETURNS jsonb
LANGUAGE sql IMMUTABLE SET search_path = ''
AS $$
  SELECT p_food || jsonb_build_object(
    'foodId', COALESCE(p_food->>'foodId', extensions.uuid_generate_v5(
      '6ba7b811-9dad-11d1-80b4-00c04fd430c8',
      'studyu:nutrition:legacy:food:' || (p_food->>'id')
    )::text),
    'foodVersionId', COALESCE(p_food->>'foodVersionId', extensions.uuid_generate_v5(
      '6ba7b811-9dad-11d1-80b4-00c04fd430c8',
      'studyu:nutrition:legacy:version:' || (p_food->>'id')
    )::text),
    'parentEntryId', COALESCE(p_food->'parentEntryId', p_food->'parentRecipeId', 'null'::jsonb),
    'preparationDetails', COALESCE(p_food->'preparationDetails', p_food->'recipeMetadata', 'null'::jsonb)
  ) || CASE WHEN p_food->>'entryType' = 'recipe' THEN jsonb_build_object(
    'entryType', 'manualCustom',
    'originalValues', COALESCE(p_food->'originalValues', '{}'::jsonb) ||
      jsonb_build_object('_legacyRecipeIngredients', p_food->'recipeIngredients')
  ) ELSE '{}'::jsonb END;
$$;
REVOKE ALL ON FUNCTION studyu_private.nutrition_upgrade_legacy_food(jsonb)
FROM public, anon, authenticated, service_role;

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
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_target public.subject_progress%ROWTYPE;
  v_food jsonb;
  v_meal_index integer;
  v_food_index integer;
  v_response jsonb;
BEGIN
  IF p_subject_id IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.study_subject
    WHERE id = p_subject_id AND (
      current_setting('role', true) = 'service_role' OR user_id = auth.uid()
    )
  ) THEN
    RAISE EXCEPTION 'nutrition definition subject is not owned by caller'
      USING ERRCODE = '42501';
  END IF;
  INSERT INTO studyu_private.nutrition_maintenance_context
  VALUES (txid_current(), p_subject_id, 'mutation');

  -- Bootstrap only a verified owned occurrence; client input cannot invent a baseline.
  IF p_historical_target IS NOT NULL AND p_expected_version_id IS NOT NULL THEN
    PERFORM pg_advisory_xact_lock(hashtextextended(p_food_id::text, 1));
    IF NOT EXISTS (SELECT 1 FROM public.nutrition_food_definition WHERE id = p_food_id) THEN
      BEGIN
        SELECT * INTO STRICT v_target FROM public.subject_progress
        WHERE subject_id = p_subject_id
          AND task_id = p_historical_target->>'taskId'
          AND intervention_id = p_historical_target->>'interventionId'
          AND completed_at = (p_historical_target->>'completedAt')::timestamptz
          AND result_type = 'DailyRecall'
          AND result->>'periodId' = p_historical_target->>'periodId'
          AND (result #>> '{result,studyDaySnapshot}')::integer =
            (p_historical_target->>'studyDaySnapshot')::integer
        FOR UPDATE;
        SELECT studyu_private.nutrition_upgrade_legacy_food(food),
          meal_ordinality::integer - 1, food_ordinality::integer - 1
        INTO STRICT v_food, v_meal_index, v_food_index
        FROM jsonb_array_elements(v_target.result #> '{result,meals}')
          WITH ORDINALITY AS meals(meal, meal_ordinality),
          jsonb_array_elements(meal->'foods')
          WITH ORDINALITY AS foods(food, food_ordinality)
        WHERE food->>'id' = p_historical_entry_id;
      EXCEPTION WHEN no_data_found OR too_many_rows THEN
        RAISE EXCEPTION 'historical nutrition recall target is missing or ambiguous'
          USING ERRCODE = 'P0002';
      END;
      IF v_food->>'foodId' IS DISTINCT FROM p_food_id::text OR
          v_food->>'foodVersionId' IS DISTINCT FROM p_expected_version_id::text OR
          NOT public.nutrition_food_snapshot_is_valid(v_food) THEN
        RAISE EXCEPTION 'historical target entry does not contain food definition'
          USING ERRCODE = 'P0002';
      END IF;
      INSERT INTO public.nutrition_food_definition (
        id, subject_id, kind, current_version_id, library_visible
      ) VALUES (
        p_food_id, p_subject_id,
        CASE WHEN v_food->>'entryType' = 'meal' THEN 'meal' ELSE 'food' END,
        p_expected_version_id, false
      );
      INSERT INTO public.nutrition_food_version (
        id, food_id, version_number, snapshot, mutation_id
      ) VALUES (p_expected_version_id, p_food_id, 1, v_food, gen_random_uuid());
      UPDATE public.subject_progress SET result = jsonb_set(
        result, ARRAY['result', 'meals', v_meal_index::text, 'foods', v_food_index::text], v_food
      ) WHERE subject_id = v_target.subject_id AND completed_at = v_target.completed_at;
    END IF;
  END IF;

  v_response := studyu_private.apply_nutrition_food_mutation(
    p_subject_id, p_mutation_id, p_food_id, p_expected_version_id, p_snapshot,
    p_deleted, p_historical_target, p_propagate_study_day,
    p_library_visible, p_historical_entry_id
  );
  DELETE FROM studyu_private.nutrition_maintenance_context
  WHERE transaction_id = txid_current() AND subject_id = p_subject_id
    AND operation = 'mutation';
  RETURN v_response;
END;
$$;

REVOKE ALL ON FUNCTION public.advance_owned_study_subject_day(uuid, integer)
FROM public, anon;
GRANT EXECUTE ON FUNCTION public.advance_owned_study_subject_day(uuid, integer)
TO authenticated, service_role;
REVOKE ALL ON FUNCTION public.delete_owned_subject_progress(uuid)
FROM public, anon;
GRANT EXECUTE ON FUNCTION public.delete_owned_subject_progress(uuid)
TO authenticated, service_role;
REVOKE ALL ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) FROM public, anon;
GRANT EXECUTE ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) TO authenticated, service_role;

COMMIT;
