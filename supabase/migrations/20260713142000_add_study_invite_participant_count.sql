BEGIN;

-- ============================================================================
-- Migration: Add computed participant count for study_invite
-- Date: July 13, 2026
-- ============================================================================
--
-- OVERVIEW:
-- Expose invite-code enrollment counts as a computed field so Designer can
-- sort invite codes by enrolled participants server-side.
--
-- ============================================================================

CREATE OR REPLACE FUNCTION public.study_invite_participant_count(
    invite public.study_invite
)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
  SELECT count(1)::int
  FROM public.study_subject
  WHERE study_subject.invite_code = invite.code
    AND study_subject.is_deleted = false;
$$;

REVOKE EXECUTE ON FUNCTION public.study_invite_participant_count(
    public.study_invite
)
FROM public, anon;
GRANT EXECUTE ON FUNCTION public.study_invite_participant_count(
    public.study_invite
)
TO authenticated;

COMMIT;
