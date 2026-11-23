BEGIN;

-- Inspect the saved answers so a change to the survey title or task ID does not
-- change the privacy of the birth date.
ALTER POLICY "Read access on progress for all if results are public"
ON public.subject_progress
USING (
    result_type <> 'DailyRecall'
    AND NOT (result @> '{"result":[{"question":"dhq_dob"}]}'::jsonb)
    AND public.has_results_public(subject_id)
);

COMMIT;
