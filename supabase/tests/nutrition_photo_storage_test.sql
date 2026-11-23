BEGIN;

SELECT plan(13);

-- Exercise RLS on transaction-local fixtures. Production deletes use the Storage API.
SET LOCAL storage.allow_delete_query = 'true';

SELECT tests.create_supabase_user('photo_owner', 'photo_owner@example.test');
SELECT tests.create_supabase_user('photo_other', 'photo_other@example.test');

INSERT INTO public.study (
    id, user_id, title, description, icon_name, contact, questionnaire,
    eligibility_criteria, observations, interventions, consent, schedule,
    report_specification, results
) VALUES (
    'a3200000-0000-4000-8000-000000000001',
    tests.get_supabase_uid('photo_owner'),
    'Photo storage', '', '', '{}', '{}', '{}', '[]', '[]', '{}', '{}', '{}', '{}'
);

INSERT INTO public.study_subject (id, study_id, user_id, selected_intervention_ids)
VALUES (
    'a3200000-0000-4000-8000-000000000002',
    'a3200000-0000-4000-8000-000000000001',
    tests.get_supabase_uid('photo_owner'), ARRAY[]::text[]
);

SELECT set_config('tests.photo_owner_path', tests.get_supabase_uid('photo_owner')::text ||
    '/a3200000-0000-4000-8000-000000000002/item/a3200000-0000-4000-8000-000000000003.jpg', true);
SELECT set_config('tests.photo_other_path', tests.get_supabase_uid('photo_other')::text ||
    '/a3200000-0000-4000-8000-000000000002/meal/a3200000-0000-4000-8000-000000000004.jpg', true);

SELECT ok(
    EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'nutrition-photos' AND NOT public
        AND file_size_limit = 6000000 AND allowed_mime_types = ARRAY['image/jpeg']),
    'the nutrition photo bucket is private and accepts JPEGs up to 6 MB'
);

SELECT tests.authenticate_as('photo_owner');
SELECT lives_ok(
    $$INSERT INTO storage.objects (bucket_id, name) VALUES
      ('nutrition-photos', current_setting('tests.photo_owner_path'))$$,
    'the owner can upload a photo'
);
SELECT is(
    (SELECT count(*) FROM storage.objects WHERE bucket_id = 'nutrition-photos'), 1::bigint,
    'the owner can read the photo'
);
WITH updated AS (
        UPDATE storage.objects SET metadata = '{"size":12}' WHERE bucket_id = 'nutrition-photos'
        RETURNING id
)
SELECT is((SELECT count(*) FROM updated), 1::bigint,
    'the owner can replace the photo'
);
SELECT throws_ok(
    $$UPDATE storage.objects SET name = current_setting('tests.photo_other_path')
      WHERE bucket_id = 'nutrition-photos'$$, '42501', NULL,
    'the owner cannot move an object to another account'
);
SELECT throws_ok(
    $$INSERT INTO storage.objects (bucket_id, name) VALUES
      ('nutrition-photos', replace(current_setting('tests.photo_owner_path'), '/item/', '/arbitrary/'))$$,
    '42501', NULL, 'the owner cannot use an unsupported path'
);

RESET ROLE;
SELECT tests.authenticate_as('photo_other');
SELECT is(
    (SELECT count(*) FROM storage.objects WHERE bucket_id = 'nutrition-photos'), 0::bigint,
    'another participant cannot read the photo'
);
WITH deleted AS (
        DELETE FROM storage.objects WHERE bucket_id = 'nutrition-photos' RETURNING id
)
SELECT is((SELECT count(*) FROM deleted), 0::bigint,
    'another participant cannot delete the photo'
);
SELECT throws_ok(
    $$INSERT INTO storage.objects (bucket_id, name) VALUES
      ('nutrition-photos', current_setting('tests.photo_other_path'))$$,
    '42501', NULL, 'another participant cannot upload under the study subject'
);

RESET ROLE;
SET LOCAL ROLE anon;
SELECT is(
    (SELECT count(*) FROM storage.objects WHERE bucket_id = 'nutrition-photos'), 0::bigint,
    'an unauthenticated caller cannot read the photo'
);
RESET ROLE;

DELETE FROM public.study_subject WHERE id = 'a3200000-0000-4000-8000-000000000002';
SELECT tests.authenticate_as('photo_owner');
SELECT throws_ok(
    $$INSERT INTO storage.objects (bucket_id, name) VALUES
      ('nutrition-photos', replace(current_setting('tests.photo_owner_path'), '/item/', '/meal/'))$$,
    '42501', NULL, 'withdrawal blocks further uploads'
);
WITH updated AS (
        UPDATE storage.objects SET metadata = '{}' WHERE bucket_id = 'nutrition-photos'
        RETURNING id
)
SELECT is((SELECT count(*) FROM updated), 0::bigint,
    'withdrawal blocks replacement'
);
WITH deleted AS (
        DELETE FROM storage.objects WHERE bucket_id = 'nutrition-photos' RETURNING id
)
SELECT is((SELECT count(*) FROM deleted), 1::bigint,
    'the owner can clean up photos after withdrawal'
);

SELECT * FROM finish();
ROLLBACK;
