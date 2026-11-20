BEGIN;

-- Designer keeps the reserved prefix when it duplicates a birth date question.
ALTER POLICY "Read access on progress for all if results are public"
ON public.subject_progress
USING (
    result_type <> 'DailyRecall'
    AND NOT jsonb_path_exists(
        result,
        '$.result[*].question ? (@ == "dhq_dob" || @ starts with "dhq_dob-")'
    )
    AND public.has_results_public(subject_id)
);

COMMIT;
