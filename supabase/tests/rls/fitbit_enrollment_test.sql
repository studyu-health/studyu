BEGIN;
SELECT plan(13);

SELECT tests.create_supabase_user('fitbit_editor', 'fitbit_editor@fake-studyu-email-domain.com');
SELECT tests.create_supabase_user('fitbit_participant', 'fitbit_participant@fake-studyu-email-domain.com');

INSERT INTO public.study (
    id, user_id, title, description, icon_name, contact, questionnaire,
    eligibility_criteria, observations, interventions, consent, schedule,
    report_specification, results, status, participation
)
SELECT ('00000000-0000-4000-8000-' || lpad(n::text, 12, '0'))::uuid,
    tests.get_supabase_uid('fitbit_editor'), 'Fitbit enrollment', '', 'heart',
    '{}'::jsonb, '[]'::jsonb, '[]'::jsonb, '[]'::jsonb, '[]'::jsonb,
    '[]'::jsonb, '{}'::jsonb, '{}'::jsonb, '[]'::jsonb,
    CASE n WHEN 3 THEN 'closed' WHEN 4 THEN 'draft' ELSE 'running' END::public.study_status,
    CASE n WHEN 2 THEN 'invite' ELSE 'open' END::public.participation
FROM generate_series(1, 4) AS n;

INSERT INTO public.study_fitbit_credentials (study_id, fitbit_credentials)
SELECT id, '{"clientId":"test-client","clientSecret":"test-secret"}'::jsonb
FROM public.study WHERE title = 'Fitbit enrollment';
INSERT INTO public.study_invite (code, study_id) VALUES
    ('fitbit-invite', '00000000-0000-4000-8000-000000000002'),
    ('wrong-study', '00000000-0000-4000-8000-000000000001');

SELECT ok(NOT has_function_privilege('anon',
    'public.get_enrollment_fitbit_configuration(uuid,text)', 'EXECUTE'),
    'unauthenticated clients cannot request enrollment configuration');
SELECT is((SELECT count(*) FROM information_schema.routine_privileges
    WHERE routine_name = 'get_enrollment_fitbit_configuration' AND grantee = 'PUBLIC'),
    0::bigint, 'PUBLIC has no function grant');
SELECT ok(has_function_privilege('authenticated',
    'public.get_enrollment_fitbit_configuration(uuid,text)', 'EXECUTE'),
    'authenticated participants can request configuration');

SELECT tests.authenticate_as('fitbit_participant');
SELECT is((SELECT count(*) FROM public.study_fitbit_credentials), 0::bigint,
    'enrollment does not broaden direct credential access');
SELECT is(public.get_enrollment_fitbit_configuration(
    '00000000-0000-4000-8000-000000000001', NULL)->'fitbit_credentials'->>'clientId',
    'test-client', 'a new participant can authorize for a running open study');
SELECT is(public.get_enrollment_fitbit_configuration(
    '00000000-0000-4000-8000-000000000002', 'fitbit-invite')->>'study_id',
    '00000000-0000-4000-8000-000000000002', 'a valid invite admits its own study');
SELECT is(public.get_enrollment_fitbit_configuration(
    '00000000-0000-4000-8000-000000000002', NULL), NULL::jsonb,
    'invite-only studies require an invite');
SELECT is(public.get_enrollment_fitbit_configuration(
    '00000000-0000-4000-8000-000000000002', 'wrong-study'), NULL::jsonb,
    'an invite for another study does not admit enrollment');
SELECT is(public.get_enrollment_fitbit_configuration(
    '00000000-0000-4000-8000-000000000002', 'invalid'), NULL::jsonb,
    'invalid invites do not admit enrollment');
SELECT is(public.get_enrollment_fitbit_configuration(
    '00000000-0000-4000-8000-000000000003', NULL), NULL::jsonb,
    'closed studies do not expose enrollment configuration');
SELECT is(public.get_enrollment_fitbit_configuration(
    '00000000-0000-4000-8000-000000000004', NULL), NULL::jsonb,
    'draft studies do not expose enrollment configuration');
SELECT is(public.get_enrollment_fitbit_configuration(
    '00000000-0000-4000-8000-000000000099', NULL), NULL::jsonb,
    'unknown studies do not expose enrollment configuration');
SELECT set_config('request.jwt.claims', '{}', true);
SELECT is(public.get_enrollment_fitbit_configuration(
    '00000000-0000-4000-8000-000000000001', NULL), NULL::jsonb,
    'the function requires a user even when the role has EXECUTE');

SELECT * FROM finish();
ROLLBACK;
