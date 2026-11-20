BEGIN;

SELECT plan(10);

SELECT tests.create_supabase_user(
    'nutrition_public_owner', 'nutrition_public_owner@studyu.health'
);
SELECT tests.create_supabase_user(
    'nutrition_public_subject', 'nutrition_public_subject@studyu.health'
);
SELECT tests.create_supabase_user(
    'nutrition_public_outsider', 'nutrition_public_outsider@studyu.health'
);
SELECT tests.create_supabase_user(
    'nutrition_public_editor', 'nutrition_public_editor@studyu.health'
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
    result_sharing,
    collaborator_emails
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
    'public',
    ARRAY['nutrition_public_editor@studyu.health']
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
    'QuestionnaireState',
    '{"type":"QuestionnaireState","result":[]}'::jsonb
),
(
    '2026-08-31 10:00:00+00',
    '80000000-0000-4000-8000-000000000002',
    'intervention-a',
    'renamed-diet-survey-task',
    'QuestionnaireState',
    '{
        "type":"QuestionnaireState",
        "result":[
            {"question":"dhq_sex","timestamp":"2026-08-31T10:00:00Z","response":"other"},
            {"question":"dhq_dob","timestamp":"2026-08-31T10:00:00Z",
                "response":"1990-01-01T00:00:00Z","responseType":"DateTime"}
        ]
    }'::jsonb
),
(
    '2026-08-31 11:00:00+00',
    '80000000-0000-4000-8000-000000000002',
    'intervention-a',
    'duplicated-diet-survey-task',
    'QuestionnaireState',
    '{
        "type":"QuestionnaireState",
        "result":[
            {"question":"dhq_dob-12345678-1234-4234-8234-123456789abc",
                "timestamp":"2026-08-31T11:00:00Z","response":"1990-01-01T00:00:00Z",
                "responseType":"DateTime"}
        ]
    }'::jsonb
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

SELECT is(
    (SELECT count(*)::integer FROM public.subject_progress
     WHERE task_id = 'renamed-diet-survey-task'),
    0,
    'unrelated users cannot read saved DHQ birth dates through public results'
);
SELECT is(
    (SELECT count(*)::integer FROM public.study_progress_export
     WHERE task_id = 'renamed-diet-survey-task'),
    0,
    'the export view applies the same birth date restriction'
);

SELECT is(
    (SELECT count(*)::integer FROM public.study_progress_export
     WHERE task_id = 'duplicated-diet-survey-task'),
    0,
    'the export view excludes cloned DHQ birth dates'
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

SELECT is(
    (SELECT count(*)::integer FROM public.subject_progress
     WHERE task_id = 'renamed-diet-survey-task'),
    1,
    'participants can read their own DHQ result'
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

SELECT is(
    (SELECT count(*)::integer FROM public.study_progress_export
     WHERE task_id = 'renamed-diet-survey-task'),
    1,
    'study owners can export their participant DHQ result'
);

SELECT tests.authenticate_as('nutrition_public_editor');
SELECT is(
    (SELECT count(*)::integer FROM public.study_progress_export
     WHERE task_id IN ('renamed-diet-survey-task', 'duplicated-diet-survey-task')),
    2,
    'study collaborators can export original and cloned DHQ results'
);

SELECT * FROM finish();
ROLLBACK;
