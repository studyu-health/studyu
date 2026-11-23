BEGIN;

SELECT no_plan();

SELECT tests.create_supabase_user('availability_owner', 'availability_owner@studyu.health');
SELECT tests.create_supabase_user('availability_other', 'availability_other@studyu.health');
INSERT INTO public.study (
    id, user_id, title, description, icon_name, contact, questionnaire,
    eligibility_criteria, observations, interventions, consent, schedule,
    report_specification, results
) VALUES (
    'a0000000-0000-0000-0000-000000000001',
    tests.get_supabase_uid('availability_owner'),
    'Availability test',
    '',
    '',
    '{}',
    '{}',
    '{}',
    '[{"id":"availability-task","type":"nutrition","schedule":{"completionPeriods":[{"id":"availability-period"}]}}]',
    '[{"id":"availability-intervention"},{"id":"other-intervention"}]',
    '{}',
    '{"phaseDuration":7,"numberOfCycles":1,"includeBaseline":false,"sequence":"alternating"}',
    '{}',
    '{}'
);
INSERT INTO public.study_subject (
    id, study_id, user_id, started_at, selected_intervention_ids
)
VALUES
(
    'a1000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    tests.get_supabase_uid('availability_owner'),
    now() - interval '2 days',
    ARRAY['availability-intervention','other-intervention']
),
(
    'a1000000-0000-0000-0000-000000000002',
    'a0000000-0000-0000-0000-000000000001',
    tests.get_supabase_uid('availability_other'),
    now() - interval '2 days',
    ARRAY['availability-intervention','other-intervention']
);

CREATE FUNCTION tests.availability_food(
    p_id uuid DEFAULT 'a2000000-0000-0000-0000-000000000001'
)
RETURNS jsonb LANGUAGE sql IMMUTABLE AS $$
  SELECT jsonb_build_object(
    'id', 'availability-entry', 'foodId', p_id, 'foodVersionId', 'a3000000-0000-0000-0000-000000000001',
    'entryType', 'singleIngredient', 'name', 'Availability food', 'amount', 1,
    'unit', 'serving', 'servingSizeGrams', 100, 'portionEstimationMethod', 'standardUnit',
    'portionState', 'asServed', 'source', 'manual', 'confidenceScore', 1,
    'createdAt', '2026-10-04T08:00:00.000Z', 'originalValues', '{}'::jsonb,
    'nutrition', '{"energyKcal":100,"protein":0,"carbs":0,"fat":0,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{"iron":0}}'::jsonb
  );
$$;
CREATE FUNCTION tests.availability_current(
    p_id uuid DEFAULT 'a2000000-0000-0000-0000-000000000001'
)
RETURNS jsonb LANGUAGE sql STABLE AS $$
  SELECT version.snapshot FROM public.nutrition_food_definition AS definition
  JOIN public.nutrition_food_version AS version ON version.id = definition.current_version_id
  WHERE definition.id = p_id;
$$;
CREATE FUNCTION tests.availability_meal(p_food jsonb)
RETURNS jsonb LANGUAGE sql IMMUTABLE AS $$
  SELECT tests.availability_food('a2000000-0000-0000-0000-000000000002') || jsonb_build_object(
    'entryType', 'meal', 'componentSnapshots', jsonb_build_array(p_food),
    'componentFoods', jsonb_build_array(jsonb_build_object(
      'id', 'component', 'parentEntryId', 'availability-entry', 'foodId', p_food->'foodId',
      'amount', 1, 'unit', 'serving', 'sortOrder', 0
    ))
  );
$$;
CREATE FUNCTION tests.availability_recall(p_food jsonb)
RETURNS jsonb LANGUAGE sql IMMUTABLE AS $$
  SELECT jsonb_build_object('type', 'DailyRecall', 'periodId', 'availability-period',
    'result', jsonb_build_object('id', 'availability-recall', 'date', '2026-10-04T00:00:00.000',
      'recallMode', 'realtimeRecord', 'studyDaySnapshot', 2,
      'meals', jsonb_build_array(jsonb_build_object(
        'id', 'availability-meal', 'mealType', 'breakfast', 'mealContext', 'home',
        'timezone', 'UTC', 'timePrecision', 'unknown', 'isSkipped', false, 'foods', jsonb_build_array(p_food)
      ))
    )
  );
