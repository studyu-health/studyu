BEGIN;

SELECT no_plan();

SELECT tests.create_supabase_user('nutrition_revision_owner', 'nutrition_revision_owner@studyu.health');
SELECT tests.create_supabase_user('nutrition_revision_other', 'nutrition_revision_other@studyu.health');

INSERT INTO public.study (
    id, user_id, title, status, contact, description, icon_name, questionnaire,
    eligibility_criteria, observations, interventions, consent, schedule, report_specification,
    results
)
SELECT
    'a7100000-0000-4000-8000-000000000002',
    user_id, 'Recall revision fixture', 'running',
    contact, description, icon_name, questionnaire, eligibility_criteria,
    '[
        {"id":"nutrition-task","type":"nutrition","schedule":{"completionPeriods":[{"id":"period-a"},{"id":"other-period"}]}},
        {"id":"specific-nutrition-task","type":"nutrition","schedule":{"completionPeriods":[{"id":"period-a"}]},"scheduleRule":{"type":"specificDays","specificDays":[2]}},
        {"id":"questionnaire-task","type":"questionnaire","schedule":{"completionPeriods":[{"id":"period-a"}]}}
    ]',
    '[{"id":"intervention-a"},{"id":"intervention-b"}]',
    consent,
    '{"phaseDuration":7,"numberOfCycles":2,"includeBaseline":false,"sequence":"alternating"}',
    report_specification, results
FROM public.study WHERE id = '22222222-2222-4222-8222-222222222222';

INSERT INTO public.study_subject (
    id, study_id, user_id, started_at, selected_intervention_ids
) VALUES (
    'a7100000-0000-4000-8000-000000000001',
    'a7100000-0000-4000-8000-000000000002',
    tests.get_supabase_uid('nutrition_revision_owner'),
    now() - interval '3 days',
    ARRAY['intervention-a','intervention-b']
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
    p_completed_at timestamptz DEFAULT now(), p_task_id text DEFAULT 'nutrition-task',
    p_intervention_id text DEFAULT 'intervention-a'
) RETURNS public.subject_progress LANGUAGE sql AS $$
    SELECT public.save_nutrition_recall(
        'a7100000-0000-4000-8000-000000000001', p_completed_at,
        p_intervention_id, p_task_id, p_result, p_expected_revision
    );
$$;

SELECT is(
    studyu_private.nutrition_intervention_for_day(
        '00000000-0000-4000-8000-000000000001',
        '{"phaseDuration":1,"numberOfCycles":2,"includeBaseline":false,"sequence":"randomized"}',
        ARRAY['intervention-a','intervention-b'], 2
    ), 'intervention-a', 'cycle one uses the same stable ordering as Dart'
);
SELECT is(
    studyu_private.nutrition_intervention_for_day(
        '00000000-0000-4000-8000-000000000001',
        '{"phaseDuration":1,"numberOfCycles":2,"includeBaseline":false,"sequence":"randomized"}',
        ARRAY['intervention-a','intervention-b'], 0
    ), 'intervention-a', 'the first randomized cycle preserves enrollment order'
);

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
        jsonb_set(
            jsonb_set(tests.revision_test_result(550), '{result,studyDaySnapshot}', '2'),
            '{result,date}', to_jsonb(now() - interval '1 day')
        ),
        null, now() - interval '1 day'
    )$$,
    'the same period can have a recall on a different writable study day'
);
SELECT lives_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(550), '{periodId}', '"other-period"'),
        null, now()
    )$$,
    'a different period can use the same requested completion timestamp'
);
SELECT is(
    (tests.revision_test_save(
        jsonb_set(tests.revision_test_result(550), '{periodId}', '"other-period"'), null, now()
    )).completed_at,
    now() + interval '1 microsecond',
    'retry returns the row allocated for the same recall'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(tests.revision_test_result(), p_task_id => 'questionnaire-task')$$,
    '22023', 'nutrition recall is not assigned to this study day',
    'nutrition cannot complete a questionnaire task'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(), '{periodId}', '"unscheduled-period"')
    )$$,
    '22023', 'nutrition recall is not assigned to this study day',
    'nutrition cannot complete a period outside the task'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(tests.revision_test_result(), p_task_id => 'specific-nutrition-task')$$,
    '22023', 'nutrition recall is not assigned to this study day',
    'nutrition cannot complete a task on an unscheduled day'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(), '{periodId}', '"other-period"'),
        p_task_id => 'specific-nutrition-task', p_intervention_id => 'intervention-b'
    )$$,
    '22023', 'nutrition recall is not assigned to this study day',
    'nutrition cannot complete a task under an unassigned intervention'
);
SELECT throws_ok(
    $$SELECT tests.revision_test_save(
        jsonb_set(tests.revision_test_result(), '{result,date}', to_jsonb(now() - interval '1 day')),
        p_task_id => 'specific-nutrition-task'
    )$$,
    '22023', 'nutrition recall date does not match its study day',
    'nutrition requires the occurrence date to match the UTC study day'
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
