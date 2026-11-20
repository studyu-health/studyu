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
        operation IN ('advance', 'mutation', 'delete', 'recall_revision')
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

CREATE FUNCTION studyu_private.guard_nutrition_subject_clock()
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
  IF OLD.started_at IS NOT NULL
     AND NEW.selected_intervention_ids IS DISTINCT FROM OLD.selected_intervention_ids
     AND EXISTS (
       SELECT 1 FROM public.study
       WHERE study.id = OLD.study_id
         AND jsonb_typeof(study.observations) = 'array'
         AND study.observations @> '[{"type":"nutrition"}]'::jsonb
     ) THEN
    RAISE EXCEPTION 'nutrition intervention assignment is immutable'
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

REVOKE ALL ON FUNCTION studyu_private.guard_nutrition_subject_clock()
FROM PUBLIC, anon, authenticated, service_role;

CREATE TRIGGER guard_nutrition_subject_clock
BEFORE UPDATE ON public.study_subject
FOR EACH ROW EXECUTE FUNCTION studyu_private.guard_nutrition_subject_clock();

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

REVOKE ALL ON FUNCTION public.advance_owned_study_subject_day(uuid, integer)
FROM public, anon;
GRANT EXECUTE ON FUNCTION public.advance_owned_study_subject_day(uuid, integer)
TO authenticated, service_role;
REVOKE ALL ON FUNCTION public.delete_owned_subject_progress(uuid)
FROM public, anon;
GRANT EXECUTE ON FUNCTION public.delete_owned_subject_progress(uuid)
TO authenticated, service_role;
COMMIT;
