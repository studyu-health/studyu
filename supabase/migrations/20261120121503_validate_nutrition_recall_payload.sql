BEGIN;

CREATE FUNCTION studyu_private.nutrition_timestamp_is_valid(p_value text)
RETURNS boolean LANGUAGE plpgsql STABLE SET search_path = ''
AS $$
BEGIN
    IF p_value IS NULL OR p_value !~
       '^[0-9]{4}-[0-9]{2}-[0-9]{2}([Tt ][0-9]{2}:[0-9]{2}:[0-9]{2}([.][0-9]{1,6})?([Zz]|[+-][0-9]{2}:?[0-9]{2})?)?$' THEN
        RETURN false;
    END IF;
    RETURN isfinite(p_value::timestamptz);
EXCEPTION WHEN data_exception THEN
    RETURN false;
END;
$$;

CREATE FUNCTION studyu_private.nutrition_recall_is_valid(p_recall jsonb)
RETURNS boolean LANGUAGE plpgsql STABLE SET search_path = ''
AS $$
DECLARE
    v_key text;
    v_meal jsonb;
BEGIN
    IF jsonb_typeof(p_recall) IS DISTINCT FROM 'object'
       OR jsonb_typeof(p_recall->'id') IS DISTINCT FROM 'string'
       OR NULLIF(p_recall->>'id', '') IS NULL
       OR NOT studyu_private.nutrition_timestamp_is_valid(p_recall->>'date')
       OR NOT studyu_private.nutrition_timestamp_is_valid(p_recall->>'entryCompletedAt')
       OR COALESCE(p_recall->>'recallMode', '') NOT IN ('realtimeRecord', 'yesterdayRecall')
       OR jsonb_typeof(p_recall->'meals') IS DISTINCT FROM 'array'
       OR jsonb_typeof(p_recall->'isUsualIntakeDay') NOT IN ('boolean', 'null')
       OR jsonb_typeof(p_recall->'specialOccasion') NOT IN ('string', 'null')
       OR jsonb_typeof(p_recall->'waterIntakeMl') NOT IN ('number', 'null')
       OR jsonb_typeof(p_recall->'availabilityVerified') NOT IN ('boolean', 'null') THEN
        RETURN false;
    END IF;

    FOREACH v_key IN ARRAY ARRAY['entryStartedAt', 'lastAutoSavedAt'] LOOP
        IF p_recall->>v_key IS NOT NULL
           AND NOT studyu_private.nutrition_timestamp_is_valid(p_recall->>v_key) THEN
            RETURN false;
        END IF;
    END LOOP;

    FOR v_meal IN SELECT value FROM jsonb_array_elements(p_recall->'meals') LOOP
        IF jsonb_typeof(v_meal) IS DISTINCT FROM 'object'
           OR jsonb_typeof(v_meal->'id') IS DISTINCT FROM 'string'
           OR NULLIF(v_meal->>'id', '') IS NULL
           OR COALESCE(v_meal->>'mealType', '') NOT IN
               ('breakfast', 'brunch', 'lunch', 'dinner', 'snack', 'other')
           OR jsonb_typeof(v_meal->'timezone') IS DISTINCT FROM 'string'
           OR jsonb_typeof(v_meal->'isSkipped') IS DISTINCT FROM 'boolean'
           OR jsonb_typeof(v_meal->'isLabelExplicitlyUnset') NOT IN ('boolean', 'null')
           OR jsonb_typeof(v_meal->'foods') IS DISTINCT FROM 'array'
           OR v_meal->>'mealContext' NOT IN ('home', 'restaurant', 'takeout', 'vending', 'other')
           OR v_meal->>'timePrecision' NOT IN ('exact', 'approximate', 'unknown')
           OR v_meal->>'companyContext' NOT IN ('alone', 'family', 'friends', 'colleagues', 'other')
           OR v_meal->>'distractionContext' NOT IN ('none', 'tv', 'phone', 'work', 'other')
           OR (v_meal->>'timestamp' IS NOT NULL
               AND NOT studyu_private.nutrition_timestamp_is_valid(v_meal->>'timestamp')) THEN
            RETURN false;
        END IF;

        FOREACH v_key IN ARRAY ARRAY['customMealLabel', 'locationDescription', 'skipReason', 'templateId'] LOOP
            IF jsonb_typeof(v_meal->v_key) NOT IN ('string', 'null') THEN
                RETURN false;
            END IF;
        END LOOP;

        IF EXISTS (
            SELECT 1 FROM jsonb_array_elements(v_meal->'foods') AS food
            WHERE NOT public.nutrition_food_snapshot_is_valid(food)
        ) THEN
            RETURN false;
        END IF;
    END LOOP;

    RETURN true;
