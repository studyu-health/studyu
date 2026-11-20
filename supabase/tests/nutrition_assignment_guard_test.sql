BEGIN;

SELECT plan(5);
SELECT tests.create_supabase_user('nutrition_assignment_owner', 'nutrition_assignment_owner@studyu.health');

INSERT INTO public.study (
    id, user_id, title, status, contact, description, icon_name, questionnaire,
    eligibility_criteria, observations, interventions, consent, schedule, report_specification,
    results
)
SELECT
    'aa710000-0000-4000-8000-000000000001',
    tests.get_supabase_uid('nutrition_assignment_owner'), 'Nutrition enrollment', 'draft',
    contact, description, icon_name, questionnaire, eligibility_criteria,
    '[{"id":"nutrition-task","type":"nutrition"}]',
    interventions, consent, schedule, report_specification, results
FROM public.study
WHERE id = '22222222-2222-4222-8222-222222222222';

SELECT tests.authenticate_as('nutrition_assignment_owner');
SELECT lives_ok(
    $$INSERT INTO public.study_subject (
        id, study_id, user_id, started_at, selected_intervention_ids
    ) VALUES (
        'aa710000-0000-4000-8000-000000000002', 'aa710000-0000-4000-8000-000000000001',
        auth.uid(), now(), ARRAY['first','second']
    )$$,
    'starting a nutrition subject stores the chosen intervention order'
);

SELECT throws_ok(
    $$UPDATE public.study_subject SET selected_intervention_ids = ARRAY['second','first']
      WHERE id = 'aa710000-0000-4000-8000-000000000002'$$,
    '22023', 'nutrition intervention assignment is immutable',
    'a started nutrition subject keeps its recorded intervention order'
);

SELECT lives_ok(
    $$SELECT public.advance_owned_study_subject_day('aa710000-0000-4000-8000-000000000002', 1)$$,
    'preview clock changes still advance an owned draft study'
);

SELECT is(
    (SELECT selected_intervention_ids FROM public.study_subject
     WHERE id = 'aa710000-0000-4000-8000-000000000002'),
    ARRAY['first','second'],
    'clock changes preserve the intervention order'
);

SELECT lives_ok(
    $$INSERT INTO public.study_subject (
        id, study_id, user_id, started_at, selected_intervention_ids
    ) VALUES (
        'aa710000-0000-4000-8000-000000000003', 'aa710000-0000-4000-8000-000000000001',
        auth.uid(), null, ARRAY[]::text[]
    );
    UPDATE public.study_subject SET selected_intervention_ids = ARRAY['second','first']
    WHERE id = 'aa710000-0000-4000-8000-000000000003'$$,
    'the order can change before a subject starts'
);

SELECT * FROM finish();
ROLLBACK;
