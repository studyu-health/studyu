BEGIN;

SELECT plan(4);

SELECT tests.create_supabase_user(
    'nutrition_public_owner', 'nutrition_public_owner@studyu.health'
);
SELECT tests.create_supabase_user(
    'nutrition_public_subject', 'nutrition_public_subject@studyu.health'
);
SELECT tests.create_supabase_user(
    'nutrition_public_outsider', 'nutrition_public_outsider@studyu.health'
);

INSERT INTO public.study (
    id,
    contact,
    title,
    description,
    icon_name,
    status,
    questionnaire,
    eligibility_criteria,
    observations,
    interventions,
    consent,
    schedule,
    report_specification,
    results,
    user_id,
    result_sharing
) VALUES (
    '80000000-0000-4000-8000-000000000001',
    '{}'::jsonb,
    'Public nutrition access test',
    'RLS regression test',
    '',
    'running',
    '[]'::jsonb,
    '[]'::jsonb,
    '[]'::jsonb,
    '[]'::jsonb,
    '[]'::jsonb,
    '{}'::jsonb,
    '{}'::jsonb,
    '[]'::jsonb,
    tests.get_supabase_uid('nutrition_public_owner'),
    'public'
);

INSERT INTO public.study_subject (
    id, study_id, user_id, selected_intervention_ids
) VALUES (
    '80000000-0000-4000-8000-000000000002',
    '80000000-0000-4000-8000-000000000001',
    tests.get_supabase_uid('nutrition_public_subject'),
    ARRAY[]::text[]
);

SET LOCAL session_replication_role = replica;
INSERT INTO public.subject_progress (
    completed_at, subject_id, intervention_id, task_id, result_type, result
) VALUES
(
    '2026-08-31 08:00:00+00',
    '80000000-0000-4000-8000-000000000002',
    'intervention-a',
    'nutrition-task',
    'DailyRecall',
    '{"type":"DailyRecall","result":{"meals":[]}}'::jsonb
),
(
    '2026-08-31 09:00:00+00',
    '80000000-0000-4000-8000-000000000002',
    'intervention-a',
    'questionnaire-task',
    'Questionnaire',
    '{"type":"Questionnaire","result":{"answers":[]}}'::jsonb
);
SET LOCAL session_replication_role = origin;

SELECT tests.authenticate_as('nutrition_public_outsider');
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.subject_progress
        WHERE task_id = 'questionnaire-task'
    ),
    1,
    'public non-nutrition results remain visible to authenticated users'
);
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.subject_progress
        WHERE task_id = 'nutrition-task'
    ),
    0,
    'public nutrition recalls are hidden from unrelated authenticated users'
);

SELECT tests.authenticate_as('nutrition_public_subject');
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.subject_progress
        WHERE task_id = 'nutrition-task'
    ),
    1,
    'subjects can read their own nutrition recalls'
);

SELECT tests.authenticate_as('nutrition_public_owner');
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.subject_progress
        WHERE task_id = 'nutrition-task'
    ),
    1,
    'study owners can read participant nutrition recalls'
);

SELECT * FROM finish();
ROLLBACK;
