BEGIN;

CREATE TABLE studyu_private.nutrition_photo_analysis_quota (
    user_id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
    window_started_at timestamptz NOT NULL,
    request_count integer NOT NULL
);

ALTER TABLE studyu_private.nutrition_photo_analysis_quota ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE studyu_private.nutrition_photo_analysis_quota
FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION public.consume_nutrition_photo_analysis_quota(p_user_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = ''
AS $$
    WITH consumed AS (
        INSERT INTO studyu_private.nutrition_photo_analysis_quota AS quota
            (user_id, window_started_at, request_count)
        VALUES (p_user_id, statement_timestamp(), 1)
        ON CONFLICT (user_id) DO UPDATE
        SET window_started_at = CASE
                WHEN quota.window_started_at <= EXCLUDED.window_started_at - interval '1 minute'
                    THEN EXCLUDED.window_started_at
                ELSE quota.window_started_at
            END,
            request_count = CASE
                WHEN quota.window_started_at <= EXCLUDED.window_started_at - interval '1 minute'
                    THEN 1
                ELSE quota.request_count + 1
            END
        WHERE quota.window_started_at <= EXCLUDED.window_started_at - interval '1 minute'
           OR quota.request_count < 5
        RETURNING 1
    )
    SELECT EXISTS (SELECT 1 FROM consumed);
$$;

REVOKE ALL ON FUNCTION public.consume_nutrition_photo_analysis_quota(uuid)
FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.consume_nutrition_photo_analysis_quota(uuid)
TO service_role;

COMMIT;