$$;
CREATE FUNCTION tests.availability_write_recall(
    p_result jsonb, p_time timestamptz DEFAULT '2026-10-04 12:00:00+00',
    p_subject_id uuid DEFAULT 'a1000000-0000-0000-0000-000000000001'
) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    PERFORM public.save_nutrition_recall(
        p_subject_id, p_time, 'availability-intervention', 'availability-task',
        jsonb_set(jsonb_set(p_result, '{result,entryCompletedAt}', to_jsonb(p_time)),
            '{result,date}', to_jsonb(now() - make_interval(
                days => 2 - (p_result #>> '{result,studyDaySnapshot}')::integer
            ))
        ),
        (
            SELECT nutrition_revision FROM public.subject_progress
            WHERE subject_id = p_subject_id AND completed_at = p_time
        )
    );
END;
$$;
CREATE FUNCTION tests.availability_mutate(
    p_food jsonb, p_expected uuid DEFAULT null
)
RETURNS jsonb LANGUAGE sql AS $$
  SELECT public.apply_nutrition_food_mutation(
    'a1000000-0000-0000-0000-000000000001', gen_random_uuid(), (p_food->>'foodId')::uuid,
    COALESCE(p_expected, (SELECT current_version_id FROM public.nutrition_food_definition WHERE id = (p_food->>'foodId')::uuid)),
    p_food
  );
$$;

SELECT ok(public.nutrition_food_snapshot_is_valid(tests.availability_food()), 'availability arrays are optional for known values');

SELECT tests.authenticate_as('availability_owner');
SELECT lives_ok(
    $$SELECT tests.availability_mutate(tests.availability_food())$$,
    'a new definition can store known zero'
);
SELECT is(
    tests.availability_current() #>> '{nutrition,protein}', '0',
    'loading the definition preserves known zero'
);

SELECT lives_ok(
    $$SELECT tests.availability_mutate(jsonb_set(jsonb_set(
        tests.availability_current(), '{nutrition,unavailableNutrients}', '["protein","micros.iron"]'
    ), '{nutrition,partialNutrients}', '["energyKcal"]'))$$,
    'the mutation saves unknown and partial nutrients'
);
SELECT is(
    tests.availability_current() #> '{nutrition,unavailableNutrients}', '["protein","micros.iron"]'::jsonb,
    'loading the definition preserves unavailable nutrients'
);
SELECT is(
    tests.availability_current() #> '{nutrition,partialNutrients}', '["energyKcal"]'::jsonb,
    'loading the definition preserves partial nutrients'
);
SELECT is(
    tests.availability_current() #>> '{nutrition,carbs}', '0',
    'availability metadata preserves other known zeros'
);

-- Reject invalid containers and elements at both write boundaries.
SELECT throws_ok(
    format($$SELECT tests.availability_mutate(%L::jsonb)$$,
        jsonb_set(tests.availability_current(), ARRAY['nutrition', field], invalid)),
    '22023', 'invalid nutrition mutation payload',
    'definition rejects ' || field || ' = ' || invalid::text
)
FROM unnest(ARRAY['unavailableNutrients', 'partialNutrients']) AS field
CROSS JOIN (
    VALUES ('null'::jsonb), ('0'::jsonb), ('"protein"'::jsonb), ('{}'::jsonb),
           ('[0]'::jsonb), ('[{}]'::jsonb), ('[null]'::jsonb)
) AS invalid_values (invalid);

SELECT throws_ok(
    format($$SELECT tests.availability_write_recall(%L::jsonb)$$,
        tests.availability_recall(tests.availability_meal(
            jsonb_set(tests.availability_current(), ARRAY['nutrition', field], invalid)
        ))),
    '22023', 'invalid nutrition recall',
    'nested recall food rejects ' || field || ' = ' || invalid::text
)
FROM unnest(ARRAY['unavailableNutrients', 'partialNutrients']) AS field
CROSS JOIN (
    VALUES ('null'::jsonb), ('0'::jsonb), ('"protein"'::jsonb), ('{}'::jsonb),
           ('[0]'::jsonb), ('[{}]'::jsonb), ('[null]'::jsonb)
) AS invalid_values (invalid);
SELECT is((SELECT count(*) FROM public.nutrition_food_version), 2::bigint, 'invalid mutations create no version');
SELECT is((SELECT count(*) FROM public.subject_progress WHERE result_type = 'DailyRecall'), 0::bigint, 'invalid recalls create no progress');

SELECT lives_ok(
    $$SELECT tests.availability_write_recall(tests.availability_recall(tests.availability_current()))$$,
    'the recall RPC accepts availability metadata'
);
SELECT lives_ok(
    $$SELECT tests.availability_write_recall(jsonb_set(
        tests.availability_recall(jsonb_set(jsonb_set(tests.availability_current(), '{amount}', '2'),
            '{nutrition,energyKcal}', '200')),
        '{result,studyDaySnapshot}', '1'
    ), '2026-10-04 14:00:00+00')$$,
    'the recall RPC accepts an occurrence-scaled snapshot for the previous day'
);
SELECT lives_ok(
    $$SELECT public.apply_nutrition_food_mutation(
        'a1000000-0000-0000-0000-000000000001', gen_random_uuid(), 'a2000000-0000-0000-0000-000000000001',
        (tests.availability_current()->>'foodVersionId')::uuid,
        tests.availability_current() || '{"name":"Edited availability food"}',
        false, '{"taskId":"availability-task","interventionId":"availability-intervention","periodId":"availability-period","completedAt":"2026-10-04 14:00:00+00","studyDaySnapshot":1,"nutritionRevision":0}',
        2, null, 'availability-entry'
    )$$,
    'the historical mutation updates the selected recall and propagates to today'
);
SELECT is((
    SELECT (result #>> '{result,meals,0,foods,0,nutrition,energyKcal}')::numeric
    FROM public.subject_progress WHERE completed_at = '2026-10-04 14:00:00+00'
), 200::numeric, 'historical propagation scales the partial value');
SELECT is((
    SELECT result #> '{result,meals,0,foods,0,nutrition,unavailableNutrients}'
    FROM public.subject_progress WHERE completed_at = '2026-10-04 14:00:00+00'
), '["protein","micros.iron"]'::jsonb, 'historical propagation preserves unavailable nutrients');
SELECT is((
    SELECT result #> '{result,meals,0,foods,0,nutrition,partialNutrients}'
    FROM public.subject_progress WHERE completed_at = '2026-10-04 12:00:00+00'
), '["energyKcal"]'::jsonb, 'current-day propagation preserves partial nutrients');
SELECT is((
    SELECT nutrition_revision FROM public.subject_progress WHERE completed_at = '2026-10-04 12:00:00+00'
), 1::bigint, 'food propagation advances the affected recall revision');

SELECT throws_ok(
    $$SELECT tests.availability_write_recall(tests.availability_recall(jsonb_set(
        tests.availability_current(), '{foodId}', '"a2000000-0000-0000-0000-000000000099"'
    )))$$,
    '22023', 'nutrition food version does not match food',
    'the recall RPC rejects an unrelated food and version pair'
);
SELECT lives_ok(
    $$SELECT tests.availability_mutate(tests.availability_meal(tests.availability_current()))$$,
    'a saved meal can reference a stored ingredient version'
);
SELECT throws_ok(
    $$SELECT tests.availability_write_recall(tests.availability_recall(jsonb_set(
        tests.availability_current('a2000000-0000-0000-0000-000000000002'),
        '{componentSnapshots,0,foodVersionId}', '"a3000000-0000-0000-0000-000000000099"'
    )))$$,
    '22023', 'nutrition food version does not exist',
    'the recall RPC rejects an unresolved nested food version'
);
SELECT lives_ok(
    $$SELECT tests.availability_write_recall(tests.availability_recall(
        tests.availability_current('a2000000-0000-0000-0000-000000000002')
    ))$$,
    'the recall RPC accepts the stored meal and ingredient versions'
);
SELECT set_config('tests.availability_foreign_version', tests.availability_current()->>'foodVersionId', true);

SELECT tests.authenticate_as('availability_other');
SELECT throws_ok(
    $$SELECT tests.availability_write_recall(tests.availability_recall(tests.availability_food()))$$,
    '42501', 'nutrition progress subject is not owned by caller',
    'the recall RPC requires subject ownership'
);
SELECT throws_ok(
    $$SELECT tests.availability_write_recall(tests.availability_recall(jsonb_set(
        tests.availability_food(), '{foodVersionId}', to_jsonb(current_setting('tests.availability_foreign_version'))
    )), p_subject_id => 'a1000000-0000-0000-0000-000000000002')$$,
    '42501', 'nutrition definition subject is not owned by caller',
    'a recall cannot reference another subject''s food version'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
        'a1000000-0000-0000-0000-000000000002', gen_random_uuid(),
        'a2000000-0000-0000-0000-000000000002', null,
        tests.availability_meal(jsonb_set(
            tests.availability_food(), '{foodVersionId}', to_jsonb(current_setting('tests.availability_foreign_version'))
        ))
    )$$,
    '42501', 'nutrition definition subject is not owned by caller',
    'a saved meal cannot reference another subject''s food version'
);

RESET ROLE;
SELECT throws_ok(
    $$UPDATE public.nutrition_food_version
      SET snapshot = jsonb_set(snapshot, '{nutrition,unavailableNutrients}', '[null]')
      WHERE id = current_setting('tests.availability_foreign_version')::uuid$$,
    '22023', 'invalid nutrition food snapshot',
    'the food version table validates direct privileged changes'
);
SELECT is(
    (SELECT count(*) FROM studyu_private.nutrition_maintenance_context),
    0::bigint, 'successful and rejected writes leave no authorization context'
);

SELECT * FROM finish();
ROLLBACK;
