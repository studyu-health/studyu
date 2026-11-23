BEGIN;

DROP POLICY IF EXISTS "Read access on progress for all if results are public"
ON public.subject_progress;

CREATE POLICY "Read access on progress for all if results are public"
ON public.subject_progress
FOR SELECT TO authenticated
USING (
    result_type <> 'DailyRecall'
    AND public.has_results_public(subject_id)
);

COMMIT;
