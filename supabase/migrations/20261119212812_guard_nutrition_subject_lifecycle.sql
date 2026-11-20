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

COMMIT;
