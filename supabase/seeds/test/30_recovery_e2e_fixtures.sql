BEGIN;

-- Local-only accounts for browser recovery E2E. The fixed recovery IDs are
-- intentionally consumed in suite order; reset-test-db restores them per run.
INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, confirmation_token, email_change,
    email_change_token_new, recovery_token
)
VALUES
(
    '00000000-0000-0000-0000-000000000000',
    '33333333-3333-4333-8333-333333333333',
    'authenticated',
    'authenticated',
    'recovery-active@local.studyu.test',
    extensions.crypt('recovery-active-pass', extensions.gen_salt('bf', 12)),
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"test_identifier":"recovery_active"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '44444444-4444-4444-8444-444444444444',
    'authenticated',
    'authenticated',
    'recovery-no-study@local.studyu.test',
    extensions.crypt('recovery-no-study-pass', extensions.gen_salt('bf', 12)),
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"test_identifier":"recovery_no_study"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '55555555-5555-4555-8555-555555555555',
    'authenticated',
    'authenticated',
    'recovery-signed-in@local.studyu.test',
    extensions.crypt('recovery-signed-in-pass', extensions.gen_salt('bf', 12)),
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"test_identifier":"recovery_signed_in"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '77777777-7777-4777-8777-777777777777',
    'authenticated',
    'authenticated',
    'recovery-confirmation@local.studyu.test',
    extensions.crypt(
        'recovery-confirmation-pass', extensions.gen_salt('bf', 12)
    ),
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"test_identifier":"recovery_confirmation"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
)
ON CONFLICT (id) DO UPDATE SET
    email = excluded.email,
    encrypted_password = excluded.encrypted_password,
    raw_app_meta_data = excluded.raw_app_meta_data,
    raw_user_meta_data = excluded.raw_user_meta_data,
    updated_at = excluded.updated_at;

INSERT INTO auth.identities (
    id, user_id, provider_id, identity_data, provider, last_sign_in_at,
    created_at, updated_at
)
VALUES
(
    '33333333-2222-4222-8222-333333333333',
    '33333333-3333-4333-8333-333333333333',
    '33333333-3333-4333-8333-333333333333',
    '{"sub":"33333333-3333-4333-8333-333333333333","email":"recovery-active@local.studyu.test"}',
    'email',
    now(),
    now(),
    now()
),
(
    '44444444-2222-4222-8222-444444444444',
    '44444444-4444-4444-8444-444444444444',
    '44444444-4444-4444-8444-444444444444',
    '{"sub":"44444444-4444-4444-8444-444444444444","email":"recovery-no-study@local.studyu.test"}',
    'email',
    now(),
    now(),
    now()
),
(
    '55555555-2222-4222-8222-555555555555',
    '55555555-5555-4555-8555-555555555555',
    '55555555-5555-4555-8555-555555555555',
    '{"sub":"55555555-5555-4555-8555-555555555555","email":"recovery-signed-in@local.studyu.test"}',
    'email',
    now(),
    now(),
    now()
),
(
    '77777777-2222-4222-8222-777777777777',
    '77777777-7777-4777-8777-777777777777',
    '77777777-7777-4777-8777-777777777777',
    '{"sub":"77777777-7777-4777-8777-777777777777","email":"recovery-confirmation@local.studyu.test"}',
    'email',
    now(),
    now(),
    now()
)
ON CONFLICT (provider, provider_id) DO UPDATE SET
    identity_data = excluded.identity_data,
    updated_at = excluded.updated_at;

INSERT INTO public.user (id, email, preferences)
VALUES
(
    '33333333-3333-4333-8333-333333333333',
    'recovery-active@local.studyu.test',
    NULL
),
(
    '44444444-4444-4444-8444-444444444444',
    'recovery-no-study@local.studyu.test',
    NULL
),
(
    '55555555-5555-4555-8555-555555555555',
    'recovery-signed-in@local.studyu.test',
    NULL
),
(
    '77777777-7777-4777-8777-777777777777',
    'recovery-confirmation@local.studyu.test',
    NULL
)
ON CONFLICT (id) DO UPDATE
    SET email = excluded.email, preferences = excluded.preferences;

-- Upsert fixed IDs so rerunning the test seed restores IDs rotated by recovery.
INSERT INTO public.user_recovery (recovery_id, user_id)
VALUES
(
    '00000000-0000-4000-8000-000000000010',
    '33333333-3333-4333-8333-333333333333'
),
(
    '00000000-0000-4000-8000-000000000020',
    '44444444-4444-4444-8444-444444444444'
),
('00000000-0000-4000-8000-000000000030', '77777777-7777-4777-8777-777777777777')
ON CONFLICT (user_id) DO UPDATE SET recovery_id = excluded.recovery_id;

INSERT INTO public.study_subject (
    id, study_id, user_id, started_at, selected_intervention_ids, is_deleted
)
VALUES (
    '66666666-6666-4666-8666-666666666666',
    '22222222-2222-4222-8222-222222222222',
    '33333333-3333-4333-8333-333333333333',
    now() - interval '1 day', ARRAY['willow_bark_tea', 'arnika'], FALSE
)
ON CONFLICT (id) DO UPDATE SET
    study_id = excluded.study_id, user_id = excluded.user_id,
    started_at = excluded.started_at,
    selected_intervention_ids = excluded.selected_intervention_ids,
    is_deleted = excluded.is_deleted;

INSERT INTO public.subject_progress (
    completed_at, subject_id, intervention_id, task_id, result_type, result
)
VALUES (
    now() - interval '1 hour', '66666666-6666-4666-8666-666666666666',
    'willow_bark_tea', 'drink_tea', 'bool',
    '{"type":"bool","periodId":"54d114f3-e692-4283-9610-17e23edf8f70","result":true}'::jsonb
)
ON CONFLICT (completed_at, subject_id) DO UPDATE SET
    intervention_id = excluded.intervention_id, task_id = excluded.task_id,
    result_type = excluded.result_type, result = excluded.result;

COMMIT;