END;
$$;

REVOKE ALL ON FUNCTION studyu_private.nutrition_timestamp_is_valid(text),
studyu_private.nutrition_recall_is_valid(jsonb)
FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION studyu_private.save_nutrition_recall(
    p_subject_id uuid, p_completed_at timestamptz, p_intervention_id text,
    p_task_id text, p_result jsonb, p_expected_revision bigint DEFAULT null
) RETURNS public.subject_progress
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
    v_recall public.subject_progress%ROWTYPE;
    v_canonical_result jsonb;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.study_subject
        WHERE id = p_subject_id AND user_id = auth.uid() AND NOT is_deleted
    ) THEN
        RAISE EXCEPTION 'nutrition progress subject is not owned by caller'
          USING ERRCODE = '42501';
    END IF;
    IF p_completed_at IS NULL OR NOT isfinite(p_completed_at)
       OR NULLIF(p_intervention_id, '') IS NULL OR NULLIF(p_task_id, '') IS NULL
       OR p_result->>'type' IS DISTINCT FROM 'DailyRecall'
       OR NOT studyu_private.nutrition_recall_is_valid(p_result->'result')
       OR jsonb_typeof(p_result->'periodId') IS DISTINCT FROM 'string'
       OR NULLIF(p_result->>'periodId', '') IS NULL
       OR jsonb_typeof(p_result #> '{result,studyDaySnapshot}') IS DISTINCT FROM 'number'
       OR (p_result ? 'nutritionAvailabilityWriteIntent' AND
           p_result->>'nutritionAvailabilityWriteIntent' IS DISTINCT FROM 'explicit-v1')
    THEN
        RAISE EXCEPTION 'invalid nutrition recall' USING ERRCODE = '22023';
    END IF;
    v_canonical_result := p_result - 'nutritionAvailabilityWriteIntent';

    IF p_expected_revision IS NULL THEN
        PERFORM studyu_private.nutrition_lock_recall_insert(p_subject_id);
    END IF;

    SELECT * INTO v_recall FROM public.subject_progress
    WHERE subject_id = p_subject_id AND completed_at = p_completed_at
    FOR UPDATE;

    IF NOT FOUND THEN
        IF p_expected_revision IS NOT NULL THEN
            RAISE EXCEPTION 'stale nutrition recall revision' USING ERRCODE = '40001';
        END IF;
        INSERT INTO public.subject_progress (
            subject_id, completed_at, intervention_id, task_id, result_type, result
        ) VALUES (
            p_subject_id, p_completed_at, p_intervention_id, p_task_id, 'DailyRecall', p_result
        )
        RETURNING * INTO v_recall;
        RETURN v_recall;
    END IF;

    IF v_recall.result_type IS DISTINCT FROM 'DailyRecall'
       OR v_recall.task_id IS DISTINCT FROM p_task_id
       OR v_recall.intervention_id IS DISTINCT FROM p_intervention_id
       OR (v_recall.result->>'periodId' IS NOT NULL
           AND v_recall.result->>'periodId' IS DISTINCT FROM p_result->>'periodId')
    THEN
        RAISE EXCEPTION 'nutrition recall identity changed' USING ERRCODE = '40001';
    END IF;
    IF v_recall.result = v_canonical_result THEN
        RETURN v_recall;
    END IF;
    IF v_recall.nutrition_revision IS DISTINCT FROM p_expected_revision THEN
        RAISE EXCEPTION 'stale nutrition recall revision' USING ERRCODE = '40001';
    END IF;

    INSERT INTO studyu_private.nutrition_maintenance_context
    VALUES (txid_current(), p_subject_id, 'recall_revision');
    UPDATE public.subject_progress SET result = p_result
    WHERE subject_id = p_subject_id AND completed_at = p_completed_at
    RETURNING * INTO v_recall;
    DELETE FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = p_subject_id
      AND operation = 'recall_revision';
    RETURN v_recall;
END;
$$;

COMMIT;
