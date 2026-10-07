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
    '[]',
    '[]',
    '{}',
    '{}',
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
    ARRAY[]::text[]
),
(
    'a1000000-0000-0000-0000-000000000002',
    'a0000000-0000-0000-0000-000000000001',
    tests.get_supabase_uid('availability_other'),
    now() - interval '2 days',
    ARRAY[]::text[]
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
CREATE FUNCTION tests.availability_intent(p_value jsonb)
RETURNS jsonb LANGUAGE sql IMMUTABLE AS $$
  SELECT p_value || '{"nutritionAvailabilityWriteIntent":"explicit-v1"}'::jsonb;
$$;
CREATE FUNCTION tests.availability_current(
    p_id uuid DEFAULT 'a2000000-0000-0000-0000-000000000001'
)
RETURNS jsonb LANGUAGE sql STABLE AS $$
  SELECT version.snapshot FROM public.nutrition_food_definition AS definition
  JOIN public.nutrition_food_version AS version ON version.id = definition.current_version_id
  WHERE definition.id = p_id;
$$;
CREATE FUNCTION tests.availability_old_food(p_food jsonb)
RETURNS jsonb LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
  v_result jsonb := jsonb_set(p_food, '{nutrition}',
    (p_food->'nutrition') - 'unavailableNutrients' - 'partialNutrients');
BEGIN
  IF jsonb_typeof(p_food->'componentSnapshots') = 'array' THEN
    v_result := jsonb_set(v_result, '{componentSnapshots}', (
      SELECT COALESCE(jsonb_agg(tests.availability_old_food(component)), '[]'::jsonb)
      FROM jsonb_array_elements(p_food->'componentSnapshots') AS component
    ));
  END IF;
  RETURN v_result;
END;
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
        'timezone', 'UTC', 'isSkipped', false, 'foods', jsonb_build_array(p_food)
      ))
    )
  );
$$;
CREATE FUNCTION tests.availability_write_recall(
    p_result jsonb, p_time timestamptz DEFAULT '2026-10-04 12:00:00+00'
)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO public.subject_progress (subject_id, completed_at, task_id, intervention_id, result_type, result)
  VALUES ('a1000000-0000-0000-0000-000000000001', p_time, 'availability-task', 'availability-intervention', 'DailyRecall', p_result)
  ON CONFLICT (subject_id, completed_at) DO UPDATE SET result = EXCLUDED.result;
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

SELECT ok(public.nutrition_food_snapshot_is_valid(tests.availability_food()), 'absent legacy availability fields are valid');
SELECT ok(public.nutrition_food_snapshot_is_valid(jsonb_set(
    tests.availability_food(), '{nutrition,unavailableNutrients}', '[]'
)), 'empty availability arrays are valid');
SELECT ok(public.nutrition_food_snapshot_is_valid(jsonb_set(jsonb_set(
    tests.availability_food(),
    '{nutrition,unavailableNutrients}',
    '["protein","micros.iron"]'
), '{nutrition,partialNutrients}', '["energyKcal"]')), 'string arrays for both states are valid');
SELECT
    ok(NOT public.nutrition_food_snapshot_is_valid(jsonb_set(
        tests.availability_food(), ARRAY['nutrition', field], invalid
    )), 'snapshot validator rejects ' || field || ' = ' || invalid::text)
FROM unnest(ARRAY['unavailableNutrients', 'partialNutrients']) AS field
CROSS JOIN (
    VALUES ('null'::jsonb), ('0'::jsonb), ('"protein"'::jsonb), ('{}'::jsonb),
    ('[0]'::jsonb), ('[{}]'::jsonb), ('[null]'::jsonb)
) AS invalid_values (invalid);

SELECT tests.authenticate_as('availability_owner');
SET LOCAL row_security = on;
SELECT lives_ok($sql$ SELECT tests.availability_mutate(tests.availability_food()) $sql$, 'legacy definition writes remain valid');
SELECT is(tests.availability_current() - 'foodVersionId', tests.availability_food() - 'foodVersionId', 'legacy snapshot identity and known zero remain unchanged');
SELECT lives_ok($sql$ SELECT tests.availability_write_recall(tests.availability_recall(tests.availability_current())) $sql$, 'legacy recall first write remains valid');
SELECT lives_ok($sql$ SELECT tests.availability_write_recall(tests.availability_recall(tests.availability_current())) $sql$, 'unchanged legacy recall remains valid');

