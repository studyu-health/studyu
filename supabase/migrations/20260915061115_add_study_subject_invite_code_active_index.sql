CREATE INDEX CONCURRENTLY IF NOT EXISTS study_subject_invite_code_active_idx
ON public.study_subject (invite_code)
WHERE is_deleted = false;
