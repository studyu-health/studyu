BEGIN;

SELECT plan(97);

SELECT
    tests.create_supabase_user('nutrition_owner', 'nutrition_owner@studyu.health');
SELECT
    tests.create_supabase_user('nutrition_other', 'nutrition_other@studyu.health');

INSERT INTO public.study_subject (
    id, study_id, user_id, started_at, selected_intervention_ids
) VALUES
(
    '10000000-0000-0000-0000-000000000001',
    (SELECT id FROM public.study LIMIT 1),
    tests.get_supabase_uid('nutrition_owner'),
    now() - interval '5 days',
    ARRAY[]::text []
),
(
    '10000000-0000-0000-0000-000000000002',
    (SELECT id FROM public.study LIMIT 1),
    tests.get_supabase_uid('nutrition_other'),
    now() - interval '5 days',
    ARRAY[]::text []
);

SET LOCAL session_replication_role = replica;
INSERT INTO public.subject_progress (
    completed_at, subject_id, intervention_id, task_id, result_type, result
) VALUES
(
    '2026-07-15 12:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-a',
    'historical-task',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-a","result":{"id":"historical","date":"2026-07-15T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"historical-meal","mealType":"breakfast","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"historical-entry","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":2,"unit":"servings","servingSizeGrams":80,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":200,"protein":2,"carbs":2,"fat":2,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00.000Z","modifiedAt":"2026-07-15T09:00:00.000Z","originalValues":{},"parentEntryId":"historical-meal"},{"id":"historical-sibling","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Sibling old","amount":4,"unit":"plates","servingSizeGrams":400,"portionEstimationMethod":"householdMeasure","portionState":"asServed","nutrition":{"energyKcal":400,"protein":4,"carbs":4,"fat":4,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T10:00:00.000Z","originalValues":{}},{"id":"other-food-entry","foodId":"20000000-0000-0000-0000-000000000002","foodVersionId":"30000000-0000-0000-0000-000000000099","entryType":"singleIngredient","name":"Other food","amount":1,"unit":"serving","servingSizeGrams":50,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":50,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T11:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":4}}'::jsonb
),
(
    '2026-07-16 08:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-a',
    'current-task-a',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-b","result":{"id":"current-a","date":"2026-07-16T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"current-meal-a","mealType":"breakfast","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"current-entry-a","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":100,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-16T08:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":5}}'::jsonb
),
(
    '2026-07-16 09:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-b',
    'current-task-b',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-c","result":{"id":"current-b","date":"2026-07-16T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"current-meal-b","mealType":"lunch","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"current-entry-b","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":3,"unit":"bowls","servingSizeGrams":300,"portionEstimationMethod":"householdMeasure","portionState":"asServed","nutrition":{"energyKcal":300,"protein":3,"carbs":3,"fat":3,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-16T09:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":5}}'::jsonb
),
(
    '2026-07-14 12:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-a',
    'locked-task',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-old","result":{"id":"locked","date":"2026-07-14T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"locked-meal","mealType":"breakfast","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"locked-entry","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":100,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-14T08:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":3}}'::jsonb
),
(
    '2026-07-16 08:00:00+00',
    '10000000-0000-0000-0000-000000000002',
    'intervention-a',
    'other-subject-task',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-b","result":{"id":"other","date":"2026-07-16T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"other-meal","mealType":"breakfast","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"other-entry","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Other subject old","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":100,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-16T08:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":5}}'::jsonb
);

UPDATE public.subject_progress
SET
    result = jsonb_set(
        result,
        '{result,meals,0,foods}',
        (result #> '{result,meals,0,foods}') || jsonb_build_array(
            (result #> '{result,meals,0,foods,0}')
            || '{"id":"current-entry-a-second","amount":2,"nutrition":{"energyKcal":200,"protein":2,"carbs":2,"fat":2,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}}}'::jsonb
        )
    )
WHERE
    subject_id = '10000000-0000-0000-0000-000000000001'
    AND task_id = 'current-task-a';
SET LOCAL session_replication_role = origin;

SELECT tests.authenticate_as('nutrition_owner');

SELECT set_config(
    'studyu.nutrition_maintenance',
    'advance:10000000-0000-0000-0000-000000000001', TRUE
);
SELECT throws_ok(
    $$UPDATE public.study_subject SET started_at = started_at - interval '1 day'
      WHERE id = '10000000-0000-0000-0000-000000000001'$$,
    '22023', 'study subject clock and identity are immutable',
    'caller-controlled settings cannot authorize clock maintenance'
);
SELECT set_config(
    'studyu.nutrition_maintenance',
    'mutation:10000000-0000-0000-0000-000000000001', TRUE
);
SELECT throws_ok(
    $$UPDATE public.subject_progress SET result = result
      WHERE subject_id = '10000000-0000-0000-0000-000000000001'
        AND task_id = 'locked-task'$$,
    '22023', 'nutrition recall study day is not writable',
    'caller-controlled settings cannot authorize locked recall updates'
);
SELECT set_config(
    'studyu.nutrition_maintenance',
    'delete:10000000-0000-0000-0000-000000000001', TRUE
);
SELECT throws_ok(
    $$DELETE FROM public.subject_progress
      WHERE subject_id = '10000000-0000-0000-0000-000000000001'
        AND task_id = 'locked-task'$$,
    '22023', 'nutrition recall study day is not writable',
    'caller-controlled settings cannot authorize locked recall deletion'
);
SELECT set_config('studyu.nutrition_maintenance', '', TRUE);

CREATE TEMP TABLE nutrition_results (label text PRIMARY KEY, response jsonb);
INSERT INTO nutrition_results VALUES (
    'create',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        NULL,
        '{"id":"definition-snapshot","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":100,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00.000Z","originalValues":{}}'::jsonb,
        FALSE,
        NULL,
        NULL,
        TRUE
    )
);

SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_version),
    1,
    'creation inserts one immutable version'
);
SELECT is(
    (
        SELECT response FROM nutrition_results
        WHERE label = 'create'
    ),
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        NULL,
        '{}'::jsonb,
        FALSE,
        NULL,
        NULL,
        NULL
    ),
    'idempotent retry returns the canonical original response'
);
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_version),
    1,
    'idempotent retry does not add a version'
);

INSERT INTO nutrition_results VALUES (
    'historical',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000001',
        (
            (
                SELECT response FROM nutrition_results
                WHERE label = 'create'
            ) #>> '{definition,currentVersionId}'
        )::uuid,
        '{"id":"edited-snapshot","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"New","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":150,"protein":2,"carbs":2,"fat":2,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00.000Z","originalValues":{}}'::jsonb,
        FALSE,
        '{"taskId":"historical-task","periodId":"period-a","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'::jsonb,
        5,
        NULL,
        'historical-entry'
    )
);

SELECT is(
    (
        SELECT (response ->> 'selectedHistoricalUpdateCount')::integer
        FROM nutrition_results
        WHERE label = 'historical'
    ),
    1,
    'mutation reports the selected historical row update count'
);
SELECT is(
    (
        SELECT (response ->> 'todayUpdateCount')::integer
        FROM nutrition_results
        WHERE label = 'historical'
    ),
    3,
    'mutation reports the current study-day occurrence update count'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,name}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    'New',
    'selected historical target is rewritten'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,1,name}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    'Sibling old',
    'same-food historical sibling is not rewritten'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,id}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    'historical-entry',
    'historical logged entry identity is preserved'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,unit}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    'serving',
    'historical serving name comes from the new definition'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,servingSizeGrams}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    '100',
    'historical serving weight comes from the new definition'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,amount}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    '2',
    'historical quantity is preserved'
);
SELECT is(
    (
        SELECT count(*)::integer FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND (result #>> '{result,studyDaySnapshot}')::integer = 5
            AND result #>> '{result,meals,0,foods,0,name}' = 'New'
    ),
    2,
    'all matching current-day task and period rows are rewritten'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,1,name}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'current-task-a'
    ),
    'New',
    'multiple same-food occurrences in one current-day row are rewritten'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,amount}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'current-task-b'
    ),
    '3',
    'current-day serving state is preserved'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,unit}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'current-task-b'
    ),
    'serving',
    'current-day serving metadata comes from the new definition'
);
SELECT is(
    (
        SELECT
            (
                result #>> '{result,meals,0,foods,0,nutrition,energyKcal}'
            )::numeric
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'current-task-b'
    ),
    450::numeric,
    'definition nutrition is scaled to the preserved quantity'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,name}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'locked-task'
    ),
    'Old',
    'unrelated historical days are isolated'
);
SELECT tests.authenticate_as('nutrition_other');
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,name}'
        FROM public.subject_progress
        WHERE subject_id = '10000000-0000-0000-0000-000000000002'
    ),
    'Other subject old',
    'other subjects are isolated'
);
SELECT tests.authenticate_as('nutrition_owner');

INSERT INTO nutrition_results VALUES (
    'composite-create',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000020',
        '20000000-0000-0000-0000-000000000020',
        NULL,
        '{"id":"meal-definition-snapshot","foodId":"20000000-0000-0000-0000-000000000020","foodVersionId":"30000000-0000-0000-0000-000000000020","entryType":"meal","name":"Composite old","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":100,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00.000Z","originalValues":{},"componentFoods":[{"id":"composition-a","parentEntryId":"meal-definition-snapshot","foodId":"20000000-0000-0000-0000-000000000002","amount":1,"unit":"serving","sortOrder":0}],"componentSnapshots":[{"id":"component-snapshot","foodId":"20000000-0000-0000-0000-000000000002","foodVersionId":"30000000-0000-0000-0000-000000000099","entryType":"singleIngredient","name":"Component old","amount":1,"unit":"serving","servingSizeGrams":50,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":50,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00.000Z","originalValues":{}}]}'::jsonb,
        FALSE, NULL, NULL, TRUE
    )
);

