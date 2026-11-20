BEGIN;

SELECT plan(30);

SELECT tests.create_supabase_user('nutrition_revision_owner', 'nutrition_revision_owner@studyu.health');
SELECT tests.create_supabase_user('nutrition_revision_other', 'nutrition_revision_other@studyu.health');

INSERT INTO public.study_subject (
    id, study_id, user_id, started_at, selected_intervention_ids
) VALUES (
    'a7100000-0000-4000-8000-000000000001',
    '22222222-2222-4222-8222-222222222222',
    tests.get_supabase_uid('nutrition_revision_owner'),
    now() - interval '3 days',
    ARRAY[]::text[]
);

CREATE FUNCTION tests.revision_test_result(
    p_water integer DEFAULT 250, p_saved_at timestamptz DEFAULT now()
) RETURNS jsonb LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
        'type', 'DailyRecall', 'periodId', 'period-a',
        'result', jsonb_build_object(
            'id', 'nutrition-revision-fixture', 'date', now(), 'recallMode', 'realtimeRecord',
            'studyDaySnapshot', 3, 'entryCompletedAt', now(), 'lastAutoSavedAt', p_saved_at,
            'meals', '[]'::jsonb, 'waterIntakeMl', p_water
        )
    );
$$;
CREATE FUNCTION tests.revision_test_save(
    p_result jsonb, p_expected_revision bigint DEFAULT null,
    p_completed_at timestamptz DEFAULT now()
) RETURNS public.subject_progress LANGUAGE sql AS $$
    SELECT public.save_nutrition_recall(
        'a7100000-0000-4000-8000-000000000001', p_completed_at,
        'intervention-a', 'nutrition-task', p_result, p_expected_revision
    );
$$;

SELECT tests.authenticate_as('nutrition_revision_owner');
SELECT throws_ok(
    $$SELECT tests.revision_test_save(tests.revision_test_result() #- '{result,id}')$$,
    '22023', 'invalid nutrition recall', 'save rejects a missing recall ID'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(), '{result,date}', '"tomorrow"')
    )$$,
    '22023', 'invalid nutrition recall', 'save rejects non-ISO recall dates'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(), '{result,recallMode}', '"other"')
    )$$,
    '22023', 'invalid nutrition recall', 'save rejects unknown recall modes'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(), '{result,meals}', '{}')
    )$$,
    '22023', 'invalid nutrition recall', 'save rejects a non-array meal list'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(), '{result,meals}', '[{}]')
    )$$,
    '22023', 'invalid nutrition recall', 'save rejects a meal missing required fields'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(
            tests.revision_test_result(), '{result,meals}',
            '[{"id":"meal","mealType":"breakfast","timezone":"UTC","timePrecision":"unknown","isSkipped":false,"foods":[{}]}]'
        )
    )$$,
    '22023', 'invalid nutrition recall', 'save rejects an invalid nested food snapshot'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(), '{result,studyDaySnapshot}', '3.1')
    )$$,
    '22023', 'invalid nutrition recall', 'save requires an integer study day'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(tests.revision_test_result() #- '{result,entryCompletedAt}')$$,
    '22023', 'invalid nutrition recall', 'save rejects incomplete recalls'
);
SELECT is(
    (tests.revision_test_save(tests.revision_test_result())).nutrition_revision,
    0::bigint, 'new recall returns its initial revision'
);
SELECT is(
    (tests.revision_test_save(tests.revision_test_result())).nutrition_revision,
    0::bigint, 'identical retry keeps the revision'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(tests.revision_test_result(100), null, now() + interval '1 second')$$,
    '40001', 'nutrition recall already exists',
    'the same task, period and study day cannot produce a second recall'
);
SELECT is(
    (tests.revision_test_save(tests.revision_test_result(350), 0)).nutrition_revision,
    1::bigint, 'a matching revision can change a recall'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(tests.revision_test_result(450, now() + interval '1 second'), 0)$$,
    '40001', 'stale nutrition recall revision',
    'a stale revision cannot overwrite a recall even with a later timestamp'
);
SELECT throws_ok(
    $$UPDATE public.subject_progress
      SET result = tests.revision_test_result(450)
      WHERE subject_id = 'a7100000-0000-4000-8000-000000000001' AND completed_at = now()$$,
    '42501', 'direct nutrition recall writes are not allowed',
    'a direct write cannot overwrite a recall'
);
SELECT is(
    (SELECT result #>> '{result,waterIntakeMl}' FROM public.subject_progress
     WHERE subject_id = 'a7100000-0000-4000-8000-000000000001' AND completed_at = now()),
    '350', 'failed writes preserve the current recall'
);
SELECT throws_ok(
    $$INSERT INTO public.subject_progress (
        subject_id, completed_at, intervention_id, task_id, result_type, result
    ) VALUES (
        'a7100000-0000-4000-8000-000000000001', now() + interval '1 hour',
        'intervention-a', 'nutrition-task', 'DailyRecall', tests.revision_test_result()
    )$$,
    '42501', 'direct nutrition recall writes are not allowed',
    'a direct write cannot insert a recall'
);
SELECT throws_ok(
    $$INSERT INTO public.subject_progress (
        subject_id, completed_at, intervention_id, task_id, result_type, result
    ) VALUES (
        'a7100000-0000-4000-8000-000000000001', now() + interval '1 hour',
        'intervention-a', 'nutrition-task', 'QuestionnaireState', tests.revision_test_result()
    )$$,
    '22023', 'nutrition recall result types must match',
    'the row and payload must both identify a nutrition recall'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(550), '{periodId}', '"other-period"'), 1
    )$$,
    '40001', 'nutrition recall identity changed',
    'an update cannot change the period'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(550), '{result,studyDaySnapshot}', '2'), 1
    )$$,
    '40001', 'nutrition recall identity changed',
    'an update cannot change the study day'
);
SELECT lives_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(550), '{result,studyDaySnapshot}', '2'),
        null, now() - interval '1 day'
    )$$,
    'the same period can have a recall on a different writable study day'
);
SELECT lives_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(550), '{periodId}', '"other-period"'),
        null, now() + interval '1 hour'
    )$$,
    'the same study day can have a recall for a different period'
);
SELECT throws_ok(
    $$SELECT public.advance_owned_study_subject_day('a7100000-0000-4000-8000-000000000001', 1)$$,
    '22023', 'invalid study subject day advance',
    'running-study participant cannot advance the authoritative clock'
);