-- Every invalid container and element must fail before either storage boundary changes.
SELECT
    throws_ok(
        format(
            $sql$ SELECT tests.availability_mutate(%L::jsonb) $sql$,
            tests.availability_intent(
                jsonb_set(
                    tests.availability_current(),
                    ARRAY['nutrition', field],
                    invalid
                )
            )
        ),
        '22023',
        'invalid nutrition availability metadata',
        'mutation rejects ' || field || ' = ' || invalid::text
    )
FROM unnest(ARRAY['unavailableNutrients', 'partialNutrients']) AS field
CROSS JOIN (
    VALUES ('null'::jsonb), ('0'::jsonb), ('"protein"'::jsonb), ('{}'::jsonb),
    ('[0]'::jsonb), ('[{}]'::jsonb), ('[null]'::jsonb)
) AS invalid_values (invalid);
SELECT is((SELECT count(*)::integer FROM public.nutrition_food_version), 1, 'invalid mutations create no versions');
SELECT is(tests.availability_current() - 'foodVersionId', tests.availability_food() - 'foodVersionId', 'invalid mutations leave the current snapshot unchanged');

SELECT
    throws_ok(
        format(
            $sql$ SELECT tests.availability_write_recall(%L::jsonb, '2026-10-04 13:00:00+00') $sql$,
            tests.availability_intent(tests.availability_recall(jsonb_set(
                tests.availability_current(), ARRAY['nutrition', field], invalid
            )))
        ),
        '22023',
        'invalid nutrition availability metadata',
        'recall rejects ' || field || ' = ' || invalid::text
    )
FROM unnest(ARRAY['unavailableNutrients', 'partialNutrients']) AS field
CROSS JOIN (
    VALUES ('null'::jsonb), ('0'::jsonb), ('"protein"'::jsonb), ('{}'::jsonb),
    ('[0]'::jsonb), ('[{}]'::jsonb), ('[null]'::jsonb)
) AS invalid_values (invalid);
SELECT
    throws_ok(
        format(
            $sql$ SELECT tests.availability_write_recall(%L::jsonb, '2026-10-04 13:00:00+00') $sql$,
            tests.availability_intent(
                tests.availability_recall(tests.availability_meal(jsonb_set(
                    tests.availability_current(),
                    ARRAY['nutrition', field],
                    invalid
                )))
            )
        ),
        '22023',
        'invalid nutrition availability metadata',
        'nested recall rejects ' || field || ' = ' || invalid::text
    )
FROM unnest(ARRAY['unavailableNutrients', 'partialNutrients']) AS field
CROSS JOIN (
    VALUES ('null'::jsonb), ('0'::jsonb), ('"protein"'::jsonb), ('{}'::jsonb),
    ('[0]'::jsonb), ('[{}]'::jsonb), ('[null]'::jsonb)
) AS invalid_values (invalid);
SELECT is((SELECT count(*)::integer FROM public.subject_progress), 1, 'invalid recalls insert no progress');
SELECT is((SELECT result FROM public.subject_progress), tests.availability_recall(tests.availability_current()), 'invalid recalls leave existing progress unchanged');
SELECT throws_ok($sql$ SELECT tests.availability_mutate(tests.availability_intent(tests.availability_meal(
  jsonb_set(tests.availability_current(), '{nutrition,partialNutrients}', '[0]')
))) $sql$, '22023', 'invalid nutrition availability metadata', 'nested definition metadata is validated');