INSERT INTO public.subject_progress (
    completed_at, subject_id, intervention_id, task_id, result_type, result
) VALUES
(
    '2026-07-15 13:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-composite',
    'historical-composite-task',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-composite","result":{"id":"historical-composite","date":"2026-07-15T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"historical-composite-meal","mealType":"dinner","mealContext":"home","timestamp":"2026-07-15T18:30:00.000Z","timezone":"UTC","isSkipped":false,"foods":[{"id":"historical-composite-entry","foodId":"20000000-0000-0000-0000-000000000020","foodVersionId":"30000000-0000-0000-0000-000000000020","entryType":"meal","name":"Composite old","amount":2,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":200,"protein":2,"carbs":2,"fat":2,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T18:30:00.000Z","originalValues":{},"parentEntryId":"historical-composite-meal","componentFoods":[{"id":"logged-composition","parentEntryId":"historical-composite-entry","foodId":"20000000-0000-0000-0000-000000000002","amount":1,"unit":"serving","sortOrder":0}],"componentSnapshots":[{"id":"logged-component-snapshot","foodId":"20000000-0000-0000-0000-000000000002","foodVersionId":"30000000-0000-0000-0000-000000000099","entryType":"singleIngredient","name":"Embedded old","amount":1,"unit":"serving","servingSizeGrams":50,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":50,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00.000Z","originalValues":{}}]},{"id":"historical-individual-component","foodId":"20000000-0000-0000-0000-000000000002","foodVersionId":"30000000-0000-0000-0000-000000000099","entryType":"singleIngredient","name":"Individual old","amount":1,"unit":"serving","servingSizeGrams":50,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":50,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T19:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":4}}'::jsonb
),
(
    '2026-07-16 13:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-composite',
    'current-composite-task',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-composite-today","result":{"id":"current-composite","date":"2026-07-16T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"current-composite-meal","mealType":"lunch","mealContext":"home","timestamp":"2026-07-16T12:15:00.000Z","timezone":"UTC","isSkipped":false,"foods":[{"id":"current-composite-entry","foodId":"20000000-0000-0000-0000-000000000020","foodVersionId":"30000000-0000-0000-0000-000000000020","entryType":"meal","name":"Composite old","amount":4,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":400,"protein":4,"carbs":4,"fat":4,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-16T12:15:00.000Z","originalValues":{},"componentFoods":[],"componentSnapshots":[]},{"id":"current-individual-component","foodId":"20000000-0000-0000-0000-000000000002","foodVersionId":"30000000-0000-0000-0000-000000000099","entryType":"singleIngredient","name":"Individual today old","amount":1,"unit":"serving","servingSizeGrams":50,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":50,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-16T12:30:00.000Z","originalValues":{}}]}],"studyDaySnapshot":5}}'::jsonb
);

UPDATE public.subject_progress
SET
    result = jsonb_set(
        result,
        '{result,meals,0,foods}',
        (result #> '{result,meals,0,foods}') || jsonb_build_array(
            (result #> '{result,meals,0,foods,0}') || jsonb_build_object(
                'id', 'current-composite-entry-second',
                'amount', 3,
                'nutrition', jsonb_build_object(
                    'energyKcal', 300,
                    'protein', 3,
                    'carbs', 3,
                    'fat', 3,
                    'sugars', 0,
                    'fiber', 0,
                    'saturatedFat', 0,
                    'transFat', 0,
                    'cholesterol', 0,
                    'sodium', 0,
                    'waterContent', 0,
                    'micros', '{}'::jsonb
                )
            )
        )
    )
WHERE task_id = 'current-composite-task';

INSERT INTO nutrition_results VALUES (
    'composite-historical',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000021',
        '20000000-0000-0000-0000-000000000020',
        (
            (
                SELECT response FROM nutrition_results
                WHERE label = 'composite-create'
            ) #>> '{definition,currentVersionId}'
        )::uuid,
        jsonb_set(
            jsonb_set(
                (
                    SELECT response #> '{definition,snapshot}'
                    FROM nutrition_results
                    WHERE label = 'composite-create'
                ),
                '{name}', '"Composite new"'::jsonb
            ),
            '{componentFoods,0,amount}', '2'::jsonb
        ) || jsonb_build_object(
            'componentSnapshots', jsonb_build_array(
                jsonb_set(
                    (
                        SELECT
                            response
                            #> '{definition,snapshot,componentSnapshots,0}'
                        FROM nutrition_results
                        WHERE label = 'composite-create'
                    ),
                    '{amount}', '2'::jsonb
                )
            )
        ),
        FALSE,
        '{"taskId":"historical-composite-task","periodId":"period-composite","interventionId":"intervention-composite","completedAt":"2026-07-15T13:00:00Z","studyDaySnapshot":4}'::jsonb,
        NULL,
        NULL,
        'historical-composite-entry'
    )
);

