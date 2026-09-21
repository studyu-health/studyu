BEGIN;

/*
 * User Recovery Table Migration
 *
 * Creates a separate table for recovery IDs to decouple recovery phrases from user IDs.
 * This prevents potential session hijacking if user IDs are accidentally shared.
 */

-- Create the user_recovery table
CREATE TABLE IF NOT EXISTS public.user_recovery (
    recovery_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL UNIQUE REFERENCES public.user (id) ON DELETE CASCADE,
    pending_password text,
    created_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.user_recovery OWNER TO postgres;

COMMENT ON TABLE public.user_recovery IS 'Maps recovery IDs to users for secure account recovery. Recovery phrases are derived from recovery_id, not user_id.';

-- Enable RLS
ALTER TABLE public.user_recovery ENABLE ROW LEVEL SECURITY;

-- Recovery records, including retry-safe pending credentials, are accessible
-- only through SECURITY DEFINER recovery RPCs.
/*
 * Function to get or create a recovery ID for the current user.
 * Called when user accesses the settings/recovery phrase screen.
 *
 * @returns jsonb - {
 *   "recovery_id": "uuid-string",
 *   "created": true/false (whether a new entry was created)
 * }
 */
CREATE OR REPLACE FUNCTION public.get_or_create_recovery()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_user_id uuid;
    v_recovery_id uuid;
    v_created boolean := false;
BEGIN
    -- Get current user ID
    v_user_id := auth.uid();
    
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Not authenticated'
        );
    END IF;
    
    -- Try to get existing recovery_id
    SELECT recovery_id INTO v_recovery_id
    FROM public.user_recovery
    WHERE user_id = v_user_id;
    
    -- If not found, create one
    IF v_recovery_id IS NULL THEN
        INSERT INTO public.user_recovery (user_id)
        VALUES (v_user_id)
        ON CONFLICT (user_id) DO UPDATE SET user_id = EXCLUDED.user_id
        RETURNING recovery_id INTO v_recovery_id;
        v_created := true;
    END IF;
    
    RETURN jsonb_build_object(
        'success', true,
        'recovery_id', v_recovery_id,
        'created', v_created
    );
END;
$$;

REVOKE ALL ON FUNCTION public.get_or_create_recovery() FROM public, anon;
GRANT EXECUTE ON FUNCTION public.get_or_create_recovery() TO authenticated;

COMMENT ON FUNCTION public.get_or_create_recovery() IS 'Gets existing recovery_id or creates one for the current authenticated user.';

/*
 * Replaces the current authenticated user's recovery ID.
 */
CREATE OR REPLACE FUNCTION public.rotate_recovery_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_recovery_id uuid;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '42501';
    END IF;

    SELECT recovery_id INTO v_recovery_id
    FROM public.user_recovery
    WHERE user_id = v_user_id
    FOR UPDATE;

    IF v_recovery_id IS NULL THEN
        RAISE EXCEPTION 'Recovery ID not found' USING ERRCODE = 'P0002';
    END IF;

    UPDATE public.user_recovery
    SET recovery_id = gen_random_uuid()
    WHERE user_id = v_user_id
    RETURNING recovery_id INTO v_recovery_id;

    RETURN v_recovery_id;
END;
$$;

REVOKE ALL ON FUNCTION public.rotate_recovery_id() FROM public, anon;
GRANT EXECUTE ON FUNCTION public.rotate_recovery_id() TO authenticated;

COMMENT ON FUNCTION public.rotate_recovery_id() IS 'Replaces the recovery_id for the current authenticated user.';

/*
 * Updated account recovery function that uses recovery_id instead of user_id.
 *
 * @param p_recovery_id - The UUID of the recovery entry (decoded from 13-word recovery phrase)
 *
 * @returns jsonb - {
 *   "success": true/false,
 *   "email": "user-email@domain.com",
 *   "password": "newly-generated-password",
 *   "subject_id": "study-subject-uuid-or-null",
 *   "error": "error-message-if-failed"
 * }
 */