SELECT lives_ok($sql$ SELECT tests.availability_mutate(tests.availability_intent(jsonb_set(jsonb_set(
  tests.availability_current(), '{nutrition,unavailableNutrients}', '["protein","micros.iron"]'
), '{nutrition,partialNutrients}', '["energyKcal"]'))) $sql$, 'supported writer can set unknown and partial nutrients');
SELECT is(tests.availability_current() #> '{nutrition,unavailableNutrients}', '["protein","micros.iron"]'::jsonb, 'unavailable state survives version reload');
SELECT is(tests.availability_current() #> '{nutrition,partialNutrients}', '["energyKcal"]'::jsonb, 'partial state survives version reload');
SELECT ok(NOT tests.availability_current() ? 'nutritionAvailabilityWriteIntent', 'version snapshots do not store write intent');
SELECT throws_ok(
    $sql$ SELECT tests.availability_mutate(tests.availability_old_food(tests.availability_current())) $sql$,
    '22023',
    'nutrition availability write intent is required',
    'older writer cannot strip current-version metadata'
);
SELECT is((SELECT count(*)::integer FROM public.nutrition_food_version), 2, 'rejected old mutation is atomic');
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(tests.availability_recall(tests.availability_old_food(tests.availability_current())), '2026-10-04 13:00:00+00') $sql$,
    '22023',
    'nutrition availability write intent is required',
    'first recall cannot omit referenced version metadata'
);
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(tests.availability_recall(tests.availability_meal(tests.availability_old_food(tests.availability_current()))), '2026-10-04 13:00:00+00') $sql$,
    '22023',
    'nutrition availability write intent is required',
    'first recall checks nested version references'
);
SELECT throws_ok(
    $sql$ SELECT tests.availability_mutate(tests.availability_meal(tests.availability_old_food(tests.availability_current()))) $sql$,
    '22023',
    'nutrition availability write intent is required',
    'new meal definition checks nested version references'
);
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(tests.availability_recall(jsonb_set(tests.availability_old_food(tests.availability_current()), '{foodVersionId}', '"a3000000-0000-0000-0000-000000000099"')), '2026-10-04 13:00:00+00') $sql$,
    '22023',
    'nutrition availability write intent is required',
    'provisional version cannot bypass a metadata-bearing definition'
);