SELECT is(
    (
        SELECT (response ->> 'selectedHistoricalUpdateCount')::integer
        FROM nutrition_results
        WHERE label = 'composite-historical'
    ),
    1,
    'composite mutation updates the selected historical entry'
);
SELECT is(
    (
        SELECT (response ->> 'todayUpdateCount')::integer FROM nutrition_results
        WHERE label = 'composite-historical'
    ),
    0,
    'null propagation skips current-day composite occurrences'
);
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.nutrition_food_definition
        WHERE
            id = '20000000-0000-0000-0000-000000000002'
            AND subject_id = '10000000-0000-0000-0000-000000000001'
            AND library_visible = FALSE
    ),
    1,
    'historical composite mutation creates missing component definition atomically'
);
SELECT is(
    (
        SELECT
            response
            #>> '{definition,snapshot,componentSnapshots,0,foodVersionId}'
        FROM nutrition_results
        WHERE label = 'composite-historical'
    ),
    (
        SELECT current_version_id::text
        FROM public.nutrition_food_definition
        WHERE id = '20000000-0000-0000-0000-000000000002'
    ),
    'historical composite snapshot uses canonical component version identity'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,name}'
        FROM public.subject_progress
        WHERE task_id = 'historical-composite-task'
    ),
    'Composite new',
    'historical composite receives the new definition'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,amount}'
        FROM public.subject_progress
        WHERE task_id = 'historical-composite-task'
    ),
    '2',
    'historical composite quantity is preserved'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,parentEntryId}'
        FROM public.subject_progress
        WHERE task_id = 'historical-composite-task'
    ),
    'historical-composite-meal',
    'historical composite meal placement is preserved'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,timestamp}'
        FROM public.subject_progress
        WHERE task_id = 'historical-composite-task'
    ),
    '2026-07-15T18:30:00.000Z',
    'historical composite meal time is preserved'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,componentFoods,0,amount}'
        FROM public.subject_progress
        WHERE task_id = 'historical-composite-task'
    ),
    '2',
    'historical composite persists the new ordered composition'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,componentSnapshots,0,amount}'
        FROM public.subject_progress
        WHERE task_id = 'historical-composite-task'
    ),
    '2',
    'historical composite persists the corresponding component snapshot'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,1,name}'
        FROM public.subject_progress
        WHERE task_id = 'historical-composite-task'
    ),
    'Individual old',
    'historical individual component occurrence is isolated'
);
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.subject_progress,
            jsonb_array_elements(result #> '{result,meals,0,foods}') AS food
        WHERE
            task_id = 'current-composite-task'
            AND food ->> 'foodId' = '20000000-0000-0000-0000-000000000020'
            AND food ->> 'name' = 'Composite old'
    ),
    2,
    'null propagation leaves all current-day composite names unchanged'
);
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.subject_progress,
            jsonb_array_elements(result #> '{result,meals,0,foods}') AS food
        WHERE
            task_id = 'current-composite-task'
            AND food ->> 'foodId' = '20000000-0000-0000-0000-000000000020'
            AND food #>> '{componentFoods,0,amount}' = '2'
            AND food #>> '{componentFoods,0,foodId}'
            = '20000000-0000-0000-0000-000000000002'
    ),
    0,
    'null propagation leaves current-day composite composition unchanged'
);
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.subject_progress,
            jsonb_array_elements(result #> '{result,meals,0,foods}') AS food
        WHERE
            task_id = 'current-composite-task'
            AND food ->> 'foodId' = '20000000-0000-0000-0000-000000000020'
            AND food #>> '{componentSnapshots,0,amount}' = '2'
            AND food #>> '{componentSnapshots,0,foodId}'
            = '20000000-0000-0000-0000-000000000002'
    ),
    0,
    'null propagation leaves current-day component snapshots unchanged'
);
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.subject_progress,
            jsonb_array_elements(result #> '{result,meals,0,foods}') AS food
        WHERE
            task_id = 'current-composite-task'
            AND food ->> 'foodId' = '20000000-0000-0000-0000-000000000020'
            AND (food #>> '{nutrition,energyKcal}')::numeric
            = (food ->> 'amount')::numeric * 100
    ),
    2,
    'one-serving composite nutrition scales to every current-day quantity'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,1,name}'
        FROM public.subject_progress
        WHERE task_id = 'current-composite-task'
    ),
    'Individual today old',
    'current-day individual component occurrence is isolated'
);

SELECT throws_ok(
    $$UPDATE public.study_subject
      SET started_at = started_at - interval '1 day'
      WHERE id = '10000000-0000-0000-0000-000000000001'$$,
    '22023',
    'study subject clock and identity are immutable',
    'callers cannot rewrite the authoritative nutrition clock'
);
SELECT is(
    (
        SELECT (
            (now() AT TIME ZONE 'UTC')::date
            - (started_at AT TIME ZONE 'UTC')::date
        )::integer
        FROM public.study_subject
        WHERE id = '10000000-0000-0000-0000-000000000001'
    ),
    5,
    'rejected clock changes leave the UTC nutrition study day unchanged'
);

