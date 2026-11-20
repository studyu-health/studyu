BEGIN;

CREATE UNIQUE INDEX subject_progress_nutrition_identity_unique_idx
ON public.subject_progress (
    subject_id, task_id, (result->>'periodId'), (result #>> '{result,studyDaySnapshot}')
)
WHERE result_type = 'DailyRecall';

COMMIT;