SELECT lives_ok($sql$ SELECT tests.availability_write_recall(tests.availability_intent(tests.availability_recall(tests.availability_current())), '2026-10-04 13:00:00+00') $sql$, 'supported first recall stores availability');
SELECT is((
    SELECT result #> '{result,meals,0,foods,0,nutrition,unavailableNutrients}'
    FROM public.subject_progress
    WHERE completed_at = '2026-10-04 13:00:00+00'
), '["protein","micros.iron"]'::jsonb, 'first recall availability survives reload');
DELETE FROM public.subject_progress
WHERE completed_at = '2026-10-04 13:00:00+00';
SELECT lives_ok($sql$ SELECT tests.availability_write_recall(tests.availability_intent(tests.availability_recall(tests.availability_current()))) $sql$, 'supported recall upsert stores availability');
SELECT lives_ok($sql$ INSERT INTO public.subject_progress (subject_id, completed_at, task_id, intervention_id, result_type, result)
  VALUES ('a1000000-0000-0000-0000-000000000001', '2026-10-04 12:00:00+00', 'availability-task', 'availability-intervention', 'DailyRecall',
    tests.availability_intent(tests.availability_recall(tests.availability_old_food(tests.availability_current()))))
  ON CONFLICT (subject_id, completed_at) DO NOTHING
$sql$, 'supported conflict-ignore write remains valid');
SELECT throws_ok($sql$ UPDATE public.subject_progress SET result = tests.availability_recall(tests.availability_old_food(tests.availability_current()))
  WHERE subject_id = 'a1000000-0000-0000-0000-000000000001' AND completed_at = '2026-10-04 12:00:00+00'
$sql$, '22023', 'nutrition availability write intent is required', 'conflict-ignore intent does not authorize a later unsupported update');
SELECT ok(NOT (SELECT result ? 'nutritionAvailabilityWriteIntent' FROM public.subject_progress), 'recall write intent is transient');
SELECT is((SELECT result #> '{result,meals,0,foods,0,nutrition,partialNutrients}' FROM public.subject_progress), '["energyKcal"]'::jsonb, 'partial state survives recall reload');
SELECT lives_ok($sql$ SELECT tests.availability_write_recall(tests.availability_intent(jsonb_set(
  tests.availability_recall(jsonb_set(jsonb_set(tests.availability_current(), '{amount}', '2'), '{nutrition,energyKcal}', '200')),
  '{result,studyDaySnapshot}', '1'
)), '2026-10-04 14:00:00+00') $sql$, 'supported historical recall stores an occurrence-scaled snapshot');
SELECT lives_ok($sql$ SELECT public.apply_nutrition_food_mutation(
  'a1000000-0000-0000-0000-000000000001', gen_random_uuid(), 'a2000000-0000-0000-0000-000000000001',
  (tests.availability_current()->>'foodVersionId')::uuid,
  tests.availability_intent(tests.availability_current() || '{"name":"Edited availability food"}'),
  false, '{"taskId":"availability-task","interventionId":"availability-intervention","periodId":"availability-period","completedAt":"2026-10-04 14:00:00+00","studyDaySnapshot":1}',
  2, null, 'availability-entry'
) $sql$, 'supported historical mutation retains guarded propagation');
SELECT is((
    SELECT result #>> '{result,meals,0,foods,0,amount}'
    FROM public.subject_progress
    WHERE completed_at = '2026-10-04 14:00:00+00'
), '2', 'historical propagation preserves occurrence quantity');
SELECT is((
    SELECT (result #>> '{result,meals,0,foods,0,nutrition,energyKcal}')::numeric
    FROM public.subject_progress
    WHERE completed_at = '2026-10-04 14:00:00+00'
), 200::numeric, 'historical propagation scales the partial numeric subtotal');
SELECT is((
    SELECT result #> '{result,meals,0,foods,0,nutrition,unavailableNutrients}'
    FROM public.subject_progress
    WHERE completed_at = '2026-10-04 14:00:00+00'
), '["protein","micros.iron"]'::jsonb, 'historical propagation preserves unavailable strings');
SELECT is((
    SELECT result #> '{result,meals,0,foods,0,nutrition,partialNutrients}'
    FROM public.subject_progress
    WHERE completed_at = '2026-10-04 14:00:00+00'
), '["energyKcal"]'::jsonb, 'historical propagation preserves partial strings');
DELETE FROM public.subject_progress
WHERE completed_at = '2026-10-04 14:00:00+00';
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(tests.availability_recall(tests.availability_old_food(tests.availability_current()))) $sql$,
    '22023',
    'nutrition availability write intent is required',
    'older whole-recall serializer cannot strip metadata'
);
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(jsonb_set(tests.availability_recall(tests.availability_food()), '{result,meals}', '[]')) $sql$,
    '22023',
    'nutrition availability write intent is required',
    'older whole-recall serializer cannot clear metadata by removing foods'
);
SELECT lives_ok($sql$ SELECT tests.availability_write_recall(tests.availability_intent(tests.availability_recall(tests.availability_meal(tests.availability_current())))) $sql$, 'supported recall stores nested availability');
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(tests.availability_recall(tests.availability_meal(tests.availability_old_food(tests.availability_current())))) $sql$,
    '22023',
    'nutrition availability write intent is required',
    'older whole-recall serializer cannot strip nested metadata'
);
SELECT lives_ok($sql$ SELECT tests.availability_mutate(tests.availability_intent(tests.availability_meal(tests.availability_current()))) $sql$, 'supported meal stores nested availability');
SELECT throws_ok(
    $sql$ SELECT tests.availability_mutate(tests.availability_old_food(tests.availability_current('a2000000-0000-0000-0000-000000000002'))) $sql$,
    '22023',
    'nutrition availability write intent is required',
    'older mutation cannot strip nested saved-meal metadata'
);

