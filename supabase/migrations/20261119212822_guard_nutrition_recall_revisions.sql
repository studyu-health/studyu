BEGIN;

ALTER TABLE public.subject_progress
ADD COLUMN nutrition_revision bigint NOT NULL DEFAULT 0;

ALTER TABLE studyu_private.nutrition_maintenance_context
DROP CONSTRAINT nutrition_maintenance_context_operation_check;
ALTER TABLE studyu_private.nutrition_maintenance_context
ADD CONSTRAINT nutrition_maintenance_context_operation_check
CHECK (operation IN ('advance', 'mutation', 'delete', 'availability', 'recall_revision'));

CREATE INDEX subject_progress_nutrition_identity_idx
ON public.subject_progress (subject_id, task_id, (result->>'periodId'))
WHERE result_type = 'DailyRecall';

CREATE FUNCTION studyu_private.nutrition_lock_recall_insert(p_subject_id uuid)
RETURNS void LANGUAGE sql SET search_path = ''
AS $$
    SELECT pg_advisory_xact_lock(hashtextextended(p_subject_id::text, 2));
$$;

CREATE FUNCTION studyu_private.nutrition_other_recall_exists(
    p_subject_id uuid, p_task_id text, p_period_id text,
    p_day text, p_completed_at timestamptz
) RETURNS boolean LANGUAGE sql SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.subject_progress
        WHERE subject_id = p_subject_id
          AND task_id = p_task_id
          AND result_type = 'DailyRecall'
          AND result->>'periodId' IS NOT DISTINCT FROM p_period_id
          AND result #>> '{result,studyDaySnapshot}' = p_day
          AND completed_at <> p_completed_at
    );
$$;

CREATE FUNCTION studyu_private.guard_nutrition_recall_revision()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
    v_old_saved_at timestamptz;
    v_new_saved_at timestamptz;
BEGIN
    IF NEW.result_type IS DISTINCT FROM 'DailyRecall' THEN
        NEW.nutrition_revision := 0;
        RETURN NEW;
    END IF;

    IF TG_OP = 'INSERT' THEN
        PERFORM studyu_private.nutrition_lock_recall_insert(NEW.subject_id);
        IF studyu_private.nutrition_other_recall_exists(
            NEW.subject_id, NEW.task_id, NEW.result->>'periodId',
            NEW.result #>> '{result,studyDaySnapshot}', NEW.completed_at
        ) THEN
            RAISE EXCEPTION 'nutrition recall already exists' USING ERRCODE = '40001';
        END IF;
        NEW.nutrition_revision := 0;
        RETURN NEW;
    END IF;

    NEW.nutrition_revision := OLD.nutrition_revision;
    IF NEW.result IS NOT DISTINCT FROM OLD.result THEN
        RETURN NEW;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM studyu_private.nutrition_maintenance_context
        WHERE transaction_id = txid_current() AND subject_id = NEW.subject_id
          AND operation IN ('recall_revision', 'mutation')
    ) THEN
        -- Older clients send a timestamp instead of the revision they read.
        v_old_saved_at := COALESCE(
            (OLD.result #>> '{result,lastAutoSavedAt}')::timestamptz, OLD.completed_at
        );
        v_new_saved_at := (NEW.result #>> '{result,lastAutoSavedAt}')::timestamptz;
        IF v_new_saved_at IS NULL OR v_new_saved_at <= v_old_saved_at THEN
            RAISE EXCEPTION 'stale nutrition recall revision' USING ERRCODE = '40001';
        END IF;
    END IF;

    NEW.nutrition_revision := OLD.nutrition_revision + 1;
    RETURN NEW;
END;
$$;

-- Validate ownership, study day, and availability before applying revision checks.
CREATE TRIGGER zz_guard_nutrition_recall_revision
BEFORE INSERT OR UPDATE ON public.subject_progress
FOR EACH ROW EXECUTE FUNCTION studyu_private.guard_nutrition_recall_revision();

CREATE FUNCTION public.save_nutrition_recall(
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
       OR jsonb_typeof(p_result->'result') IS DISTINCT FROM 'object'
       OR jsonb_typeof(p_result->'periodId') IS DISTINCT FROM 'string'
       OR NULLIF(p_result->>'periodId', '') IS NULL
       OR jsonb_typeof(p_result #> '{result,studyDaySnapshot}') IS DISTINCT FROM 'number'
       OR jsonb_typeof(p_result #> '{result,entryCompletedAt}') IS DISTINCT FROM 'string'
       OR NOT COALESCE(isfinite((p_result #>> '{result,entryCompletedAt}')::timestamptz), false)
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

REVOKE ALL ON FUNCTION studyu_private.nutrition_lock_recall_insert(uuid),
studyu_private.nutrition_other_recall_exists(uuid, text, text, text, timestamptz),
studyu_private.guard_nutrition_recall_revision()
FROM PUBLIC, anon, authenticated, service_role;

REVOKE ALL ON FUNCTION public.save_nutrition_recall(
    uuid, timestamptz, text, text, jsonb, bigint
) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.save_nutrition_recall(
    uuid, timestamptz, text, text, jsonb, bigint
) TO authenticated;

COMMIT;