SELECT throws_ok(
    $$UPDATE public.subject_progress
      SET result = jsonb_set(result, '{result,meals,0,foods,0,name}', '"Forged"')
      WHERE subject_id = '10000000-0000-0000-0000-000000000001'
        AND task_id = 'locked-task'$$,
    '22023',
    'nutrition recall study day is not writable',
    'direct writes cannot update locked historical recalls'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,name}'
        FROM public.subject_progress
        WHERE task_id = 'locked-task'
    ),
    'Old',
    'rejected direct updates leave locked recalls unchanged'
);
SELECT throws_ok(
    $$DELETE FROM public.subject_progress
      WHERE subject_id = '10000000-0000-0000-0000-000000000001'
        AND task_id = 'locked-task'$$,
    '22023',
    'nutrition recall study day is not writable',
    'direct writes cannot delete locked historical recalls'
);
SELECT is(
    (
        SELECT count(*)::integer FROM public.subject_progress
        WHERE task_id = 'locked-task'
    ),
    1,
    'rejected direct deletes preserve locked recalls'
);
SELECT throws_ok(
    $$INSERT INTO public.subject_progress (
        completed_at, subject_id, intervention_id, task_id, result_type, result
      ) SELECT
        '2026-07-13T12:00:00Z', subject_id, intervention_id, 'forged-old-task',
        result_type,
        jsonb_set(result, '{result,studyDaySnapshot}', '2')
      FROM public.subject_progress WHERE task_id = 'locked-task'$$,
    '22023',
    'nutrition recall study day is not writable',
    'direct writes cannot insert out-of-window historical recalls'
);
SELECT throws_ok(
    $$UPDATE public.subject_progress
      SET result = jsonb_set(result, '{result,studyDaySnapshot}', '3')
      WHERE subject_id = '10000000-0000-0000-0000-000000000001'
        AND task_id = 'historical-task'$$,
    '22023',
    'nutrition recall study day is not writable',
    'direct writes cannot change a recall study-day identity'
);
SELECT lives_ok(
    $$UPDATE public.subject_progress
      SET result = jsonb_set(result, '{result,specialOccasion}', '"holiday"')
      WHERE subject_id = '10000000-0000-0000-0000-000000000001'
        AND task_id = 'historical-task'$$,
    'direct entry-local writes remain allowed for the latest historical day'
);