SELECT lives_ok($sql$ SELECT tests.availability_write_recall(tests.availability_intent(tests.availability_recall(tests.availability_old_food(tests.availability_current())))) $sql$, 'supported recall can intentionally clear both states');
SELECT is((SELECT result #>> '{result,meals,0,foods,0,nutrition,protein}' FROM public.subject_progress), '0', 'intentional recall clearing preserves known zero');
SELECT lives_ok($sql$ SELECT tests.availability_mutate(tests.availability_intent(tests.availability_old_food(tests.availability_current()))) $sql$, 'supported mutation can intentionally clear both states');
SELECT is(tests.availability_current() -> 'nutrition', tests.availability_food() -> 'nutrition', 'intentional definition clearing restores complete zero');
SELECT lives_ok($sql$ SELECT tests.availability_mutate(tests.availability_current()) $sql$, 'ordinary older definition write resumes for metadata-free data');
SELECT lives_ok($sql$ SELECT tests.availability_mutate(tests.availability_intent(jsonb_set(jsonb_set(
  tests.availability_current(), '{nutrition,unavailableNutrients}', '[]'
), '{nutrition,partialNutrients}', '[]'))) $sql$, 'supported explicit empty arrays are valid');
SELECT is(tests.availability_current() #>> '{nutrition,protein}', '0', 'empty availability arrays preserve complete zero');

SELECT throws_ok(
    $sql$ SELECT tests.availability_mutate(tests.availability_intent(tests.availability_current()), 'a3000000-0000-0000-0000-000000000001') $sql$,
    '40001',
    'stale nutrition definition version',
    'write intent does not bypass revision checks'
);
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(tests.availability_intent(tests.availability_recall(jsonb_set(tests.availability_current(), '{foodId}', '"a2000000-0000-0000-0000-000000000099"'))), '2026-10-04 13:00:00+00') $sql$,
    '22023',
    'nutrition food version does not match food',
    'write intent does not bypass linked-version checks'
);
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(tests.availability_intent(jsonb_set(tests.availability_recall(tests.availability_current()), '{result,studyDaySnapshot}', '0')), '2026-10-04 13:00:00+00') $sql$,
    '22023',
    'nutrition recall study day is not writable',
    'write intent does not bypass day checks'
);
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(tests.availability_recall(tests.availability_current()) || '{"nutritionAvailabilityWriteIntent":"unsupported"}') $sql$,
    '22023',
    'invalid nutrition availability write intent',
    'unknown recall intent is rejected'
);
SELECT throws_ok(
    $sql$ SELECT tests.availability_mutate(tests.availability_current() || '{"nutritionAvailabilityWriteIntent":"unsupported"}') $sql$,
    '22023',
    'invalid nutrition availability write intent',
    'unknown mutation intent is rejected'
);

-- Private transaction context must not be accessible or replaceable with a setting.
SELECT throws_ok(
    $sql$ INSERT INTO studyu_private.nutrition_maintenance_context VALUES (txid_current(), 'a1000000-0000-0000-0000-000000000001', 'availability') $sql$,
    '42501',
    'permission denied for schema studyu_private',
    'caller cannot forge availability transaction context'
);
SELECT set_config('studyu.nutrition_maintenance', 'mutation:a1000000-0000-0000-0000-000000000001', true);
SELECT throws_ok(
    $sql$ SELECT tests.availability_write_recall(tests.availability_intent(jsonb_set(tests.availability_recall(tests.availability_current()), '{result,studyDaySnapshot}', '0')), '2026-10-04 13:00:00+00') $sql$,
    '22023',
    'nutrition recall study day is not writable',
    'caller-controlled maintenance setting cannot bypass day checks'
);
SELECT throws_ok(
    $sql$ SELECT studyu_private.apply_nutrition_food_mutation_without_availability('a1000000-0000-0000-0000-000000000001', gen_random_uuid(), 'a2000000-0000-0000-0000-000000000001', null, tests.availability_food()) $sql$,
    '42501',
    'permission denied for schema studyu_private',
    'caller cannot bypass the public availability wrapper'
);

