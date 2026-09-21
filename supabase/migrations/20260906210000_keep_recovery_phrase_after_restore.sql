BEGIN;

CREATE OR REPLACE FUNCTION public.confirm_recovered_account()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '42501';
    END IF;

    UPDATE public.user_recovery
    SET pending_password = NULL
    WHERE user_id = v_user_id AND pending_password IS NOT NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No pending recovery' USING ERRCODE = 'P0002';
    END IF;

    RETURN true;
END;
$$;

COMMENT ON FUNCTION public.confirm_recovered_account() IS
'Completes a pending recovery and keeps the recovery phrase valid.';

COMMIT;