CREATE TEMP VIEW mutation_guard_state AS
SELECT jsonb_build_object(
    'definition', (
        SELECT to_jsonb(d.*)
        FROM public.nutrition_food_definition AS d
        WHERE d.id = '20000000-0000-0000-0000-000000000001'
    ),
    'versions', (
        SELECT jsonb_agg(to_jsonb(v.*) ORDER BY v.version_number)
        FROM public.nutrition_food_version AS v
        WHERE v.food_id = '20000000-0000-0000-0000-000000000001'
    ),
    'progress', (
        SELECT jsonb_agg(to_jsonb(p.*) ORDER BY p.completed_at, p.task_id)
        FROM public.subject_progress AS p
        WHERE p.subject_id = '10000000-0000-0000-0000-000000000001'
    )
) AS state;
CREATE TEMP TABLE mutation_guard_baseline AS
SELECT state FROM mutation_guard_state;

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000030',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
    false,
    '{"taskId":"locked-task","periodId":"period-old","interventionId":"intervention-a","completedAt":"2026-07-14T12:00:00Z","studyDaySnapshot":3}'::jsonb,
    4,
    NULL,
    'locked-entry'
  )$$,
    '22023',
    'historical nutrition recall is no longer editable',
    'callers cannot forge an older historical edit window'
);
SELECT is(
    (SELECT state FROM mutation_guard_state),
    (SELECT state FROM mutation_guard_baseline),
    'forged old target rejection leaves definitions, versions, and progress unchanged'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000031',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
    false,
    '{"taskId":"historical-task","periodId":"period-a","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'::jsonb,
    6,
    NULL,
    'historical-entry'
  )$$,
    '22023',
    'historical nutrition recall is no longer editable',
    'callers cannot forge the propagation study day'
);
SELECT is(
    (SELECT state FROM mutation_guard_state),
    (SELECT state FROM mutation_guard_baseline),
    'forged propagation rejection leaves definitions, versions, and progress unchanged'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000032',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
    false, NULL, 5, NULL
  )$$,
    '22023',
    'historical nutrition recall is no longer editable',
    'propagation requires a historical target'
);
SELECT is(
    (SELECT state FROM mutation_guard_state),
    (SELECT state FROM mutation_guard_baseline),
    'targetless propagation rejection leaves definitions, versions, and progress unchanged'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000009',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical') - 'source',
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'snapshots missing a FoodEntry required field are rejected'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000a',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    jsonb_set(
      (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
      '{entryType}', '"invalid"'::jsonb
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'snapshots with unknown enum values are rejected'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000b',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    jsonb_set(
      (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
      '{nutrition,energyKcal}', '"not-a-number"'::jsonb
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'snapshots with invalid nested JSON types are rejected'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000e',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    jsonb_set(
      (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
      '{createdAt}', '"2026-07-15T08:00:00 UTC"'::jsonb
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'timestamps unsupported by Dart DateTime.parse are rejected'
);
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_version),
    5,
    'malformed snapshot mutations roll back without adding versions'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000c',
    '20000000-0000-0000-0000-000000000010',
    NULL,
    jsonb_set(
      jsonb_set(
        (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
        '{foodId}', '"20000000-0000-0000-0000-000000000010"'::jsonb
      ),
      '{entryType}', '"meal"'::jsonb
    ) || jsonb_build_object(
      'componentFoods', jsonb_build_array(jsonb_build_object(
        'id', 'composition-a',
        'parentEntryId', 'edited-snapshot',
        'foodId', '20000000-0000-0000-0000-000000000001',
        'amount', 1,
        'unit', 'serving'
      )),
      'componentSnapshots', jsonb_build_array(
        (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical') - 'source'
      )
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'saved-meal component snapshots are validated recursively'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000d',
    '20000000-0000-0000-0000-000000000011',
    NULL,
    jsonb_set(
      jsonb_set(
        (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
        '{foodId}', '"20000000-0000-0000-0000-000000000011"'::jsonb
      ),
      '{entryType}', '"meal"'::jsonb
    ) || jsonb_build_object(
      'componentFoods', jsonb_build_array(jsonb_build_object(
        'id', 'composition-a',
        'parentEntryId', 'edited-snapshot',
        'foodId', '20000000-0000-0000-0000-000000000002',
        'amount', 1,
        'unit', 'serving'
      )),
      'componentSnapshots', jsonb_build_array(
        (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical')
      )
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'saved-meal components must correspond by ordered food identity'
);
SELECT is(
    (
        SELECT count(*)::integer FROM public.nutrition_food_definition
        WHERE id IN (
            '20000000-0000-0000-0000-000000000010',
            '20000000-0000-0000-0000-000000000011'
        )
    ),
    0,
    'malformed saved meals roll back definition creation atomically'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000003',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'create') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
    false, NULL, NULL, NULL
  )$$,
    '40001',
    'stale nutrition definition version',
    'stale versions are rejected'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000004',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
    false,
    '{"taskId":"missing","periodId":"period-a","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'::jsonb,
    5,
    NULL,
    'historical-entry'
  )$$,
    'P0002',
    'historical nutrition recall target is missing or ambiguous',
    'nonmatching persistence targets are rejected atomically'
);
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_version),
    5,
    'post-version target failures roll back the entire mutation'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000022',
    '20000000-0000-0000-0000-000000000020',
    ((SELECT response FROM nutrition_results WHERE label = 'composite-historical') #>> '{definition,currentVersionId}')::uuid,
    jsonb_set(
      jsonb_set(
        jsonb_set(
          (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'composite-historical'),
          '{componentFoods,0,foodId}',
          '"20000000-0000-0000-0000-000000000022"'::jsonb
        ),
        '{componentSnapshots,0,foodId}',
        '"20000000-0000-0000-0000-000000000022"'::jsonb
      ),
      '{componentSnapshots,0,foodVersionId}',
      '"30000000-0000-0000-0000-000000000022"'::jsonb
    ),
    false,
    '{"taskId":"missing-composite","periodId":"period-composite","interventionId":"intervention-composite","completedAt":"2026-07-15T13:00:00Z","studyDaySnapshot":4}'::jsonb,
    NULL,
    NULL,
    'historical-composite-entry'
  )$$,
    'P0002',
    'historical nutrition recall target is missing or ambiguous',
    'failed historical composite mutation rolls back component setup'
);
SELECT is(
    (
        SELECT count(*)::integer
        FROM public.nutrition_food_definition
        WHERE id = '20000000-0000-0000-0000-000000000022'
    ),
    0,
    'failed historical composite mutation leaves no invisible component definition'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000008',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
    false,
    '{"taskId":"historical-task","periodId":"period-a","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'::jsonb,
    5,
    NULL,
    'other-food-entry'
  )$$,
    'P0002',
    'historical target entry does not contain food definition',
    'historical entry must belong to the requested stable food definition'
);

INSERT INTO nutrition_results VALUES (
    'delete',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000005',
        '20000000-0000-0000-0000-000000000001',
        (
            (
                SELECT response FROM nutrition_results
                WHERE label = 'historical'
            ) #>> '{definition,currentVersionId}'
        )::uuid,
        (
            SELECT response #> '{definition,snapshot}' FROM nutrition_results
            WHERE label = 'historical'
        ),
        TRUE, NULL, NULL, NULL
    )
);
SELECT ok(
    (
        SELECT deleted_at IS NOT NULL FROM public.nutrition_food_definition
        WHERE id = '20000000-0000-0000-0000-000000000001'
    ),
    'definition is soft deleted'
);

INSERT INTO nutrition_results VALUES (
    'restore',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000006',
        '20000000-0000-0000-0000-000000000001',
        (
            (
                SELECT response FROM nutrition_results
                WHERE label = 'historical'
            ) #>> '{definition,currentVersionId}'
        )::uuid,
        (
            SELECT response #> '{definition,snapshot}' FROM nutrition_results
            WHERE label = 'historical'
        ),
        FALSE,
        '{"taskId":"historical-task","periodId":"period-a","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'::jsonb,
        5,
        NULL,
        'historical-entry'
    )
);
SELECT ok(
    (
        SELECT deleted_at IS NULL FROM public.nutrition_food_definition
        WHERE id = '20000000-0000-0000-0000-000000000001'
    ),
    'historical edit restores the same stable definition identity'
);
SELECT is(
    (
        SELECT count(*)::integer FROM public.nutrition_food_definition
        WHERE id = '20000000-0000-0000-0000-000000000001'
    ),
    1,
    'restore does not create a second definition'
);