SELECT throws_ok($sql$ INSERT INTO studyu_private.nutrition_recall_write_intent
  VALUES (txid_current(), 'a1000000-0000-0000-0000-000000000001', '2026-10-04 12:00:00+00', 'availability-task', 'availability-intervention', '{}')
$sql$, '42501', 'permission denied for schema studyu_private', 'caller cannot forge row-bound recall intent');
SELECT set_config('tests.availability_foreign_version', tests.availability_current() ->> 'foodVersionId', true);
SELECT set_config('tests.availability_foreign_metadata_version', tests.availability_current('a2000000-0000-0000-0000-000000000002') ->> 'foodVersionId', true);
SELECT tests.authenticate_as('availability_other');
SELECT throws_ok($sql$ SELECT tests.availability_write_recall(tests.availability_recall(jsonb_set(
  tests.availability_food('a2000000-0000-0000-0000-000000000002'), '{foodVersionId}', to_jsonb(current_setting('tests.availability_foreign_metadata_version'))
))) $sql$, '42501', 'nutrition progress subject is not owned by caller', 'foreign subject ownership is checked before unsupported availability reads');
SELECT throws_ok($sql$ SELECT tests.availability_write_recall(tests.availability_intent(tests.availability_recall(jsonb_set(
  tests.availability_food('a2000000-0000-0000-0000-000000000002'), '{foodVersionId}', to_jsonb(current_setting('tests.availability_foreign_metadata_version'))
)))) $sql$, '42501', 'nutrition progress subject is not owned by caller', 'supported intent does not bypass ownership before reference reads');
SELECT throws_ok(
    $sql$ SELECT public.apply_nutrition_food_mutation('a1000000-0000-0000-0000-000000000001', gen_random_uuid(), 'a2000000-0000-0000-0000-000000000001', null, tests.availability_intent(tests.availability_food())) $sql$,
    '42501',
    'nutrition definition subject is not owned by caller',
    'write intent does not bypass subject ownership'
);
SELECT throws_ok($sql$ INSERT INTO public.subject_progress (subject_id, completed_at, task_id, intervention_id, result_type, result)
  VALUES ('a1000000-0000-0000-0000-000000000002', '2026-10-04 14:00:00+00', 'availability-task', 'availability-intervention', 'DailyRecall',
    tests.availability_intent(tests.availability_recall(jsonb_set(tests.availability_food(), '{foodVersionId}', to_jsonb(current_setting('tests.availability_foreign_version'))))))
$sql$, '42501', 'nutrition definition subject is not owned by caller', 'cross-subject version reference is rejected');

RESET ROLE;
SELECT is((SELECT count(*)::integer FROM studyu_private.nutrition_maintenance_context), 0, 'successful and rejected writes leave no transaction context');
SELECT is((SELECT count(*)::integer FROM studyu_private.nutrition_recall_write_intent), 0, 'successful and rejected upserts leave no recall intent');
SELECT is((SELECT count(*)::integer FROM public.subject_progress), 1, 'rejected first writes create no progress');
-- Direct service writes also validate availability at the version storage boundary.
SELECT throws_ok(
    $sql$ UPDATE public.nutrition_food_version SET snapshot = jsonb_set(snapshot, '{nutrition,unavailableNutrients}', '[null]') WHERE food_id = 'a2000000-0000-0000-0000-000000000001' $sql$,
    '22023',
    'invalid nutrition availability metadata',
    'version storage rejects malformed unavailable elements'
);
SELECT throws_ok(
    $sql$ UPDATE public.nutrition_food_version SET snapshot = jsonb_set(snapshot, '{nutrition,partialNutrients}', '{}') WHERE food_id = 'a2000000-0000-0000-0000-000000000001' $sql$,
    '22023',
    'invalid nutrition availability metadata',
    'version storage rejects malformed partial containers'
);

SELECT throws_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = jsonb_set(snapshot, '{componentSnapshots,0,nutrition,partialNutrients}', '[null]')
  WHERE food_id = 'a2000000-0000-0000-0000-000000000002'
$sql$, '22023', 'invalid nutrition availability metadata', 'version storage rejects malformed nested metadata');


