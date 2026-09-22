-- ============================================================================
-- Migration: Restore Study Delete Cascade
-- Date: March 23, 2026
-- ============================================================================
--
-- OVERVIEW:
-- Restore ON DELETE CASCADE behavior for foreign keys that reference
-- public.study(id). This preserves the pre-20251022 behavior and ensures study
-- cleanup removes dependent rows from repo, study_fitbit_credentials,
-- study_invite, and study_subject.
--
-- ============================================================================

BEGIN;

ALTER TABLE ONLY public.repo
    DROP CONSTRAINT IF EXISTS "repo_studyId_fkey",
    ADD CONSTRAINT "repo_studyId_fkey"
        FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.study_fitbit_credentials
    DROP CONSTRAINT IF EXISTS "study_fitbit_credentials_studyId_fkey",
    ADD CONSTRAINT "study_fitbit_credentials_studyId_fkey"
        FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.study_invite
    DROP CONSTRAINT IF EXISTS "study_invite_studyId_fkey",
    ADD CONSTRAINT "study_invite_studyId_fkey"
        FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.study_subject
    DROP CONSTRAINT IF EXISTS "study_subject_studyId_fkey",
    ADD CONSTRAINT "study_subject_studyId_fkey"
        FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;

COMMIT;