SELECT tests.authenticate_as('nutrition_other');
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_definition),
    0,
    'definition RLS hides another subject library'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000007',
    '20000000-0000-0000-0000-000000000001',
    NULL, '{}'::jsonb, false, NULL, NULL, NULL
  )$$,
    '42501',
    'nutrition definition subject is not owned by caller',
    'RPC rejects cross-subject mutation'
);
SELECT throws_ok(
    $$SELECT public.advance_owned_study_subject_day(
      '10000000-0000-0000-0000-000000000001', 1
    )$$,
    '22023',
    'invalid study subject day advance',
    'preview RPC rejects cross-subject advancement'
);
SELECT throws_ok(
    $$SELECT public.delete_owned_subject_progress(
      '10000000-0000-0000-0000-000000000001'
    )$$,
    '42501',
    'study subject is not owned by caller',
    'cleanup RPC rejects cross-subject deletion'
);

SELECT tests.authenticate_as('nutrition_owner');
SELECT throws_ok(
    $$SELECT public.advance_owned_study_subject_day(
      '10000000-0000-0000-0000-000000000001', 2
    )$$,
    '22023',
    'invalid study subject day advance',
    'preview RPC rejects unsupported day advances'
);
SELECT throws_ok(
    $$SELECT public.advance_owned_study_subject_day(NULL, 1)$$,
    '22023',
    'invalid study subject day advance',
    'preview RPC rejects a null subject'
);
SELECT throws_ok(
    $$SELECT public.delete_owned_subject_progress(NULL)$$,
    '42501',
    'study subject is not owned by caller',
    'cleanup RPC rejects a null subject'
);
SELECT is(
    (
        SELECT (
            (now() AT TIME ZONE 'UTC')::date
            - (started_at AT TIME ZONE 'UTC')::date
        )::integer
        FROM public.study_subject
        WHERE id = '10000000-0000-0000-0000-000000000001'
    ),
    5,
    'rejected preview arguments leave the subject clock unchanged'
);
SELECT is(
    (
        SELECT count(*)
        FROM pg_proc AS procedure
        INNER JOIN pg_namespace AS namespace
            ON procedure.pronamespace = namespace.oid
        WHERE
            namespace.nspname = 'public'
            AND procedure.proname IN (
                'advance_owned_study_subject_day',
                'delete_owned_subject_progress',
                'apply_nutrition_food_mutation'
            )
            AND pg_get_userbyid(procedure.proowner) = 'postgres'
    ),
    3::bigint,
    'guarded RPCs remain owned by postgres'
);
SELECT is(
    (
        SELECT count(*)
        FROM pg_proc AS procedure
        INNER JOIN pg_namespace AS namespace
            ON procedure.pronamespace = namespace.oid
        WHERE
            namespace.nspname = 'public'
            AND procedure.proname IN (
                'advance_owned_study_subject_day',
                'delete_owned_subject_progress',
                'apply_nutrition_food_mutation'
            )
            AND array_to_string(procedure.proconfig, ',') = 'search_path=""'
    ),
    3::bigint,
    'guarded RPCs use empty search paths'
);
SELECT is(
    (
        SELECT count(*)
        FROM (
            VALUES
            ('public.advance_owned_study_subject_day(uuid,integer)'),
            ('public.delete_owned_subject_progress(uuid)'),
            (
                'public.apply_nutrition_food_mutation(uuid,uuid,uuid,uuid,jsonb,boolean,jsonb,integer,boolean,text)'
            )
        ) AS rpc (signature)
        WHERE has_function_privilege('service_role', signature, 'EXECUTE')
    ),
    3::bigint,
    'service role can execute every guarded RPC'
);
SELECT set_config('role', 'service_role', TRUE);
SELECT set_config('request.jwt.claims', '{}', TRUE);
SELECT throws_ok(
    $$UPDATE public.study_subject
      SET started_at = started_at - interval '1 day'
      WHERE id = '10000000-0000-0000-0000-000000000001'$$,
    '22023',
    'study subject clock and identity are immutable',
    'service role cannot directly rewrite the authoritative nutrition clock'
);
SELECT throws_ok(
    $$UPDATE public.study_subject
      SET id = '10000000-0000-0000-0000-000000000099'
      WHERE id = '10000000-0000-0000-0000-000000000001'$$,
    '22023',
    'study subject clock and identity are immutable',
    'service role cannot directly rewrite authoritative subject identity'
);
SELECT throws_ok(
    $$INSERT INTO public.subject_progress (
        completed_at, subject_id, intervention_id, task_id, result_type, result
      ) SELECT
        '2026-07-13T13:00:00Z', subject_id, intervention_id,
        'service-forged-old-task', result_type,
        jsonb_set(result, '{result,studyDaySnapshot}', '2')
      FROM public.subject_progress WHERE task_id = 'locked-task'$$,
    '42501',
    'nutrition progress subject is not owned by caller',
    'service role cannot directly insert an out-of-window recall'
);
SELECT throws_ok(
    $$UPDATE public.subject_progress
      SET result = jsonb_set(
        result, '{result,meals,0,foods,0,name}', '"Service forged"'
      )
      WHERE subject_id = '10000000-0000-0000-0000-000000000001'
        AND task_id = 'locked-task'$$,
    '42501',
    'nutrition progress subject is not owned by caller',
    'service role cannot directly update a protected recall'
);
SELECT throws_ok(
    $$DELETE FROM public.subject_progress
      WHERE subject_id = '10000000-0000-0000-0000-000000000001'
        AND task_id = 'locked-task'$$,
    '42501',
    'nutrition progress subject is not owned by caller',
    'service role cannot directly delete a protected recall'
);
SELECT set_config('role', 'postgres', TRUE);
CREATE FUNCTION pg_temp.reject_preview_clock_update()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'forced preview failure';
END;
$$;
CREATE TRIGGER reject_preview_clock_update
BEFORE UPDATE OF started_at ON public.study_subject
FOR EACH ROW
WHEN (old.id = '10000000-0000-0000-0000-000000000001')
EXECUTE FUNCTION pg_temp.reject_preview_clock_update();
SELECT tests.authenticate_as('nutrition_owner');
SELECT throws_ok(
    $$SELECT public.advance_owned_study_subject_day(
      '10000000-0000-0000-0000-000000000001', 1
    )$$,
    'P0001',
    'forced preview failure',
    'preview failure rolls back the guarded atomic path'
);
SELECT is(
    (
        SELECT max(completed_at) FROM public.subject_progress
        WHERE subject_id = '10000000-0000-0000-0000-000000000001'
    ),
    '2026-07-16 13:00:00+00'::timestamptz,
    'failed preview leaves all progress timestamps unchanged'
);
SELECT set_config('role', 'postgres', TRUE);
DROP TRIGGER reject_preview_clock_update ON public.study_subject;
SELECT set_config('role', 'authenticated', TRUE);
SELECT lives_ok(
    $$SELECT public.advance_owned_study_subject_day(
      '10000000-0000-0000-0000-000000000001', 1
    )$$,
    'owned preview day advance uses the guarded atomic path'
);
SELECT is(
    (
        SELECT (
            (now() AT TIME ZONE 'UTC')::date
            - (started_at AT TIME ZONE 'UTC')::date
        )::integer
        FROM public.study_subject
        WHERE id = '10000000-0000-0000-0000-000000000001'
    ),
    6,
    'preview day advance updates the authoritative UTC nutrition clock'
);
SELECT is(
    (
        SELECT max(completed_at) FROM public.subject_progress
        WHERE subject_id = '10000000-0000-0000-0000-000000000001'
    ),
    '2026-07-15 13:00:00+00'::timestamptz,
    'preview day advance shifts persisted progress atomically'
);
SELECT lives_ok(
    $$SELECT public.delete_owned_subject_progress(
      '10000000-0000-0000-0000-000000000001'
    )$$,
    'owned cleanup can remove protected historical progress'
);
SELECT is(
    (
        SELECT count(*)::integer FROM public.subject_progress
        WHERE subject_id = '10000000-0000-0000-0000-000000000001'
    ),
    0,
    'owned cleanup removes all subject progress'
);

