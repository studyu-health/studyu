BEGIN;

CREATE TABLE studyu_private.nutrition_recall_revision_required (
    completed_at timestamptz NOT NULL,
    subject_id uuid NOT NULL,
    PRIMARY KEY (completed_at, subject_id),
    FOREIGN KEY (completed_at, subject_id)
        REFERENCES public.subject_progress (completed_at, subject_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
ALTER TABLE studyu_private.nutrition_recall_revision_required ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE studyu_private.nutrition_recall_revision_required
FROM PUBLIC, anon, authenticated, service_role;

ALTER FUNCTION public.save_nutrition_recall(
    uuid, timestamptz, text, text, jsonb, bigint
) SET SCHEMA studyu_private;
REVOKE ALL ON FUNCTION studyu_private.save_nutrition_recall(
    uuid, timestamptz, text, text, jsonb, bigint
) FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION public.save_nutrition_recall(
    p_subject_id uuid, p_completed_at timestamptz, p_intervention_id text,
    p_task_id text, p_result jsonb, p_expected_revision bigint DEFAULT null
) RETURNS public.subject_progress
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
    v_recall public.subject_progress%ROWTYPE;
BEGIN
    v_recall := studyu_private.save_nutrition_recall(
        p_subject_id, p_completed_at, p_intervention_id,
        p_task_id, p_result, p_expected_revision
    );

    INSERT INTO studyu_private.nutrition_recall_revision_required (completed_at, subject_id)
    VALUES (v_recall.completed_at, v_recall.subject_id)
    ON CONFLICT DO NOTHING;

    RETURN v_recall;
END;
$$;

REVOKE ALL ON FUNCTION public.save_nutrition_recall(
    uuid, timestamptz, text, text, jsonb, bigint
) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.save_nutrition_recall(
    uuid, timestamptz, text, text, jsonb, bigint
) TO authenticated;

CREATE FUNCTION studyu_private.guard_nutrition_recall_revision_required()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    IF OLD.result_type IS DISTINCT FROM 'DailyRecall'
       OR NEW.result IS NOT DISTINCT FROM OLD.result THEN
        RETURN NEW;
    END IF;

    IF EXISTS (
        SELECT 1 FROM studyu_private.nutrition_maintenance_context
        WHERE transaction_id = txid_current() AND subject_id = OLD.subject_id
          AND operation = 'mutation'
    ) THEN
        INSERT INTO studyu_private.nutrition_recall_revision_required (completed_at, subject_id)
        VALUES (OLD.completed_at, OLD.subject_id)
        ON CONFLICT DO NOTHING;
    ELSIF EXISTS (
        SELECT 1 FROM studyu_private.nutrition_recall_revision_required
        WHERE completed_at = OLD.completed_at AND subject_id = OLD.subject_id
    ) AND NOT EXISTS (
        SELECT 1 FROM studyu_private.nutrition_maintenance_context
        WHERE transaction_id = txid_current() AND subject_id = OLD.subject_id
          AND operation = 'recall_revision'
    ) THEN
        RAISE EXCEPTION 'nutrition recall update requires a revision' USING ERRCODE = '40001';
    END IF;

    RETURN NEW;
END;
$$;

-- The availability trigger removes transient metadata before this check.
CREATE TRIGGER zy_guard_nutrition_recall_revision_required
BEFORE UPDATE ON public.subject_progress
FOR EACH ROW EXECUTE FUNCTION studyu_private.guard_nutrition_recall_revision_required();

REVOKE ALL ON FUNCTION studyu_private.guard_nutrition_recall_revision_required()
FROM PUBLIC, anon, authenticated, service_role;

COMMIT;
