BEGIN;

SELECT plan(19);

SELECT tests.create_supabase_user(
    'recovery_user',
    'recovery_user@fake-studyu-email-domain.com'
);

INSERT INTO public.user_recovery (recovery_id, user_id)
VALUES (
    '00000000-0000-4000-8000-000000000001',
    tests.get_supabase_uid('recovery_user')
);

SELECT ok(
    (
        public.recover_account(
            '00000000-0000-4000-8000-000000000001'
        ) ->> 'success'
    )::boolean,
    'recovery succeeds with the current recovery ID'
);

SELECT is(
    public.recover_account('00000000-0000-4000-8000-000000000001')
    ->> 'password',
    public.recover_account('00000000-0000-4000-8000-000000000001')
    ->> 'password',
    'retries return the same pending credential'
);

SELECT tests.create_supabase_user(
    'other_recovery_user',
    'other_recovery_user@fake-studyu-email-domain.com'
);
INSERT INTO public.user_recovery (recovery_id, user_id)
VALUES (
    '00000000-0000-4000-8000-000000000002',
    tests.get_supabase_uid('other_recovery_user')
);

SELECT tests.authenticate_as('recovery_user');
SELECT is(
    (SELECT count(*) FROM public.user_recovery), 0::bigint,
    'authenticated users cannot select recovery records containing pending passwords'
);
SELECT tests.authenticate_as('other_recovery_user');
SELECT is(
    (SELECT count(*) FROM public.user_recovery), 0::bigint,
    'authenticated users cannot select other users recovery records'
);
SELECT set_config('role', 'anon', true);
SELECT is(
    (SELECT count(*) FROM public.user_recovery), 0::bigint,
    'anon cannot select recovery rows'
);
SELECT set_config('role', 'postgres', true);

SELECT is(
    (
        SELECT count(*)
        FROM information_schema.routine_privileges
        WHERE
            routine_schema = 'public'
            AND routine_name IN (
                'rotate_recovery_id',
                'get_or_create_recovery',
                'recover_account',
                'confirm_recovered_account'
            )
            AND grantee = 'PUBLIC' AND privilege_type = 'EXECUTE'
    ),
    0::bigint,
    'PUBLIC cannot execute recovery functions'
);
SELECT ok(
    NOT has_function_privilege(
        'anon', 'public.get_or_create_recovery()', 'EXECUTE'
    ),
    'anon cannot get or create recovery IDs'
);
SELECT ok(
    has_function_privilege(
        'authenticated', 'public.get_or_create_recovery()', 'EXECUTE'
    ),
    'authenticated can get or create recovery IDs'
);
SELECT ok(
    has_function_privilege('anon', 'public.recover_account(uuid)', 'EXECUTE'),
    'anon can start recovery'
);
SELECT ok(
    has_function_privilege(
        'authenticated', 'public.confirm_recovered_account()', 'EXECUTE'
    ),
    'authenticated can confirm recovery'
);

SELECT ok(
    NOT has_function_privilege(
        'anon', 'public.rotate_recovery_id()', 'EXECUTE'
    ),
    'anon cannot execute rotate_recovery_id'
);

SELECT ok(
    has_function_privilege(
        'authenticated',
        'public.rotate_recovery_id()',
        'EXECUTE'
    ),
    'authenticated can execute rotate_recovery_id'
);

SELECT set_config('role', 'authenticated', true);
SELECT set_config('request.jwt.claims', null, true);
SELECT throws_ok(
    'SELECT public.rotate_recovery_id()',
    '42501',
    'Not authenticated',
    'rotate_recovery_id rejects callers without an authenticated user ID'
);

SELECT tests.authenticate_as('recovery_user');
SELECT set_config(
    'tests.current_recovery_id',
    public.get_or_create_recovery() ->> 'recovery_id',
    true
);
SELECT set_config(
    'tests.rotated_recovery_id',
    public.rotate_recovery_id()::text,
    true
);

SELECT isnt(
    current_setting('tests.rotated_recovery_id'),
    current_setting('tests.current_recovery_id'),
    'rotation returns a replacement recovery ID'
);

SELECT isnt(
    public.get_or_create_recovery() ->> 'recovery_id',
    current_setting('tests.current_recovery_id'),
    'the old recovery ID is invalid after explicit rotation'
);

SELECT is(
    public.get_or_create_recovery() ->> 'recovery_id',
    current_setting('tests.rotated_recovery_id'),
    'the replacement recovery ID is current for the authenticated user'
);

SELECT ok(
    (
        public.recover_account(
            current_setting('tests.rotated_recovery_id')::uuid
        ) ->> 'success'
    )::boolean,
    'the replacement recovery ID can recover the account'
);

SELECT tests.authenticate_as('recovery_user');
SELECT
    ok(public.confirm_recovered_account(), 'authenticated recovery confirmation succeeds');
SELECT ok(
    (
        public.recover_account(
            current_setting('tests.rotated_recovery_id')::uuid
        ) ->> 'success'
    )::boolean,
    'confirmation keeps the recovery phrase valid'
);

SELECT * FROM finish();

ROLLBACK;