-- Direct service writers use the same intent contract as the mutation RPC.
GRANT USAGE ON SCHEMA tests TO service_role;
GRANT EXECUTE ON FUNCTION tests.availability_food(uuid),
tests.availability_current(uuid),
tests.availability_old_food(jsonb), tests.availability_intent(jsonb),
tests.availability_meal(jsonb) TO service_role;
SET LOCAL ROLE service_role;
INSERT INTO public.nutrition_food_definition (
    id, subject_id, kind, current_version_id
)
VALUES (
    'a2000000-0000-0000-0000-000000000003',
    'a1000000-0000-0000-0000-000000000001',
    'food',
    'a3000000-0000-0000-0000-000000000010'
),
(
    'a2000000-0000-0000-0000-000000000004',
    'a1000000-0000-0000-0000-000000000002',
    'food',
    'a3000000-0000-0000-0000-000000000012'
),
(
    'a2000000-0000-0000-0000-000000000005',
    'a1000000-0000-0000-0000-000000000001',
    'food',
    'a3000000-0000-0000-0000-000000000015'
);
SELECT lives_ok($sql$ INSERT INTO public.nutrition_food_version (id, food_id, version_number, mutation_id, snapshot)
  VALUES ('a3000000-0000-0000-0000-000000000010', 'a2000000-0000-0000-0000-000000000003', 1, gen_random_uuid(),
    jsonb_set(tests.availability_food('a2000000-0000-0000-0000-000000000003'), '{foodVersionId}', '"a3000000-0000-0000-0000-000000000010"'))
$sql$, 'service legacy version insert preserves metadata-free writes');
INSERT INTO public.nutrition_food_version (
    id, food_id, version_number, mutation_id, snapshot
)
VALUES (
    'a3000000-0000-0000-0000-000000000012',
    'a2000000-0000-0000-0000-000000000004',
    1,
    gen_random_uuid(),
    jsonb_set(
        tests.availability_food('a2000000-0000-0000-0000-000000000004'),
        '{foodVersionId}',
        '"a3000000-0000-0000-0000-000000000012"'
    )
);
SELECT lives_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = tests.availability_intent(jsonb_set(jsonb_set(
  snapshot, '{nutrition,unavailableNutrients}', '["protein"]'
), '{nutrition,partialNutrients}', '["energyKcal"]')) WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, 'service explicit intent can set unavailable and partial state');
SELECT ok(NOT (
    SELECT snapshot ? 'nutritionAvailabilityWriteIntent'
    FROM public.nutrition_food_version
    WHERE id = 'a3000000-0000-0000-0000-000000000010'
), 'service update does not persist intent');
SELECT throws_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = tests.availability_old_food(snapshot)
  WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, '22023', 'nutrition availability write intent is required', 'service unsupported update cannot strip availability');
SELECT throws_ok($sql$ INSERT INTO public.nutrition_food_version (id, food_id, version_number, mutation_id, snapshot)
  VALUES ('a3000000-0000-0000-0000-000000000011', 'a2000000-0000-0000-0000-000000000003', 2, gen_random_uuid(),
    jsonb_set(tests.availability_old_food(tests.availability_current('a2000000-0000-0000-0000-000000000003')), '{foodVersionId}', '"a3000000-0000-0000-0000-000000000011"'))
$sql$, '22023', 'nutrition availability write intent is required', 'service unsupported insert cannot replace metadata-bearing current version');
SELECT lives_ok($sql$ INSERT INTO public.nutrition_food_version (id, food_id, version_number, mutation_id, snapshot)
  VALUES ('a3000000-0000-0000-0000-000000000011', 'a2000000-0000-0000-0000-000000000003', 2, gen_random_uuid(),
    tests.availability_intent(jsonb_set(tests.availability_old_food(tests.availability_current('a2000000-0000-0000-0000-000000000003')), '{foodVersionId}', '"a3000000-0000-0000-0000-000000000011"')))
$sql$, 'service explicit insert can intentionally clear availability');
SELECT ok(NOT (
    SELECT snapshot ? 'nutritionAvailabilityWriteIntent'
    FROM public.nutrition_food_version
    WHERE id = 'a3000000-0000-0000-0000-000000000011'
), 'service insert does not persist intent');
SELECT is((
    SELECT (snapshot #>> '{nutrition,protein}')::numeric
    FROM public.nutrition_food_version
    WHERE id = 'a3000000-0000-0000-0000-000000000011'
), 0::numeric, 'service intentional insert preserves known zero');
SELECT throws_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = tests.availability_old_food(snapshot)
  WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, '22023', 'nutrition availability write intent is required', 'service intent cannot be replayed from storage or a prior statement');
SELECT lives_ok($sql$ UPDATE public.nutrition_food_version SET mutation_id = gen_random_uuid()
  WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, 'service unrelated update with unchanged metadata-bearing snapshot remains valid');
