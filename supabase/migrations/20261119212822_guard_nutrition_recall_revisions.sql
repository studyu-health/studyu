BEGIN;

ALTER TABLE public.subject_progress
ADD COLUMN nutrition_revision bigint NOT NULL DEFAULT 0;

CREATE FUNCTION studyu_private.guard_nutrition_progress_mutation()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
    v_subject_id uuid := CASE WHEN TG_OP = 'DELETE' THEN OLD.subject_id ELSE NEW.subject_id END;
    v_operation text;
BEGIN
    IF TG_OP <> 'DELETE'
       AND (NEW.result_type = 'DailyRecall' OR NEW.result->>'type' = 'DailyRecall')
       AND (NEW.result_type IS DISTINCT FROM 'DailyRecall'
            OR NEW.result->>'type' IS DISTINCT FROM 'DailyRecall') THEN
        RAISE EXCEPTION 'nutrition recall result types must match' USING ERRCODE = '22023';
    END IF;

    IF (TG_OP = 'INSERT' AND NEW.result_type IS DISTINCT FROM 'DailyRecall')
       OR (TG_OP = 'UPDATE' AND OLD.result_type IS DISTINCT FROM 'DailyRecall'
           AND NEW.result_type IS DISTINCT FROM 'DailyRecall') THEN
        NEW.nutrition_revision := 0;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' AND OLD.result_type IS DISTINCT FROM 'DailyRecall' THEN
        RETURN OLD;
    END IF;

    -- The subject is already absent during a foreign-key cascade.
    IF TG_OP = 'DELETE' AND NOT EXISTS (
        SELECT 1 FROM public.study_subject WHERE id = OLD.subject_id
    ) THEN
        RETURN OLD;
    END IF;

    SELECT operation INTO v_operation
    FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = v_subject_id;

    IF TG_OP = 'DELETE' AND v_operation = 'delete' THEN
        RETURN OLD;
    END IF;
    IF TG_OP = 'INSERT' AND v_operation = 'recall_revision' THEN
        NEW.nutrition_revision := 0;
        RETURN NEW;
    END IF;
    IF TG_OP = 'UPDATE' AND v_operation IN ('advance', 'mutation', 'recall_revision') THEN
        NEW.nutrition_revision := OLD.nutrition_revision
            + CASE WHEN NEW.result IS DISTINCT FROM OLD.result THEN 1 ELSE 0 END;
        RETURN NEW;
    END IF;
    RAISE EXCEPTION 'direct nutrition recall writes are not allowed' USING ERRCODE = '42501';
END;
$$;

REVOKE ALL ON FUNCTION studyu_private.guard_nutrition_progress_mutation()
FROM PUBLIC, anon, authenticated, service_role;

CREATE TRIGGER guard_nutrition_progress_mutation
BEFORE INSERT OR UPDATE OR DELETE ON public.subject_progress
FOR EACH ROW EXECUTE FUNCTION studyu_private.guard_nutrition_progress_mutation();

COMMIT;
