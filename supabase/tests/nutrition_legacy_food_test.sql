BEGIN;
SELECT plan(15);

SELECT tests.create_supabase_user('legacy_food_owner', 'legacy_food_owner@studyu.health');
SELECT tests.create_supabase_user('legacy_food_other', 'legacy_food_other@studyu.health');
INSERT INTO public.study_subject (
    id, study_id, user_id, started_at, selected_intervention_ids
) VALUES (
    '10000000-0000-0000-0000-000000000091',
    (SELECT id FROM public.study LIMIT 1),
    tests.get_supabase_uid('legacy_food_owner'),
    now() - interval '5 days', ARRAY[]::text[]
);
SELECT tests.authenticate_as('legacy_food_owner');
CREATE TEMP TABLE legacy_food_test (
    food jsonb, snapshot jsonb, target jsonb, response jsonb
);
INSERT INTO legacy_food_test (food, target) VALUES (
    '{"id":"legacy-occurrence","entryType":"singleIngredient","name":"Original food","amount":2,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":200,"protein":2,"carbs":2,"fat":2,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00Z","originalValues":{}}',
    '{"taskId":"legacy-task","periodId":"legacy-period","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'
);
UPDATE legacy_food_test SET snapshot = food || jsonb_build_object(
    'foodId', 'bb6d79e8-4ca2-56db-ace4-6d491d9a4092',
    'foodVersionId', '9b239099-5afd-5a63-ba3a-93def9b19e8d',
    'name', 'Updated food'
);
INSERT INTO public.subject_progress (
    completed_at, subject_id, intervention_id, task_id, result_type, result
) SELECT
    '2026-07-15T12:00:00Z',
    '10000000-0000-0000-0000-000000000091',
    'intervention-a',
    'legacy-task',
    'DailyRecall',
    jsonb_build_object(
        'type', 'DailyRecall', 'periodId', 'legacy-period',
        'result',
        jsonb_build_object('studyDaySnapshot', 4, 'meals', jsonb_build_array(
            jsonb_build_object('foods', jsonb_build_array(
                food,
                food || '{"id":"legacy-sibling","name":"Sibling"}'::jsonb
            ))
        ))
    )
FROM legacy_food_test;

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
      '10000000-0000-0000-0000-000000000091', gen_random_uuid(),
      'bb6d79e8-4ca2-56db-ace4-6d491d9a4092',
      '9b239099-5afd-5a63-ba3a-93def9b19e8d', snapshot || '{"foodId":"bb6d79e8-4ca2-56db-ace4-6d491d9a4093"}'::jsonb,
      false, target, NULL, NULL, 'legacy-occurrence'
    ) FROM legacy_food_test$$,
    '22023', 'invalid nutrition mutation payload',
    'invalid mutations cannot retain a bootstrapped legacy definition'
);
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_definition), 0,
    'failed bootstrap rolls back the baseline definition'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,foodId}'
        FROM public.subject_progress
        WHERE task_id = 'legacy-task'
    ), NULL::text,
    'failed bootstrap leaves the legacy occurrence unchanged'
);
UPDATE legacy_food_test SET response = public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000091',
    '40000000-0000-0000-0000-000000000091',
    'bb6d79e8-4ca2-56db-ace4-6d491d9a4092',
    '9b239099-5afd-5a63-ba3a-93def9b19e8d', snapshot,
    FALSE, target, NULL, NULL, 'legacy-occurrence'
);
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_version), 2,
    'legacy mutation stores the baseline and new immutable version'
);
SELECT is(
    (
        SELECT snapshot ->> 'name' FROM public.nutrition_food_version
        WHERE version_number = 1
    ),
    'Original food', 'baseline retains the persisted food before the edit'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,name}'
        FROM public.subject_progress
        WHERE task_id = 'legacy-task'
    ), 'Updated food',
    'the selected legacy occurrence receives the new definition'
);
SELECT is(
    (
        SELECT result #> '{result,meals,0,foods,1}' FROM public.subject_progress
        WHERE task_id = 'legacy-task'
    ),
    (
        SELECT food || '{"id":"legacy-sibling","name":"Sibling"}'::jsonb
        FROM legacy_food_test
    ),
    'unselected legacy occurrences remain unchanged'
);
SELECT is(
    (SELECT public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000091',
        '40000000-0000-0000-0000-000000000091',
        'bb6d79e8-4ca2-56db-ace4-6d491d9a4092',
        '9b239099-5afd-5a63-ba3a-93def9b19e8d', snapshot,
        FALSE, target, NULL, NULL, 'legacy-occurrence'
    ) FROM legacy_food_test), (SELECT response FROM legacy_food_test),
    'legacy mutation retries remain idempotent'
);
SELECT tests.authenticate_as('legacy_food_other');
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
      '10000000-0000-0000-0000-000000000091', gen_random_uuid(),
      'bb6d79e8-4ca2-56db-ace4-6d491d9a4092',
      '9b239099-5afd-5a63-ba3a-93def9b19e8d', snapshot,
      false, target, NULL, NULL, 'legacy-occurrence'
    ) FROM legacy_food_test$$,
    '42501', 'nutrition definition subject is not owned by caller',
    'other subjects cannot bootstrap or edit the legacy occurrence'
);
SELECT set_config('role', 'postgres', TRUE);
SELECT is(
    (
        SELECT count(*)::integer
        FROM studyu_private.nutrition_maintenance_context
    ),
    0,
    'maintenance authorization is removed after successful and failed calls'
);
SELECT ok(
    NOT has_schema_privilege('authenticated', 'studyu_private', 'USAGE'),
    'authenticated callers cannot enter the maintenance schema'
);
SELECT ok(NOT has_table_privilege(
    'authenticated',
    'studyu_private.nutrition_maintenance_context', 'INSERT'
),
'authenticated callers cannot forge maintenance authorization');

SELECT is(
    (SELECT studyu_private.nutrition_upgrade_legacy_food(
        food || '{"entryType":"recipe"}'::jsonb
    ) ->> 'entryType' FROM legacy_food_test),
    'manualCustom',
    'legacy recipe totals remain available without ingredient snapshots'
);
SELECT is(
    (SELECT studyu_private.nutrition_upgrade_legacy_food(
        food || '{"entryType":"recipe","recipeMetadata":{"cookedWeight":250}}'::jsonb
    ) #>> '{preparationDetails,cookedWeight}' FROM legacy_food_test),
    '250',
    'legacy recipe preparation metadata remains available'
);
SELECT is(
    (SELECT studyu_private.nutrition_upgrade_legacy_food(
        food || '{"entryType":"recipe","recipeIngredients":[{"foodId":"ingredient","amount":2}]}'::jsonb
    ) #> '{originalValues,_legacyRecipeIngredients}' FROM legacy_food_test),
    '[{"foodId":"ingredient","amount":2}]'::jsonb,
    'legacy ingredient references remain available'
);

SELECT * FROM finish();
ROLLBACK;
