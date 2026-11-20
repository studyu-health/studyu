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
       OR jsonb_typeof(p_recall->'date') IS DISTINCT FROM 'string'
       OR NOT studyu_private.nutrition_timestamp_is_valid(p_recall->>'date')
       OR NOT studyu_private.nutrition_timestamp_is_valid(p_recall->>'entryCompletedAt')
       OR COALESCE(p_recall->>'recallMode', '') NOT IN ('realtimeRecord', 'yesterdayRecall')
       OR jsonb_typeof(p_recall->'meals') IS DISTINCT FROM 'array'
       OR jsonb_typeof(p_recall->'isUsualIntakeDay') NOT IN ('boolean', 'null')
       OR jsonb_typeof(p_recall->'specialOccasion') NOT IN ('string', 'null')
       OR jsonb_typeof(p_recall->'waterIntakeMl') NOT IN ('number', 'null')
       OR (p_recall->>'waterIntakeMl' IS NOT NULL
           AND p_recall->>'waterIntakeMl' !~ '^[0-9]+$') THEN
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
           OR jsonb_typeof(v_meal->'foods') IS DISTINCT FROM 'array'
           OR v_meal->>'mealContext' NOT IN ('home', 'restaurant', 'takeout', 'vending', 'other')
           OR COALESCE(v_meal->>'timePrecision', '') NOT IN ('exact', 'approximate', 'unknown')
           OR v_meal->>'companyContext' NOT IN ('alone', 'family', 'friends', 'colleagues', 'other')
           OR v_meal->>'distractionContext' NOT IN ('none', 'tv', 'phone', 'work', 'other')
           OR (v_meal->>'timestamp' IS NOT NULL
               AND NOT studyu_private.nutrition_timestamp_is_valid(v_meal->>'timestamp')) THEN
            RETURN false;
        END IF;

        IF NOT (v_meal->>'isSkipped')::boolean
           AND ((v_meal->>'timePrecision' = 'unknown') IS DISTINCT FROM
                (v_meal->>'timestamp' IS NULL)) THEN
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

CREATE FUNCTION public.save_nutrition_recall(
    p_subject_id uuid, p_completed_at timestamptz, p_intervention_id text,
    p_task_id text, p_result jsonb, p_expected_revision bigint DEFAULT null
) RETURNS public.subject_progress
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
    v_recall public.subject_progress%ROWTYPE;
    v_current_day integer;
    v_study_day integer;
    v_food jsonb;
    v_row_time timestamptz := p_completed_at;
