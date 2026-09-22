BEGIN;

-- ============================================================================
-- Migration: Fix invite and public study deep-link permissions
-- Date: July 6, 2026
-- ============================================================================
--
-- OVERVIEW:
-- Allow unauthenticated deep-link validation for invite codes and public study
-- links. The app needs to resolve invite links and open-study links before the
-- participant has signed in or completed onboarding.
--
-- ============================================================================

-- Normalize invite-code lookup so mobile keyboard capitalization and copied
-- whitespace do not make otherwise valid invite links fail.
CREATE OR REPLACE FUNCTION public.get_study_record_from_invite(invite_code text)
RETURNS public.study
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT * FROM public.study
  WHERE study.id = (
    SELECT study_invite.study_id
    FROM public.study_invite
    WHERE lower(trim(invite_code)) = lower(trim(study_invite.code))
  );
$$;

-- Deep-link validation calls this RPC before authentication. Keep PUBLIC
-- revoked, then grant only the roles that need the API surface.
REVOKE EXECUTE ON FUNCTION public.get_study_record_from_invite(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(text) TO authenticated;

-- Public /study/<id> deep links need anonymous SELECT access for open studies.
-- RLS still limits rows to running/closed studies with public visibility.
DROP POLICY IF EXISTS "Study visibility" ON public.study;

CREATE POLICY "Study visibility" ON public.study
FOR SELECT
USING (
  (
    status = 'running'::public.study_status
    OR status = 'closed'::public.study_status
  )
  AND (
    registry_published = true
    OR participation = 'open'::public.participation
    OR result_sharing = 'public'::public.result_sharing
  )
);

COMMIT;
