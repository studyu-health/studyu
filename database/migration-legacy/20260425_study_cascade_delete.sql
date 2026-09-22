--
-- Add ON DELETE CASCADE to all FK constraints referencing study(id)
-- so that deleting a study automatically removes all dependent records.
--

ALTER TABLE public.repo
  DROP CONSTRAINT "repo_studyId_fkey",
  ADD CONSTRAINT "repo_studyId_fkey"
    FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;

ALTER TABLE public.study_fitbit_credentials
  DROP CONSTRAINT "study_fitbit_credentials_studyId_fkey",
  ADD CONSTRAINT "study_fitbit_credentials_studyId_fkey"
    FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;

ALTER TABLE public.study_invite
  DROP CONSTRAINT "study_invite_studyId_fkey",
  ADD CONSTRAINT "study_invite_studyId_fkey"
    FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;

ALTER TABLE public.study_subject
  DROP CONSTRAINT "study_subject_studyId_fkey",
  ADD CONSTRAINT "study_subject_studyId_fkey"
    FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;
