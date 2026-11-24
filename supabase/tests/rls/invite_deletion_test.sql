BEGIN;
SELECT plan(15);
SELECT tests.create_supabase_user('invite_owner');
SELECT tests.create_supabase_user('invite_first');
SELECT tests.create_supabase_user('invite_second');
SELECT tests.create_supabase_user('invite_stranger');
CREATE TEMP TABLE fixture AS SELECT gen_random_uuid() AS study_id, gen_random_uuid()::text AS code;
GRANT SELECT ON fixture TO authenticated;
INSERT INTO public.study(id,user_id,title,description,icon_name,contact,status,participation,result_sharing,questionnaire,eligibility_criteria,observations,interventions,consent,schedule,report_specification,results)
SELECT study_id,tests.get_supabase_uid('invite_owner'),'Invite deletion regression','','accountHeart','{}','running','invite','private','[]','[]','[]','[]','[]','{"sequence":"alternating","phaseDuration":1,"numberOfCycles":1,"includeBaseline":false}','{}','[]' FROM fixture;
INSERT INTO public.study_invite(code,study_id) SELECT code,study_id FROM fixture;
INSERT INTO public.study_subject(study_id,user_id,selected_intervention_ids,invite_code)
SELECT study_id,tests.get_supabase_uid(identifier),ARRAY[]::text[],code FROM fixture CROSS JOIN (VALUES ('invite_first'),('invite_second')) AS users(identifier);
CREATE TEMP TABLE fixture_subjects AS SELECT id FROM public.study_subject WHERE study_id=(SELECT study_id FROM fixture);
INSERT INTO public.subject_progress(subject_id,intervention_id,task_id,result_type,result)
SELECT id,study_id::text,id::text,'bool','{"type":"bool","result":false}' FROM public.study_subject WHERE study_id=(SELECT study_id FROM fixture);
SELECT tests.authenticate_as('invite_stranger');
DELETE FROM public.study_invite WHERE code=(SELECT code FROM fixture);
SELECT is((SELECT count(*)::int FROM public.study_invite WHERE code=(SELECT code FROM fixture)),0,'Unrelated user cannot see private invite codes');
RESET ROLE;
SELECT is((SELECT count(*)::int FROM public.study_invite WHERE code=(SELECT code FROM fixture)),1,'Unrelated user cannot delete the invite code');
SELECT tests.authenticate_as('invite_owner');
DELETE FROM public.study_invite WHERE code=(SELECT code FROM fixture);
SELECT is((SELECT count(*)::int FROM public.study_invite WHERE code=(SELECT code FROM fixture)),0,'Owner can delete the invite code');
SELECT is((SELECT count(*)::int FROM public.study_subject WHERE study_id=(SELECT study_id FROM fixture)),2,'Both participants survive shared invite deletion');
SELECT is((SELECT count(*)::int FROM public.study_subject WHERE study_id=(SELECT study_id FROM fixture) AND invite_code IS NULL),2,'Deleted code is detached from both participants');
SELECT is((SELECT count(*)::int FROM public.study_progress_export WHERE study_id=(SELECT study_id FROM fixture)),2,'Researcher can export both saved answers');
SELECT is((SELECT status::text FROM public.study WHERE id=(SELECT study_id FROM fixture)),'running','Study remains running');
SELECT ok((public.get_study_record_from_invite((SELECT code FROM fixture)) ->> 'id') IS NULL,'Deleted code no longer resolves to a study');
SELECT tests.authenticate_as('invite_second');
SELECT throws_ok(
    'INSERT INTO public.study_subject(study_id,user_id,selected_intervention_ids,invite_code) '
    || 'SELECT study_id,tests.get_supabase_uid(''invite_second''),ARRAY[]::text[],code FROM fixture',
    '42501', NULL, 'Deleted code cannot enroll another participant'
);
SELECT tests.authenticate_as('invite_first');
SELECT is((SELECT count(*)::int FROM public.study_subject WHERE study_id=(SELECT study_id FROM fixture)),1,'First participant retains access only to own participation');
SELECT is((SELECT count(*)::int FROM public.subject_progress WHERE subject_id IN (SELECT id FROM public.study_subject WHERE study_id=(SELECT study_id FROM fixture))),1,'First participant retains own saved answer');
SELECT tests.authenticate_as('invite_second');
SELECT is((SELECT count(*)::int FROM public.study_subject WHERE study_id=(SELECT study_id FROM fixture)),1,'Second participant retains access only to own participation');
SELECT tests.authenticate_as('invite_stranger');
SELECT is((SELECT count(*)::int FROM public.study_subject WHERE study_id=(SELECT study_id FROM fixture)),0,'Unrelated user cannot read preserved participants');
RESET ROLE;
DELETE FROM public.study WHERE id=(SELECT study_id FROM fixture);
SELECT is((SELECT count(*)::int FROM public.study_subject WHERE study_id=(SELECT study_id FROM fixture)),0,'Intentional study deletion still removes participants');
SELECT is((SELECT count(*)::int FROM public.subject_progress WHERE subject_id IN (SELECT id FROM fixture_subjects)),0,'Study deletion leaves no orphaned answers');
SELECT * FROM finish();
ROLLBACK;
