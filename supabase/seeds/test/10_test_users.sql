BEGIN;

INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  '11111111-1111-4111-8111-111111111111',
  'authenticated',
  'authenticated',
  'test-owner@studyu.health',
  extensions.crypt('test-owner-pass', extensions.gen_salt('bf', 12)),
  now() at time zone 'utc',
  now() at time zone 'utc',
  now() at time zone 'utc',
  '{"provider":"email","providers":["email"]}',
  '{"test_identifier":"test_owner"}',
  now() at time zone 'utc',
  now() at time zone 'utc',
  '',
  '',
  '',
  ''
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  encrypted_password = EXCLUDED.encrypted_password,
  raw_app_meta_data = EXCLUDED.raw_app_meta_data,
  raw_user_meta_data = EXCLUDED.raw_user_meta_data,
  updated_at = EXCLUDED.updated_at;

INSERT INTO auth.identities (
  id,
  user_id,
  provider_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
)
VALUES (
  '11111111-2222-4222-8222-111111111111',
  '11111111-1111-4111-8111-111111111111',
  '11111111-1111-4111-8111-111111111111',
  '{"sub":"11111111-1111-4111-8111-111111111111","email":"test-owner@studyu.health"}'::jsonb,
  'email',
  now() at time zone 'utc',
  now() at time zone 'utc',
  now() at time zone 'utc'
)
ON CONFLICT (provider, provider_id) DO UPDATE SET
  identity_data = EXCLUDED.identity_data,
  updated_at = EXCLUDED.updated_at;

INSERT INTO public."user" (id, email, preferences)
VALUES ('11111111-1111-4111-8111-111111111111', 'test-owner@studyu.health', NULL)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  preferences = EXCLUDED.preferences;

COMMIT;