SELECT lives_ok(
    $$UPDATE public.study_subject SET is_deleted = true
      WHERE id = 'a7100000-0000-4000-8000-000000000001'$$,
    'a participant can withdraw while retaining their progress'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(tests.revision_test_result(550), 1)$$,
    '42501', 'nutrition progress subject is not owned by caller',
    'the recall RPC rejects a withdrawn participant'
);
SELECT throws_ok(
    $$INSERT INTO public.subject_progress (
        subject_id, completed_at, intervention_id, task_id, result_type, result
    ) VALUES (
        'a7100000-0000-4000-8000-000000000001', now() + interval '2 hours',
        'intervention-a', 'legacy-task-2', 'DailyRecall', tests.revision_test_result()
    )$$,
    '42501', 'direct nutrition recall writes are not allowed',
    'a direct write cannot add progress after withdrawal'
);
SELECT throws_ok(
    $$UPDATE public.subject_progress
      SET result = tests.revision_test_result(500)
      WHERE subject_id = 'a7100000-0000-4000-8000-000000000001' AND completed_at = now()$$,
    '42501', 'direct nutrition recall writes are not allowed',
    'a direct write cannot edit progress after withdrawal'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
        'a7100000-0000-4000-8000-000000000001', gen_random_uuid(),
        gen_random_uuid(), null, '{}'::jsonb
    )$$,
    '42501', 'nutrition definition subject is not owned by caller',
    'a withdrawn participant cannot mutate food definitions'
);

SELECT tests.authenticate_as('nutrition_revision_other');
SELECT throws_ok(
    $$SELECT tests.revision_test_save(tests.revision_test_result(), 2)$$,
    '42501', 'nutrition progress subject is not owned by caller',
    'another participant cannot write the recall'
);

RESET ROLE;
SELECT set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}', true);
SET LOCAL ROLE authenticated;
SELECT lives_ok(
    $$DELETE FROM public.study_subject
      WHERE id = 'a7100000-0000-4000-8000-000000000001'$$,
    'the study owner can delete a participant with a protected recall'
);
RESET ROLE;
SELECT is(
    (SELECT count(*) FROM public.subject_progress
     WHERE subject_id = 'a7100000-0000-4000-8000-000000000001'),
    0::bigint, 'the participant cascade deletes the nutrition recall'
);

SELECT * FROM finish();
ROLLBACK;