BEGIN
    IF NOT studyu_private.lock_nutrition_subject_for_write(p_subject_id) THEN
        RAISE EXCEPTION 'nutrition progress subject is not owned by caller' USING ERRCODE = '42501';
    END IF;
    IF p_completed_at IS NULL OR NOT isfinite(p_completed_at)
       OR NULLIF(p_intervention_id, '') IS NULL OR NULLIF(p_task_id, '') IS NULL
       OR p_result->>'type' IS DISTINCT FROM 'DailyRecall'
       OR NOT studyu_private.nutrition_recall_is_valid(p_result->'result')
       OR jsonb_typeof(p_result->'periodId') IS DISTINCT FROM 'string'
       OR NULLIF(p_result->>'periodId', '') IS NULL
       OR jsonb_typeof(p_result #> '{result,studyDaySnapshot}') IS DISTINCT FROM 'number'
       OR (p_result #>> '{result,studyDaySnapshot}') !~ '^[0-9]{1,9}$'
    THEN
        RAISE EXCEPTION 'invalid nutrition recall' USING ERRCODE = '22023';
    END IF;

    v_study_day := (p_result #>> '{result,studyDaySnapshot}')::integer;
    SELECT public.nutrition_subject_current_day(subject) INTO v_current_day
    FROM public.study_subject AS subject WHERE id = p_subject_id;

    FOR v_food IN SELECT * FROM studyu_private.nutrition_recall_foods(p_result) LOOP
        PERFORM studyu_private.nutrition_assert_snapshot_owner(
            p_subject_id, v_food, p_require_version => true
        );
    END LOOP;

    IF p_expected_revision IS NULL THEN
        -- Serialize recall creation for the same subject. Existing questionnaire
        -- writes use the same primary key and can still race with an insert.
        PERFORM pg_advisory_xact_lock(hashtextextended(p_subject_id::text, 2));
        SELECT * INTO v_recall FROM public.subject_progress
        WHERE subject_id = p_subject_id AND task_id = p_task_id AND result_type = 'DailyRecall'
          AND result->>'periodId' = p_result->>'periodId'
          AND result #>> '{result,studyDaySnapshot}' = v_study_day::text
        FOR UPDATE;
        IF FOUND THEN
            IF v_recall.intervention_id = p_intervention_id AND v_recall.result = p_result THEN
                RETURN v_recall;
            END IF;
            RAISE EXCEPTION 'nutrition recall already exists' USING ERRCODE = '40001';
        END IF;

        IF v_current_day IS NULL OR v_study_day NOT IN (v_current_day - 1, v_current_day) THEN
            RAISE EXCEPTION 'nutrition recall study day is not writable' USING ERRCODE = '22023';
        END IF;

        INSERT INTO studyu_private.nutrition_maintenance_context
        VALUES (txid_current(), p_subject_id, 'recall_revision');
        LOOP
            INSERT INTO public.subject_progress (
                subject_id, completed_at, intervention_id, task_id, result_type, result
            ) VALUES (
                p_subject_id, v_row_time, p_intervention_id, p_task_id, 'DailyRecall', p_result
            )
            ON CONFLICT (completed_at, subject_id) DO NOTHING
            RETURNING * INTO v_recall;
            EXIT WHEN FOUND;
            v_row_time := v_row_time + interval '1 microsecond';
        END LOOP;
        DELETE FROM studyu_private.nutrition_maintenance_context
        WHERE transaction_id = txid_current() AND subject_id = p_subject_id AND operation = 'recall_revision';
        RETURN v_recall;
    END IF;

    SELECT * INTO v_recall FROM public.subject_progress
    WHERE subject_id = p_subject_id AND completed_at = p_completed_at
    FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'stale nutrition recall revision' USING ERRCODE = '40001';
    END IF;

    IF v_recall.result_type IS DISTINCT FROM 'DailyRecall'
       OR v_recall.task_id IS DISTINCT FROM p_task_id
       OR v_recall.intervention_id IS DISTINCT FROM p_intervention_id
       OR v_recall.result->>'periodId' IS DISTINCT FROM p_result->>'periodId'
       OR v_recall.result #>> '{result,studyDaySnapshot}' IS DISTINCT FROM v_study_day::text
       OR v_recall.result #>> '{result,id}' IS DISTINCT FROM p_result #>> '{result,id}'
    THEN
        RAISE EXCEPTION 'nutrition recall identity changed' USING ERRCODE = '40001';
    END IF;
    IF v_recall.result = p_result THEN
        RETURN v_recall;
    END IF;
    IF v_recall.nutrition_revision IS DISTINCT FROM p_expected_revision THEN
        RAISE EXCEPTION 'stale nutrition recall revision' USING ERRCODE = '40001';
    END IF;
    IF v_current_day IS NULL OR v_study_day NOT IN (v_current_day - 1, v_current_day) THEN
        RAISE EXCEPTION 'nutrition recall study day is not writable' USING ERRCODE = '22023';
    END IF;

    INSERT INTO studyu_private.nutrition_maintenance_context
    VALUES (txid_current(), p_subject_id, 'recall_revision');
    UPDATE public.subject_progress SET result = p_result
    WHERE subject_id = p_subject_id AND completed_at = p_completed_at
    RETURNING * INTO v_recall;
    DELETE FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = p_subject_id AND operation = 'recall_revision';
    RETURN v_recall;
END;
$$;

REVOKE ALL ON FUNCTION public.save_nutrition_recall(
    uuid, timestamptz, text, text, jsonb, bigint
) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.save_nutrition_recall(
    uuid, timestamptz, text, text, jsonb, bigint
) TO authenticated;

COMMIT;