CREATE OR REPLACE FUNCTION public.recover_account(
    p_recovery_id uuid
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_user_id uuid;
    v_user_email text;
    v_new_password text;
    v_encrypted_password text;
    v_subject_id uuid;
BEGIN
    -- 1. Look up user_id from recovery table
    SELECT user_id INTO v_user_id
    FROM public.user_recovery
    WHERE recovery_id = p_recovery_id
    FOR UPDATE;
    
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Recovery ID not found'
        );
    END IF;

    -- 2. Validate user exists in auth.users
    SELECT email INTO v_user_email
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_email IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'User not found'
        );
    END IF;

    -- 3. Create a password once. Retries return this pending credential until
    -- the recovered user confirms the sign-in, so a lost RPC response cannot
    -- consume the only recovery phrase.
    SELECT pending_password INTO v_new_password
    FROM public.user_recovery
    WHERE user_id = v_user_id;

    IF v_new_password IS NULL THEN
        v_new_password := gen_random_uuid()::text;
        v_encrypted_password := extensions.crypt(v_new_password, extensions.gen_salt('bf', 12));
        UPDATE auth.users
        SET encrypted_password = v_encrypted_password, updated_at = now()
        WHERE id = v_user_id;
        UPDATE public.user_recovery
        SET pending_password = v_new_password
        WHERE user_id = v_user_id;
        -- Revoke sessions before the recovered credential can be used. This
        -- leaves the new sign-in session intact while evicting lost devices.
        -- auth.refresh_tokens.user_id is varchar; auth.sessions.user_id is uuid.
        DELETE FROM auth.refresh_tokens WHERE user_id = v_user_id::text;
        DELETE FROM auth.sessions WHERE user_id = v_user_id;
    END IF;

    -- 4. Find latest active study subject
    -- Priority: most recent progress > most recent start date > deterministic ID ordering
    SELECT
        ss.id
    INTO v_subject_id

    FROM public.study_subject ss
    LEFT JOIN public.subject_progress sp ON sp.subject_id = ss.id
    WHERE
        ss.user_id = v_user_id
        AND ss.is_deleted = false
        AND ss.started_at IS NOT NULL
    GROUP BY ss.id
    ORDER BY
        MAX(sp.completed_at) DESC NULLS LAST,  -- Most recent progress first
        ss.started_at DESC,                     -- Most recent start date as tiebreaker
        ss.id DESC                               -- Deterministic ordering for identical dates
    LIMIT 1;

    -- 5. Return success with credentials and optional subject ID.
    RETURN jsonb_build_object(
        'success', true,
        'email', v_user_email,
        'password', v_new_password,
        'subject_id', v_subject_id  -- Will be null if no active studies found
    );

EXCEPTION
    WHEN OTHERS THEN
        -- Log the full error server-side only; never return internal
        -- database details to callers of this public RPC.
        RAISE LOG 'Error in recover_account for recovery_id %: %', p_recovery_id, SQLERRM;
        RETURN jsonb_build_object(
            'success', false,
            'error', 'recovery_failed'
        );
END;
$$;

REVOKE ALL ON FUNCTION public.recover_account(uuid) FROM public;
-- anon is required since users call this before authentication.
GRANT EXECUTE ON FUNCTION public.recover_account(uuid) TO anon, authenticated;

COMMENT ON FUNCTION public.recover_account(uuid) IS
'Returns a retry-safe pending credential for a recovery ID until confirmed.';

/* Confirm a recovered, authenticated account. This is deliberately separate
 * from recover_account: only a successfully signed-in participant can consume
 * the phrase. */
CREATE OR REPLACE FUNCTION public.confirm_recovered_account()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '42501';
    END IF;

    UPDATE public.user_recovery
    SET recovery_id = gen_random_uuid(), pending_password = NULL
    WHERE user_id = v_user_id AND pending_password IS NOT NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No pending recovery' USING ERRCODE = 'P0002';
    END IF;

    RETURN true;
END;
$$;

REVOKE ALL ON FUNCTION public.confirm_recovered_account() FROM public, anon;
GRANT EXECUTE ON FUNCTION public.confirm_recovered_account() TO authenticated;
COMMENT ON FUNCTION public.confirm_recovered_account() IS
'Consumes a pending recovery, rotates its phrase, and revokes all user sessions.';

COMMIT;
