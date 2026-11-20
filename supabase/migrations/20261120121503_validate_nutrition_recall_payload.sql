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

CREATE FUNCTION studyu_private.nutrition_intervention_for_day(
    p_subject_id uuid, p_schedule jsonb, p_selected text[], p_study_day integer
) RETURNS text LANGUAGE plpgsql IMMUTABLE SET search_path = ''
AS $$
DECLARE
    v_phase_duration integer := (p_schedule->>'phaseDuration')::integer;
    v_cycle_count integer := (p_schedule->>'numberOfCycles')::integer;
    v_include_baseline boolean := (p_schedule->>'includeBaseline')::boolean;
    v_sequence text := p_schedule->>'sequence';
    v_custom_sequence text := upper(COALESCE(p_schedule->>'sequenceCustom', 'ABAB'));
    v_phase integer;
    v_cycle integer;
    v_position integer;
    v_phases_per_cycle integer;
BEGIN
    IF v_phase_duration IS NULL OR v_phase_duration <= 0 OR v_cycle_count IS NULL
       OR v_cycle_count < 0 OR v_include_baseline IS NULL OR p_study_day < 0 THEN
        RETURN NULL;
    END IF;
    v_phase := p_study_day / v_phase_duration;
    IF v_include_baseline THEN
        IF v_phase = 0 THEN RETURN '__baseline'; END IF;
        v_phase := v_phase - 1;
    END IF;

    v_phases_per_cycle := CASE WHEN v_sequence = 'customized'
        THEN length(v_custom_sequence) ELSE 2 END;
    IF v_phases_per_cycle = 0 THEN RETURN NULL; END IF;
    v_cycle := v_phase / v_phases_per_cycle;
    IF v_cycle >= v_cycle_count THEN RETURN NULL; END IF;
    v_position := v_phase % v_phases_per_cycle;

    CASE v_sequence
        WHEN 'alternating' THEN
            RETURN p_selected[v_position + 1];
        WHEN 'counterBalanced' THEN
            RETURN p_selected[1 + (v_position + (v_cycle + 1) / 2) % 2];
        WHEN 'randomized' THEN
            IF v_cycle > 0 AND get_byte(sha256(convert_to(
                p_subject_id::text || ':' || v_cycle::text, 'UTF8'
            )), 0) % 2 = 1 THEN
                v_position := 1 - v_position;
            END IF;
            RETURN p_selected[v_position + 1];
        WHEN 'customized' THEN
            RETURN CASE substr(v_custom_sequence, v_position + 1, 1)
                WHEN 'A' THEN p_selected[1] WHEN 'B' THEN p_selected[2] END;
        ELSE
            RETURN NULL;
    END CASE;
END;
$$;

CREATE FUNCTION studyu_private.nutrition_task_is_scheduled(
    p_rule jsonb, p_schedule jsonb, p_study_day integer
) RETURNS boolean LANGUAGE plpgsql IMMUTABLE SET search_path = ''
AS $$
DECLARE
    v_interval integer;
    v_start integer;
    v_day_of_cycle integer;
    v_baseline_days integer;
    v_cycle_days integer;
    v_offset integer;
    v_cycle integer;
BEGIN
    IF p_rule IS NULL OR p_rule = 'null'::jsonb THEN RETURN true; END IF;

    CASE p_rule->>'type'
        WHEN 'specificDays' THEN
            RETURN COALESCE(p_rule->'specificDays' @> jsonb_build_array(p_study_day), false);
        WHEN 'everyNDays' THEN
            v_interval := COALESCE((p_rule->>'intervalDays')::integer, 1);
            v_start := COALESCE((p_rule->>'startDayOffset')::integer, 0);
            RETURN v_interval > 0 AND p_study_day >= v_start
                AND (p_study_day - v_start) % NULLIF(v_interval, 0) = 0;
        WHEN 'perCycle' THEN
            v_day_of_cycle := COALESCE((p_rule->>'dayOfCycle')::integer, 0);
            v_baseline_days := CASE WHEN (p_schedule->>'includeBaseline')::boolean
                THEN (p_schedule->>'phaseDuration')::integer ELSE 0 END;
            IF COALESCE((p_rule->>'includeBaseline')::boolean, false)
               AND p_study_day = v_day_of_cycle AND p_study_day < v_baseline_days THEN
                RETURN true;
            END IF;
            v_cycle_days := (p_schedule->>'phaseDuration')::integer *
                CASE WHEN p_schedule->>'sequence' = 'customized'
                    THEN length(COALESCE(p_schedule->>'sequenceCustom', 'ABAB')) ELSE 2 END;
            v_offset := p_study_day - v_baseline_days - v_day_of_cycle;
            IF v_cycle_days <= 0 OR v_offset < 0 OR v_offset % v_cycle_days <> 0 THEN
                RETURN false;
            END IF;
            v_cycle := v_offset / v_cycle_days;
            RETURN v_cycle < (p_schedule->>'numberOfCycles')::integer
                AND (COALESCE(p_rule->'targetCycles', 'null'::jsonb) IN ('null', '[]')
                    OR p_rule->'targetCycles' @> jsonb_build_array(v_cycle));
        ELSE
            RETURN false;
    END CASE;
END;
$$;

REVOKE ALL ON FUNCTION studyu_private.nutrition_intervention_for_day(uuid, jsonb, text[], integer),
studyu_private.nutrition_task_is_scheduled(jsonb, jsonb, integer)
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
    v_subject public.study_subject%ROWTYPE;
    v_study public.study%ROWTYPE;
    v_assigned_intervention text;
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
    SELECT * INTO v_subject FROM public.study_subject WHERE id = p_subject_id;
    SELECT * INTO v_study FROM public.study WHERE id = v_subject.study_id;
    v_current_day := public.nutrition_subject_current_day(v_subject);

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

        IF ((p_result #>> '{result,date}')::timestamptz AT TIME ZONE 'UTC')::date
           IS DISTINCT FROM (v_subject.started_at AT TIME ZONE 'UTC')::date + v_study_day THEN
            RAISE EXCEPTION 'nutrition recall date does not match its study day' USING ERRCODE = '22023';
        END IF;

        v_assigned_intervention := studyu_private.nutrition_intervention_for_day(
            p_subject_id, v_study.schedule, v_subject.selected_intervention_ids, v_study_day
        );
        IF v_assigned_intervention IS DISTINCT FROM p_intervention_id
           OR (v_assigned_intervention <> '__baseline' AND NOT EXISTS (
               SELECT 1 FROM jsonb_array_elements(v_study.interventions) AS intervention
               WHERE intervention->>'id' = v_assigned_intervention
           ))
           OR NOT EXISTS (
               SELECT 1 FROM jsonb_array_elements(v_study.observations) AS task
               CROSS JOIN LATERAL jsonb_array_elements(task #> '{schedule,completionPeriods}') AS period
               WHERE task->>'id' = p_task_id AND task->>'type' = 'nutrition'
                 AND period->>'id' = p_result->>'periodId'
                 AND studyu_private.nutrition_task_is_scheduled(task->'scheduleRule', v_study.schedule, v_study_day)
           ) THEN
            RAISE EXCEPTION 'nutrition recall is not assigned to this study day' USING ERRCODE = '22023';
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
       OR v_recall.result #>> '{result,date}' IS DISTINCT FROM p_result #>> '{result,date}'
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