SELECT set_config('role', 'service_role', TRUE);
SELECT set_config('request.jwt.claims', '{}', TRUE);
SELECT lives_ok(
    $$SELECT public.apply_nutrition_food_mutation(
      '10000000-0000-0000-0000-000000000001',
      '40000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000001',
      NULL, '{}'::jsonb, false, NULL, NULL, NULL
    )$$,
    'service role can retry an atomic mutation without a user JWT'
);
SELECT lives_ok(
    $$SELECT public.advance_owned_study_subject_day(
      '10000000-0000-0000-0000-000000000002', 1
    )$$,
    'service role can advance a subject without a user JWT'
);
SELECT is(
    (
        SELECT max(completed_at) FROM public.subject_progress
        WHERE subject_id = '10000000-0000-0000-0000-000000000002'
    ),
    '2026-07-15 08:00:00+00'::timestamptz,
    'service preview shifts progress through the guarded path'
);
SELECT lives_ok(
    $$SELECT public.delete_owned_subject_progress(
      '10000000-0000-0000-0000-000000000002'
    )$$,
    'service role can clean up a subject without a user JWT'
);
SELECT is(
    (
        SELECT count(*)::integer FROM public.subject_progress
        WHERE subject_id = '10000000-0000-0000-0000-000000000002'
    ),
    0,
    'service cleanup removes only the requested subject progress'
);

SELECT * FROM finish();
ROLLBACK;
