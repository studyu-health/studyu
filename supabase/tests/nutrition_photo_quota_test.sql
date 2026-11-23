BEGIN;

SELECT plan(6);

SELECT tests.create_supabase_user('nutrition_quota_user', 'nutrition_quota_user@studyu.health');
SELECT tests.create_supabase_user('nutrition_quota_other', 'nutrition_quota_other@studyu.health');
SELECT set_config('tests.nutrition_quota_user', tests.get_supabase_uid('nutrition_quota_user')::text, true);
SELECT set_config('tests.nutrition_quota_other', tests.get_supabase_uid('nutrition_quota_other')::text, true);

SELECT ok(
    NOT has_function_privilege('authenticated', 'public.consume_nutrition_photo_analysis_quota(uuid)', 'EXECUTE'),
    'participant accounts cannot access the internal quota endpoint'
);
SELECT ok(
    NOT has_function_privilege('anon', 'public.consume_nutrition_photo_analysis_quota(uuid)', 'EXECUTE'),
    'anonymous callers cannot access the internal quota endpoint'
);

SET LOCAL ROLE service_role;
SELECT ok(
    public.consume_nutrition_photo_analysis_quota(current_setting('tests.nutrition_quota_user')::uuid),
    'the first photo request is accepted'
);
DO $$
BEGIN
    FOR i IN 2..5 LOOP
        PERFORM public.consume_nutrition_photo_analysis_quota(current_setting('tests.nutrition_quota_user')::uuid);
    END LOOP;
END;
$$;
SELECT ok(
    NOT public.consume_nutrition_photo_analysis_quota(current_setting('tests.nutrition_quota_user')::uuid),
    'the sixth request in the same minute is refused'
);
SELECT ok(
    public.consume_nutrition_photo_analysis_quota(current_setting('tests.nutrition_quota_other')::uuid),
    'a separate participant has a separate quota'
);

RESET ROLE;
UPDATE studyu_private.nutrition_photo_analysis_quota
SET window_started_at = now() - interval '1 minute'
WHERE user_id = current_setting('tests.nutrition_quota_user')::uuid;
SET LOCAL ROLE service_role;
SELECT ok(
    public.consume_nutrition_photo_analysis_quota(current_setting('tests.nutrition_quota_user')::uuid),
    'the quota renews after one minute'
);

SELECT * FROM finish();
ROLLBACK;
