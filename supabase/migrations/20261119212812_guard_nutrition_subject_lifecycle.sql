BEGIN;

CREATE OR REPLACE FUNCTION public.advance_owned_study_subject_day(
    p_subject_id uuid, p_days integer
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    IF p_subject_id IS NULL OR p_days IS DISTINCT FROM 1 THEN
        RAISE EXCEPTION 'invalid study subject day advance' USING ERRCODE = '22023';
    END IF;

    IF current_setting('role', true) IS DISTINCT FROM 'service_role' THEN
        PERFORM 1
        FROM public.study_subject AS subject
        JOIN public.study AS study ON study.id = subject.study_id
        WHERE subject.id = p_subject_id
          AND subject.user_id = auth.uid()
          AND NOT subject.is_deleted
          AND study.status = 'draft'
          AND public.can_edit(auth.uid(), study)
        FOR SHARE OF study;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'invalid study subject day advance' USING ERRCODE = '22023';
        END IF;
    END IF;

    INSERT INTO studyu_private.nutrition_maintenance_context
    VALUES (txid_current(), p_subject_id, 'advance');
    PERFORM studyu_private.advance_owned_study_subject_day(p_subject_id, p_days);
    DELETE FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = p_subject_id
      AND operation = 'advance';
END;
$$;

CREATE OR REPLACE FUNCTION public.guard_nutrition_progress_mutation()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
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

    -- A foreign-key cascade runs after PostgreSQL deletes the subject.
    IF TG_OP = 'DELETE' AND NOT EXISTS (
        SELECT 1 FROM public.study_subject WHERE id = OLD.subject_id
    ) THEN
        RETURN OLD;
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
            v_old_day := COALESCE(
                (OLD.result #>> '{result,studyDaySnapshot}')::integer,
                (OLD.completed_at AT TIME ZONE 'UTC')::date
                  - (v_subject.started_at AT TIME ZONE 'UTC')::date
            );
        END IF;
        IF TG_OP <> 'DELETE' AND NEW.result_type = 'DailyRecall' THEN
            v_new_day := (NEW.result #>> '{result,studyDaySnapshot}')::integer;
        END IF;
    EXCEPTION WHEN invalid_text_representation OR numeric_value_out_of_range THEN
        RAISE EXCEPTION 'invalid nutrition progress study day' USING ERRCODE = '22023';
    END;

    IF TG_OP = 'INSERT' AND NEW.result_type = 'DailyRecall' THEN
        IF v_new_day IS NULL OR v_new_day < 0
            OR v_new_day NOT IN (v_current_day - 1, v_current_day)
            OR v_current_day IS NULL THEN
            RAISE EXCEPTION 'nutrition recall study day is not writable' USING ERRCODE = '22023';
        END IF;
    ELSIF TG_OP = 'UPDATE' AND
          (OLD.result_type = 'DailyRecall' OR NEW.result_type = 'DailyRecall') THEN
        IF OLD.result_type IS DISTINCT FROM 'DailyRecall' OR
           NEW.result_type IS DISTINCT FROM 'DailyRecall' OR
           NEW.subject_id IS DISTINCT FROM OLD.subject_id OR
           NEW.completed_at IS DISTINCT FROM OLD.completed_at OR
           NEW.task_id IS DISTINCT FROM OLD.task_id OR
           NEW.intervention_id IS DISTINCT FROM OLD.intervention_id OR
           (OLD.result->>'periodId' IS NOT NULL AND
            NEW.result->>'periodId' IS DISTINCT FROM OLD.result->>'periodId') OR
           v_old_day IS NULL OR
           v_old_day < 0 OR
           v_new_day IS DISTINCT FROM v_old_day OR
           v_old_day NOT IN (v_current_day - 1, v_current_day) THEN
            RAISE EXCEPTION 'nutrition recall study day is not writable' USING ERRCODE = '22023';
        END IF;
    ELSIF TG_OP = 'DELETE' AND OLD.result_type = 'DailyRecall' AND
          (v_old_day IS NULL OR v_old_day < 0 OR
           v_old_day NOT IN (v_current_day - 1, v_current_day)) THEN
        RAISE EXCEPTION 'nutrition recall study day is not writable' USING ERRCODE = '22023';
    END IF;

    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$;

-- The historical food RPC matches the stored day to the selected occurrence.
-- Fill this field for recalls from app versions that stored only completed_at.
INSERT INTO studyu_private.nutrition_maintenance_context
SELECT DISTINCT txid_current(), progress.subject_id, operation
FROM public.subject_progress AS progress
JOIN public.study_subject AS subject ON subject.id = progress.subject_id
CROSS JOIN (VALUES ('mutation'), ('availability')) AS intent(operation)
WHERE progress.result_type = 'DailyRecall'
  AND jsonb_typeof(progress.result->'result') = 'object'
  AND progress.result #>> '{result,studyDaySnapshot}' IS NULL
  AND subject.started_at IS NOT NULL;

UPDATE public.subject_progress AS progress
SET result = jsonb_set(
    progress.result, '{result,studyDaySnapshot}',
    to_jsonb(
        (progress.completed_at AT TIME ZONE 'UTC')::date
          - (subject.started_at AT TIME ZONE 'UTC')::date
    )
)
FROM public.study_subject AS subject
WHERE subject.id = progress.subject_id
  AND progress.result_type = 'DailyRecall'
  AND jsonb_typeof(progress.result->'result') = 'object'
  AND progress.result #>> '{result,studyDaySnapshot}' IS NULL
  AND subject.started_at IS NOT NULL;

DELETE FROM studyu_private.nutrition_maintenance_context
WHERE transaction_id = txid_current() AND operation IN ('mutation', 'availability');

COMMIT;
