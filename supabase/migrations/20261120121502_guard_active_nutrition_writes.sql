BEGIN;

CREATE FUNCTION studyu_private.lock_nutrition_subject_for_write(
    p_subject_id uuid, p_allow_service_role boolean DEFAULT false
)
RETURNS boolean LANGUAGE plpgsql SET search_path = ''
AS $$
BEGIN
    -- Legacy updates already hold the progress row lock. Refuse to wait for
    -- a parent row lock so a concurrent delete can complete its cascade.
    PERFORM 1 FROM public.study_subject
    WHERE id = p_subject_id
      AND ((user_id = auth.uid() AND NOT is_deleted)
           OR (p_allow_service_role AND current_setting('role', true) = 'service_role'))
    FOR SHARE NOWAIT;
    RETURN FOUND;
END;
$$;

CREATE FUNCTION studyu_private.guard_active_nutrition_progress()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    IF NEW.result_type = 'DailyRecall'
       AND current_setting('role', true) IS DISTINCT FROM 'service_role'
       AND NOT studyu_private.lock_nutrition_subject_for_write(NEW.subject_id) THEN
        RAISE EXCEPTION 'nutrition progress subject is not owned by caller'
          USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION studyu_private.lock_nutrition_subject_for_write(uuid, boolean),
studyu_private.guard_active_nutrition_progress()
FROM PUBLIC, anon, authenticated, service_role;

CREATE TRIGGER guard_active_nutrition_progress
BEFORE INSERT OR UPDATE ON public.subject_progress
FOR EACH ROW EXECUTE FUNCTION studyu_private.guard_active_nutrition_progress();

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
        FOR SHARE OF study
        FOR NO KEY UPDATE OF subject;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'invalid study subject day advance' USING ERRCODE = '22023';
        END IF;
    ELSE
        PERFORM 1 FROM public.study_subject
        WHERE id = p_subject_id
        FOR NO KEY UPDATE;
    END IF;

    INSERT INTO studyu_private.nutrition_maintenance_context
    VALUES (txid_current(), p_subject_id, 'advance');
    PERFORM studyu_private.advance_owned_study_subject_day(p_subject_id, p_days);
    DELETE FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = p_subject_id
      AND operation = 'advance';
END;
$$;

CREATE OR REPLACE FUNCTION public.save_nutrition_recall(
    p_subject_id uuid, p_completed_at timestamptz, p_intervention_id text,
    p_task_id text, p_result jsonb, p_expected_revision bigint DEFAULT null
) RETURNS public.subject_progress
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
    v_recall public.subject_progress%ROWTYPE;
BEGIN
    IF NOT studyu_private.lock_nutrition_subject_for_write(p_subject_id) THEN
        RAISE EXCEPTION 'nutrition progress subject is not owned by caller'
          USING ERRCODE = '42501';
    END IF;
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

CREATE OR REPLACE FUNCTION public.apply_nutrition_food_mutation(
    p_subject_id uuid, p_mutation_id uuid, p_food_id uuid,
    p_expected_version_id uuid, p_snapshot jsonb,
    p_deleted boolean DEFAULT false, p_historical_target jsonb DEFAULT null,
    p_propagate_study_day integer DEFAULT null,
    p_library_visible boolean DEFAULT null,
    p_historical_entry_id text DEFAULT null
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_supported boolean;
  v_snapshot jsonb;
  v_definition record;
  v_response jsonb;
BEGIN
  IF NOT studyu_private.lock_nutrition_subject_for_write(p_subject_id, true) THEN
    RAISE EXCEPTION 'nutrition definition subject is not owned by caller' USING ERRCODE = '42501';
  END IF;
  IF p_snapshot ? 'nutritionAvailabilityWriteIntent' AND
     p_snapshot->>'nutritionAvailabilityWriteIntent' IS DISTINCT FROM 'explicit-v1' THEN
    RAISE EXCEPTION 'invalid nutrition availability write intent' USING ERRCODE = '22023';
  END IF;
  v_supported := COALESCE(p_snapshot->>'nutritionAvailabilityWriteIntent' = 'explicit-v1', false);
  v_snapshot := CASE WHEN jsonb_typeof(p_snapshot) = 'object'
    THEN p_snapshot - 'nutritionAvailabilityWriteIntent' ELSE p_snapshot END;
  PERFORM pg_advisory_xact_lock(hashtextextended(p_food_id::text, 1));
  SELECT definition.subject_id, version.snapshot INTO v_definition
  FROM public.nutrition_food_definition AS definition
  JOIN public.nutrition_food_version AS version ON version.id = definition.current_version_id
  WHERE definition.id = p_food_id;
  IF FOUND THEN
    IF v_definition.subject_id IS DISTINCT FROM p_subject_id THEN
      RAISE EXCEPTION 'nutrition definition subject is not owned by caller' USING ERRCODE = '42501';
    END IF;
    IF NOT v_supported AND studyu_private.nutrition_has_availability(v_definition.snapshot) THEN
      RAISE EXCEPTION 'nutrition availability write intent is required' USING ERRCODE = '22023';
    END IF;
  END IF;
  PERFORM studyu_private.nutrition_assert_food_availability(
    p_subject_id, v_snapshot, v_supported, p_food_id
  );
  IF v_supported THEN
    INSERT INTO studyu_private.nutrition_maintenance_context
    VALUES (txid_current(), p_subject_id, 'availability');
  END IF;
  v_response := studyu_private.apply_nutrition_food_mutation_without_availability(
    p_subject_id, p_mutation_id, p_food_id, p_expected_version_id, v_snapshot,
    p_deleted, p_historical_target, p_propagate_study_day,
    p_library_visible, p_historical_entry_id
  );
  IF v_supported THEN
    DELETE FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = p_subject_id AND operation = 'availability';
  END IF;
  RETURN v_response;
END;
$$;

COMMIT;
