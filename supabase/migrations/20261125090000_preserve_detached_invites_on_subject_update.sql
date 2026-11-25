BEGIN;

CREATE FUNCTION public.preserve_detached_subject_invite()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    -- Open clients can resend a deleted invite code from their cached subject.
    -- Keep detached participation detached without rejecting the other updates.
    NEW.invite_code := NULL;
    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.preserve_detached_subject_invite()
FROM PUBLIC, anon, authenticated;

CREATE TRIGGER preserve_detached_subject_invite
BEFORE UPDATE OF invite_code ON public.study_subject
FOR EACH ROW
WHEN (OLD.invite_code IS NULL AND NEW.invite_code IS NOT NULL)
EXECUTE FUNCTION public.preserve_detached_subject_invite();

COMMIT;