SELECT throws_ok($sql$ INSERT INTO public.nutrition_food_version (id, food_id, version_number, mutation_id, snapshot)
  VALUES ('a3000000-0000-0000-0000-000000000015', 'a2000000-0000-0000-0000-000000000005', 1, gen_random_uuid(),
    jsonb_set(jsonb_set(tests.availability_meal(tests.availability_old_food((SELECT snapshot FROM public.nutrition_food_version WHERE id = 'a3000000-0000-0000-0000-000000000010'))),
      '{foodId}', '"a2000000-0000-0000-0000-000000000005"'), '{foodVersionId}', '"a3000000-0000-0000-0000-000000000015"'))
$sql$, '22023', 'nutrition availability write intent is required', 'service first insert cannot omit nested referenced availability');
INSERT INTO public.nutrition_food_version (
    id, food_id, version_number, mutation_id, snapshot
)
VALUES (
    'a3000000-0000-0000-0000-000000000015',
    'a2000000-0000-0000-0000-000000000005',
    1,
    gen_random_uuid(),
    jsonb_set(
        tests.availability_food('a2000000-0000-0000-0000-000000000005'),
        '{foodVersionId}',
        '"a3000000-0000-0000-0000-000000000015"'
    )
);
SELECT throws_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = jsonb_set(snapshot, '{nutrition,partialNutrients}', '[0]')
  WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, '22023', 'invalid nutrition availability metadata', 'service storage rejects malformed metadata before intent handling');
SELECT throws_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = snapshot || '{"nutritionAvailabilityWriteIntent":"unsupported"}'
  WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, '22023', 'invalid nutrition availability write intent', 'service storage rejects unsupported intent');
SELECT throws_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = tests.availability_intent(jsonb_set(
  snapshot, '{foodVersionId}', '"a3000000-0000-0000-0000-000000000011"'
)) WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, '22023', 'nutrition food version does not match food', 'service intent cannot bypass stored version identity');
SELECT throws_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = tests.availability_intent(
  jsonb_set(jsonb_set(tests.availability_meal(jsonb_set(tests.availability_current(), '{foodId}', '"a2000000-0000-0000-0000-000000000099"')),
    '{foodId}', '"a2000000-0000-0000-0000-000000000003"'), '{foodVersionId}', '"a3000000-0000-0000-0000-000000000010"')
) WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, '22023', 'nutrition food version does not match food', 'service intent cannot bypass nested version linkage');
SELECT throws_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = tests.availability_intent(
  snapshot || jsonb_build_object('componentSnapshots', jsonb_build_array(tests.availability_current()))
) WHERE id = 'a3000000-0000-0000-0000-000000000012'
$sql$, '42501', 'nutrition definition subject is not owned by caller', 'service nested references cannot cross subject ownership');
SELECT throws_ok($sql$ INSERT INTO public.nutrition_food_version (id, food_id, version_number, mutation_id, snapshot)
  VALUES ('a3000000-0000-0000-0000-000000000013', 'a2000000-0000-0000-0000-000000000004', 2, gen_random_uuid(),
    jsonb_set(jsonb_set(tests.availability_meal(tests.availability_old_food((SELECT snapshot FROM public.nutrition_food_version WHERE id = 'a3000000-0000-0000-0000-000000000010'))),
      '{foodId}', '"a2000000-0000-0000-0000-000000000004"'), '{foodVersionId}', '"a3000000-0000-0000-0000-000000000013"'))
$sql$, '42501', 'nutrition definition subject is not owned by caller', 'service first insert validates nested subject references');
SELECT lives_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = tests.availability_intent(tests.availability_old_food(snapshot))
  WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, 'service explicit update can intentionally clear both states');
SELECT is((
    SELECT (snapshot #>> '{nutrition,protein}')::numeric
    FROM public.nutrition_food_version
    WHERE id = 'a3000000-0000-0000-0000-000000000010'
), 0::numeric, 'service intentional update preserves known zero');
SELECT lives_ok($sql$ UPDATE public.nutrition_food_version SET snapshot = snapshot || '{"name":"Legacy service edit"}'
  WHERE id = 'a3000000-0000-0000-0000-000000000010'
$sql$, 'service legacy snapshot edits remain valid after intentional clearing');
SELECT is((
    SELECT count(*)::integer FROM public.nutrition_food_version
    WHERE food_id = 'a2000000-0000-0000-0000-000000000003'
), 2, 'service rejected writes create no extra versions');
RESET ROLE;
SELECT is((SELECT count(*)::integer FROM studyu_private.nutrition_maintenance_context), 0, 'service writes leave no authorization context');

SELECT * FROM finish();
ROLLBACK;
