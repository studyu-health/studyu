BEGIN;

CREATE FUNCTION studyu_private.lock_nutrition_subject_for_write(
    p_subject_id uuid, p_allow_service_role boolean DEFAULT false
)
RETURNS boolean LANGUAGE plpgsql SET search_path = ''
AS $$
BEGIN
    -- Lock the subject before making any nutrition changes.
    PERFORM 1 FROM public.study_subject
    WHERE id = p_subject_id
      AND ((user_id = auth.uid() AND NOT is_deleted)
           OR (p_allow_service_role AND current_setting('role', true) = 'service_role'))
    FOR SHARE NOWAIT;
    RETURN FOUND;
END;
$$;

REVOKE ALL ON FUNCTION studyu_private.lock_nutrition_subject_for_write(uuid, boolean)
FROM PUBLIC, anon, authenticated, service_role;

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
    v_response jsonb;
BEGIN
    IF NOT studyu_private.lock_nutrition_subject_for_write(p_subject_id, true) THEN
        RAISE EXCEPTION 'nutrition definition subject is not owned by caller' USING ERRCODE = '42501';
    END IF;
    IF p_propagate_study_day IS NOT NULL THEN
        -- Use the recall creation lock before taking any food version locks.
        PERFORM pg_advisory_xact_lock(hashtextextended(p_subject_id::text, 2));
    END IF;
    INSERT INTO studyu_private.nutrition_maintenance_context
    VALUES (txid_current(), p_subject_id, 'mutation');
    v_response := studyu_private.apply_nutrition_food_mutation(
        p_subject_id, p_mutation_id, p_food_id, p_expected_version_id, p_snapshot,
        p_deleted, p_historical_target, p_propagate_study_day,
        p_library_visible, p_historical_entry_id
    );
    DELETE FROM studyu_private.nutrition_maintenance_context
    WHERE transaction_id = txid_current() AND subject_id = p_subject_id AND operation = 'mutation';
    RETURN v_response;
END;
$$;

REVOKE ALL ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean, text
) TO authenticated, service_role;

COMMIT;
