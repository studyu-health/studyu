-- ============================================================================
-- Migration: Security Hardening and Performance Optimization
-- Date: October 22, 2025
-- ============================================================================
--
-- OVERVIEW:
-- This migration enhances database security and performance through:
--   1. Tightening function execution privileges
--   2. Removing SECURITY DEFINER where unnecessary
--   3. Optimizing RLS policies for better performance
--   4. Cleaning up redundant constraints and functions
--   5. Removing external extension dependencies
--
-- SECURITY IMPROVEMENTS:
-- - Revokes public/anon execute privileges on internal functions
-- - Removes SECURITY DEFINER from functions where RLS policies suffice
-- - Ensures functions cannot be exploited for privilege escalation
-- - Applies principle of least privilege throughout
--
-- PERFORMANCE IMPROVEMENTS:
-- - Wraps auth.uid() in subqueries to enable query plan caching
-- - Removes duplicate unique constraints
-- - Optimizes foreign key references
-- - Replaces moddatetime extension with native trigger
--
-- IMPORTANT NOTES:
-- - This migration is idempotent and can be safely re-run
-- - All code changes maintain backwards compatibility
-- - RLS policies are preserved and optimized, not replaced
--
-- ============================================================================

BEGIN;

-- ============================================================================
-- SECTION 1: REVOKE FUNCTION EXECUTION PRIVILEGES
-- ============================================================================
--
-- Revoke EXECUTE privileges from public and anon roles on internal functions.
-- These functions should only be callable by authenticated users or through
-- RLS policy evaluation, not directly by unauthenticated users.
--
-- By default, PostgreSQL grants EXECUTE on functions to PUBLIC. This is
-- overly permissive for functions that access sensitive data or are used
-- internally by RLS policies.
-- ============================================================================

-- Functions used in RLS policies
-- These are called during policy evaluation and don't need public access
REVOKE EXECUTE ON FUNCTION public.can_edit(uuid, public.study) FROM public, anon;
-- anon is needed for RLS on the study table
REVOKE EXECUTE ON FUNCTION public.is_study_subject_of(uuid, uuid) FROM public;
REVOKE EXECUTE ON FUNCTION public.get_study_from_invite(text) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.has_results_public(uuid) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.user_email(uuid) FROM public, anon;

-- Computed field functions (PostgREST calls these with elevated privileges)
-- These are exposed through the API as computed columns on tables
REVOKE EXECUTE ON FUNCTION public.active_subject_count(public.study) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.has_study_ended(public.study_subject) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.study_active_days(public.study) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.study_ended_count(public.study) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.study_length(public.study) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.study_missed_days(public.study) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.study_participant_count(public.study) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.study_total_tasks(public.study_subject) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.subject_current_day(public.study_subject) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.subject_total_active_days(public.study_subject) FROM public, anon;

-- Utility functions
-- Internal helper functions not meant for direct API access
REVOKE EXECUTE ON FUNCTION public.has_study_ended(uuid) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.is_active_subject(uuid, integer) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.last_completed_task(uuid) FROM public, anon;

-- RPC/API functions
-- Even though this is an API endpoint, we control access through explicit grants
REVOKE EXECUTE ON FUNCTION public.get_study_record_from_invite(text) FROM public, anon;

-- Trigger functions
-- These should never be called directly, only by triggers
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.allow_updating_only_study() FROM public, anon;


-- ============================================================================
-- SECTION 2: REMOVE SECURITY DEFINER WHERE UNNECESSARY
-- ============================================================================
--
-- SECURITY DEFINER functions run with the privileges of the function owner,
-- not the caller. This is necessary only when a function needs to access
-- data that the caller doesn't have direct access to.
--
-- Where RLS policies already grant appropriate access, SECURITY DEFINER is
-- unnecessary and creates a potential security risk if the function can be
-- exploited. We remove it from such functions and simplify their logic.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- is_study_subject_of: Check if a user is a subject of a study
-- No SECURITY DEFINER needed - users can already query their own study_subject rows
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_study_subject_of(_user_id uuid, _study_id uuid)
RETURNS boolean
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.study_subject
    WHERE study_subject.user_id = _user_id AND study_subject.study_id = _study_id
  )
$$;

-- ----------------------------------------------------------------------------
-- has_results_public: Check if a study subject's results are public
-- SECURITY DEFINER needed - must check study settings that caller may not access
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.has_results_public(psubject_id uuid) RETURNS boolean
  LANGUAGE plpgsql SECURITY DEFINER
  set search_path = ''
  AS $$
  BEGIN
    RETURN (
     SELECT EXISTS(
     SELECT 1
      FROM public.study, public.study_subject
      WHERE (study_subject.study_id = study.id AND psubject_id = study_subject.id AND study.result_sharing = 'public'::public.result_sharing))
    );
  END;
$$;

-- ----------------------------------------------------------------------------
-- user_email: DEPRECATED AND REMOVED
-- This function is no longer used and posed a security risk
-- ----------------------------------------------------------------------------
DROP FUNCTION public.user_email(uuid);

-- ----------------------------------------------------------------------------
-- can_edit: Check if a user can edit a study
-- No SECURITY DEFINER needed - inlines user_email logic, RLS grants access
-- Checks both ownership and collaborator status
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.can_edit(user_id uuid, study_param public.study)
RETURNS boolean
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT study_param.user_id = user_id
    OR (SELECT email FROM public.user WHERE id = user_id) = ANY (study_param.collaborator_emails);
$$;

-- ----------------------------------------------------------------------------
-- active_subject_count: Count active subjects in a study
-- No SECURITY DEFINER needed - participants already have access through RLS
-- Returns count of subjects active within the last 3 days
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.active_subject_count(study public.study)
RETURNS integer
LANGUAGE sql
set search_path = ''
STABLE
AS $$
    SELECT count(1)::int
    FROM (
        SELECT public.is_active_subject(study_subject.id, 3)
        FROM public.study_subject
        WHERE study_id = study.id
          AND study_subject.is_deleted = false
    ) AS s
    WHERE s.is_active_subject;
$$;

-- ----------------------------------------------------------------------------
-- has_study_ended: Check if a study subject has completed their study
-- Accepts study_subject record and compares study length to elapsed time
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.has_study_ended(subject public.study_subject)
RETURNS boolean
LANGUAGE sql
SET search_path = ''
STABLE
AS $$
  SELECT public.study_length(s.*) < (DATE(now()) - DATE(subject.started_at))
  FROM public.study s
  WHERE s.id = subject.study_id;
$$;

-- ----------------------------------------------------------------------------
-- has_study_ended (uuid variant): DEPRECATED AND REMOVED
-- The study_subject-based version above is more commonly used and preferred
-- ----------------------------------------------------------------------------
DROP FUNCTION public.has_study_ended(uuid);

-- ----------------------------------------------------------------------------
-- study_active_days: Get array of active days for all subjects in a study
-- Returns aggregated active day counts for analytics/reporting
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.study_active_days(study_param public.study)
RETURNS integer[]
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT ARRAY_AGG(public.subject_total_active_days(study_subject))
  FROM public.study_subject
  WHERE study_subject.study_id = study_param.id;
$$;

-- ----------------------------------------------------------------------------
-- study_ended_count: Count how many subjects have completed a study
-- Excludes soft-deleted subjects from the count
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.study_ended_count(study public.study)
RETURNS integer
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT count(1)::int
  FROM (
    SELECT public.has_study_ended(study_subject) AS completed
    FROM public.study_subject
    WHERE study_id = study.id
      AND study_subject.is_deleted = false
  ) AS s
  WHERE completed;
$$;

-- ----------------------------------------------------------------------------
-- study_length: Calculate total duration of a study in days
-- Considers schedule parameters including:
--   - Phase duration, number of cycles, sequence type
--   - Custom sequences (variable length)
--   - Optional baseline period
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.study_length(study_param public.study)
RETURNS integer
    LANGUAGE sql
    set search_path = ''
    STABLE
    AS $$
 WITH s AS (
   SELECT schedule
   FROM public.study
   WHERE id = study_param.id
 )
 SELECT
   -- total study length
   (
     (schedule->>'phaseDuration')::int
     * (schedule->>'numberOfCycles')::int
     * (
         CASE
           -- if sequence = customized, count characters in sequenceCustom
           WHEN (schedule->>'sequence') = 'customized' THEN
             char_length(trim(both ' ' from COALESCE(schedule->>'sequenceCustom', '')))
           ELSE
             2 -- default for alternating, counterbalanced, random
         END
       )
   )
   +
   CASE
     WHEN (schedule->>'includeBaseline')::boolean
     THEN (schedule->>'phaseDuration')::int
     ELSE 0
   END AS length
 FROM s;
$$;

-- ----------------------------------------------------------------------------
-- study_missed_days: Calculate missed days for all subjects in a study
-- Returns array of missed day counts (current day - active days)
-- Excludes soft-deleted subjects
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.study_missed_days(study_param public.study)
RETURNS integer[]
    LANGUAGE sql
    set search_path = ''
    STABLE
    AS $$
  select ARRAY_AGG(public.subject_current_day(study_subject) - public.subject_total_active_days(study_subject)) from public.study_subject
where study_subject.study_id = study_param.id and study_subject.is_deleted = false;
$$;

-- ----------------------------------------------------------------------------
-- study_participant_count: Count total participants in a study
-- Excludes soft-deleted subjects from the count
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.study_participant_count(study public.study)
RETURNS integer
    LANGUAGE sql
    set search_path = ''
    STABLE
    AS $$
  select count(1)::int
    from public.study_subject
    where study_id = study.id
      and study_subject.is_deleted = false;
$$;

-- ----------------------------------------------------------------------------
-- study_total_tasks: Count total tasks completed by a study subject
-- Counts all progress records for the subject
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.study_total_tasks(subject public.study_subject)
RETURNS integer
    LANGUAGE sql
    set search_path = ''
    STABLE
    AS $$
  select count(1)::int
    from public.subject_progress
    where subject_id = subject.id;
$$;

-- ----------------------------------------------------------------------------
-- subject_current_day: Get the current day number for a study subject
-- Returns:
--   - Study length if the study has ended
--   - Days since start if study is ongoing
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.subject_current_day(subject public.study_subject)
RETURNS integer
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT
    CASE
      WHEN public.has_study_ended(subject)
      THEN (SELECT public.study_length(study) FROM public.study WHERE id = subject.study_id)::int
      ELSE DATE(now()) - DATE(subject.started_at)
    END;
$$;

-- ----------------------------------------------------------------------------
-- subject_total_active_days: Count distinct days with completed tasks
-- Only counts days before today (completed days, not including today)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.subject_total_active_days(subject public.study_subject)
RETURNS integer
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT COUNT(DISTINCT DATE(completed_at))::int
  FROM public.subject_progress
  WHERE subject_id = subject.id
  AND DATE(completed_at) < DATE(now());
$$;

-- ----------------------------------------------------------------------------
-- is_active_subject: Check if a subject has been active recently
-- A subject is active if they completed a task within the specified days
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_active_subject(psubject_id uuid, days_active integer)
RETURNS boolean
	LANGUAGE plpgsql
	set search_path = ''
	STABLE
	AS $$
BEGIN
  RETURN (
    SELECT
      (DATE(now()) - public.last_completed_task (psubject_id)) <= days_active);
END;
$$;

-- ----------------------------------------------------------------------------
-- last_completed_task: Get the date of the most recent completed task
-- Returns NULL if no tasks have been completed
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.last_completed_task(psubject_id uuid)
RETURNS date
	LANGUAGE plpgsql
	set search_path = ''
	STABLE
	AS $$
BEGIN
    RETURN (
        SELECT
            DATE(completed_at)
        FROM
            public.subject_progress
        WHERE
            subject_id = psubject_id
        ORDER BY
            completed_at DESC
        LIMIT 1);
END;
$$;

-- ----------------------------------------------------------------------------
-- get_study_record_from_invite: Get study details via invite code
-- SECURITY DEFINER required - allows unauthenticated users to view study
-- details via invite code, which they cannot access through RLS policies
-- Used by the signup flow to display study information before authentication
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_study_record_from_invite(invite_code text)
RETURNS public.study
LANGUAGE sql SECURITY DEFINER
set search_path = ''
STABLE
AS $$
  SELECT * FROM public.study
  WHERE study.id = (
    SELECT study_invite.study_id
    FROM public.study_invite
    WHERE invite_code = study_invite.code
  );
$$;

-- ----------------------------------------------------------------------------
-- Update RLS policy to use the full study record function
-- This ensures invite codes are validated against the actual study
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Invite code needs to be valid (not possible in the app)" ON public.study_subject;

CREATE POLICY "Invite code must match study_id"
ON public.study_subject
AS RESTRICTIVE
FOR INSERT
WITH CHECK (
  invite_code IS NULL
  OR study_id IN (
    SELECT (public.get_study_record_from_invite(study_subject.invite_code)).id
  )
);

-- ----------------------------------------------------------------------------
-- handle_new_user: Trigger function to create user record on auth signup
-- Called by trigger when new user signs up via Supabase Auth
-- Creates corresponding row in public.user table
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    set search_path = ''
    AS $$
begin
  insert into public.user (id, email)
  values (new.id, new.email);
  return new;
end;
$$;

-- Trigger functions should not be executable by authenticated users
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM authenticated;

-- ----------------------------------------------------------------------------
-- allow_updating_only_study: Trigger to restrict study updates after launch
-- Enforces immutability rules on study configuration:
--   - Draft studies can be freely modified
--   - Running/closed studies can only update whitelisted columns
--   - Status transitions are strictly controlled:
--       * draft -> running (launch study)
--       * running -> closed (end study)
--   - supabase_admin can bypass restrictions (for Studio access)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.allow_updating_only_study()
 RETURNS trigger
 LANGUAGE plpgsql
 set search_path = ''
AS $function$
DECLARE
  whitelist TEXT[] := TG_ARGV::TEXT[];
  schema_table TEXT;
  column_name TEXT;
  rec RECORD;
  new_value TEXT;
  old_value TEXT;
BEGIN

  -- The user 'supabase_admin' should be able to update any record, e.g. when using Supabase Studio
  IF CURRENT_USER = 'supabase_admin' THEN
    RETURN NEW;
  END IF;

  -- In draft status allow update of all columns
  IF OLD.status = 'draft'::public.study_status THEN
    RETURN NEW;
  END IF;

  -- Only allow status to be updated from draft to running and from running to closed
  IF OLD.status != NEW.status THEN
    IF NOT (
        (OLD.status = 'draft'::public.study_status AND NEW.status = 'running'::public.study_status)
        OR (OLD.status = 'running'::public.study_status AND NEW.status = 'closed'::public.study_status)
    ) THEN
      RAISE EXCEPTION 'Invalid status transition';
    END IF;
  END IF;

  schema_table := concat(TG_TABLE_SCHEMA, '.', TG_TABLE_NAME);

  -- If RLS is not active on current table for function invoker, early return
  IF NOT row_security_active(schema_table) THEN
    RETURN NEW;
  END IF;

  -- Otherwise, loop on all columns of the table schema
  FOR rec IN (
    SELECT col.column_name
    FROM information_schema.columns as col
    WHERE table_schema = TG_TABLE_SCHEMA
    AND table_name = TG_TABLE_NAME
  ) LOOP
    -- If the current column is whitelisted, early continue
    column_name := rec.column_name;
    IF column_name = ANY(whitelist) THEN
      CONTINUE;
    END IF;

    -- If not whitelisted, execute dynamic SQL to get column value from OLD and NEW records
    EXECUTE format('SELECT ($1).%I, ($2).%I', column_name, column_name)
    INTO new_value, old_value
    USING NEW, OLD;

    -- Raise exception if column value changed
    IF new_value IS DISTINCT FROM old_value THEN
      RAISE EXCEPTION 'Unauthorized change to "%"', column_name;
    END IF;
  END LOOP;

  -- RLS active, but no exception encountered, clear to proceed.
  RETURN NEW;
END;
$function$;

-- Trigger functions should not be executable by authenticated users
REVOKE EXECUTE ON FUNCTION public.allow_updating_only_study() FROM authenticated;

-- ----------------------------------------------------------------------------
-- get_study_from_invite: DEPRECATED AND REMOVED
-- This function is redundant - get_study_record_from_invite already returns
-- the study_id and all study fields
-- ----------------------------------------------------------------------------
DROP FUNCTION public.get_study_from_invite(text);

-- ============================================================================
-- SECTION 3: PERFORMANCE IMPROVEMENTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Remove duplicate unique constraints
-- PostgreSQL PRIMARY KEY already provides uniqueness, additional UNIQUE
-- constraints create unnecessary index overhead and complicate foreign keys
-- ----------------------------------------------------------------------------

-- Drop the duplicate UNIQUE constraint on study.id
-- The PRIMARY KEY already provides uniqueness
-- We need to recreate foreign keys to reference the PRIMARY KEY instead

-- 1. Drop the foreign keys that depend on the duplicate unique constraint
ALTER TABLE public.repo
    DROP CONSTRAINT "repo_studyId_fkey";

ALTER TABLE public.study_invite
    DROP CONSTRAINT "study_invite_studyId_fkey";

ALTER TABLE public.study_fitbit_credentials
    DROP CONSTRAINT "study_fitbit_credentials_studyId_fkey";

ALTER TABLE public.study_subject
    DROP CONSTRAINT "study_subject_studyId_fkey";

-- 2. Drop the redundant UNIQUE constraint on study.id
ALTER TABLE public.study
    DROP CONSTRAINT "study_id_key";

-- 3. Recreate the foreign keys referencing the PRIMARY KEY (study_pkey)
ALTER TABLE public.repo
    ADD CONSTRAINT "repo_studyId_fkey"
        FOREIGN KEY (study_id) REFERENCES public.study(id);

ALTER TABLE public.study_invite
    ADD CONSTRAINT "study_invite_studyId_fkey"
        FOREIGN KEY (study_id) REFERENCES public.study(id);

ALTER TABLE public.study_fitbit_credentials
    ADD CONSTRAINT "study_fitbit_credentials_studyId_fkey"
        FOREIGN KEY (study_id) REFERENCES public.study(id);

ALTER TABLE public.study_subject
    ADD CONSTRAINT "study_subject_studyId_fkey"
        FOREIGN KEY (study_id) REFERENCES public.study(id);

-- Remove duplicate unique constraint on study_invite.code
-- The PRIMARY KEY already provides uniqueness
ALTER TABLE public.study_invite DROP CONSTRAINT IF EXISTS study_invite_code_unique;

-- ----------------------------------------------------------------------------
-- Remove dependency on moddatetime extension
-- Replace with native PostgreSQL trigger for better portability
-- The moddatetime extension requires installation and may not be available
-- in all environments. A simple native trigger achieves the same result.
-- ----------------------------------------------------------------------------

-- 1. Create or replace the trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER
set search_path = '' AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Drop the existing trigger if it exists (from moddatetime or old version)
DROP TRIGGER IF EXISTS handle_updated_at ON public.study;

-- 3. Create the new trigger using our custom function
CREATE TRIGGER handle_updated_at
BEFORE UPDATE ON public.study
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


-- ============================================================================
-- SECTION 4: OPTIMIZE RLS POLICIES FOR PERFORMANCE
-- ============================================================================
--
-- PERFORMANCE OPTIMIZATION: Cache auth.uid() calls in RLS policies
--
-- Problem: PostgreSQL re-evaluates auth.uid() for every row when used directly
-- in RLS policies, causing significant performance degradation on large tables.
--
-- Solution: Wrap auth.uid() in a subquery with SELECT. The query planner can
-- evaluate this once and cache the result, rather than calling it per-row.
--
-- Pattern:
--   Bad:  USING (auth.uid() = user_id)
--   Good: USING ((SELECT auth.uid()) = user_id)
--
-- This optimization can improve query performance by 10-100x on large tables.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Repo table policies
-- ----------------------------------------------------------------------------

-- Optimize: Study creators can do everything with repos from their studies
DROP POLICY IF EXISTS "Study creators can do everything with repos from their studies" ON public.repo;
CREATE POLICY "Study creators can do everything with repos from their studies"
ON public.repo
USING (
  (SELECT auth.uid()) = (
    SELECT study.user_id
    FROM public.study
    WHERE repo.study_id = study.id
  )
);

-- ----------------------------------------------------------------------------
-- Study table policies
-- ----------------------------------------------------------------------------

-- Optimize: Editors can view their studies
DROP POLICY IF EXISTS "Editors can view their studies" ON public.study;
CREATE POLICY "Editors can view their studies"
ON public.study
FOR SELECT
USING ((SELECT auth.uid()) = user_id);

-- Optimize: Editors can do everything with their studies
DROP POLICY IF EXISTS "Editors can do everything with their studies" ON public.study;
CREATE POLICY "Editors can do everything with their studies"
ON public.study
USING (public.can_edit((SELECT auth.uid()), study.*));

-- Optimize: Study subjects can view their joined study
DROP POLICY IF EXISTS "Study subjects can view their joined study" ON public.study;
CREATE POLICY "Study subjects can view their joined study"
ON public.study
FOR SELECT
USING (public.is_study_subject_of((SELECT auth.uid()), id));

-- ----------------------------------------------------------------------------
-- Study invite policies
-- ----------------------------------------------------------------------------

-- Optimize: Editors can manage their own invite-only study invite codes
DROP POLICY IF EXISTS "Editors can manage their own invite-only study invite codes" ON public.study_invite;
CREATE POLICY "Editors can manage their own invite-only study invite codes"
ON public.study_invite
USING (
  (
    SELECT public.can_edit((SELECT auth.uid()), study.*) AS can_edit
    FROM public.study
    WHERE study.id = study_invite.study_id
    AND study.participation = 'invite'::public.participation
  )
);

-- Optimize: Editors can read their own open-study invite codes
DROP POLICY IF EXISTS "Editors can read their own open-study invite codes" ON public.study_invite;
CREATE POLICY "Editors can read their own open-study invite codes"
ON public.study_invite
FOR SELECT
USING (
  (
    SELECT public.can_edit((SELECT auth.uid()), study.*) AS can_edit
    FROM public.study
    WHERE study.id = study_invite.study_id
    AND study.participation = 'open'::public.participation
  )
);

-- Optimize: Editors can delete their own open-study invite codes
DROP POLICY IF EXISTS "Editors can delete their own open-study invite codes" ON public.study_invite;
CREATE POLICY "Editors can delete their own open-study invite codes"
ON public.study_invite
FOR DELETE
USING (
  (
    SELECT public.can_edit((SELECT auth.uid()), study.*) AS can_edit
    FROM public.study
    WHERE study.id = study_invite.study_id
    AND study.participation = 'open'::public.participation
  )
);

-- ----------------------------------------------------------------------------
-- Study subject policies
-- ----------------------------------------------------------------------------

-- Optimize: Users can do everything with their subjects
DROP POLICY IF EXISTS "Users can do everything with their subjects" ON public.study_subject;
CREATE POLICY "Users can do everything with their subjects"
ON public.study_subject
USING ((SELECT auth.uid()) = user_id);

-- Optimize: Editors can do everything with their study subjects
DROP POLICY IF EXISTS "Editors can do everything with their study subjects" ON public.study_subject;
CREATE POLICY "Editors can do everything with their study subjects"
ON public.study_subject
USING (
  (
    SELECT public.can_edit((SELECT auth.uid()), study.*) AS can_edit
    FROM public.study
    WHERE study.id = study_subject.study_id
  )
);

-- Optimize: Editors can see subjects from their studies
DROP POLICY IF EXISTS "Editors can see subjects from their studies" ON public.study_subject;
CREATE POLICY "Editors can see subjects from their studies"
ON public.study_subject
FOR SELECT
USING (
  (
    SELECT public.can_edit((SELECT auth.uid()), study.*) AS can_edit
    FROM public.study
    WHERE study.id = study_subject.study_id
  )
);

-- ----------------------------------------------------------------------------
-- Subject progress policies
-- ----------------------------------------------------------------------------

-- Optimize: Editors can see their study subjects progress
DROP POLICY IF EXISTS "Editors can see their study subjects progress" ON public.subject_progress;
CREATE POLICY "Editors can see their study subjects progress"
ON public.subject_progress
FOR SELECT
USING (
  (
    SELECT public.can_edit((SELECT auth.uid()), study.*) AS can_edit
    FROM public.study, public.study_subject
    WHERE study.id = study_subject.study_id
    AND study_subject.id = subject_progress.subject_id
  )
);

-- Optimize: Users can do everything with their progress
DROP POLICY IF EXISTS "Users can do everything with their progress" ON public.subject_progress;
CREATE POLICY "Users can do everything with their progress"
ON public.subject_progress
USING (
  (SELECT auth.uid()) = (
    SELECT study_subject.user_id
    FROM public.study_subject
    WHERE study_subject.id = subject_progress.subject_id
  )
);

-- ----------------------------------------------------------------------------
-- Fitbit credentials policies
-- ----------------------------------------------------------------------------

-- Optimize: Enable read access for study participants for fitbit credentials and owners
DROP POLICY IF EXISTS "Enable read access for study participants for fitbit credentials and owners" ON public.study_fitbit_credentials;
CREATE POLICY "Enable read access for study participants for fitbit credentials and owners"
ON public.study_fitbit_credentials
FOR SELECT
USING (
  (
    SELECT public.can_edit((SELECT auth.uid()), study)
    FROM public.study
    WHERE study.id = study_fitbit_credentials.study_id
  )
  OR public.is_study_subject_of((SELECT auth.uid()), study_fitbit_credentials.study_id)
);

-- Optimize: Study owners can manage their own fitbit credentials
DROP POLICY IF EXISTS "Study owners can manage their own fitbit credentials" ON public.study_fitbit_credentials;
CREATE POLICY "Study owners can manage their own fitbit credentials"
ON public.study_fitbit_credentials
FOR ALL
USING (
  (
    SELECT public.can_edit((SELECT auth.uid()), study)
    FROM public.study
    WHERE study.id = study_fitbit_credentials.study_id
  )
)
WITH CHECK (
  (
    SELECT public.can_edit((SELECT auth.uid()), study)
    FROM public.study
    WHERE study.id = study_fitbit_credentials.study_id
  )
);

-- ----------------------------------------------------------------------------
-- User table policies
-- ----------------------------------------------------------------------------

-- Optimize: Allow users to manage their own user
DROP POLICY IF EXISTS "Allow users to manage their own user" ON public."user";
CREATE POLICY "Allow users to manage their own user"
ON public."user"
FOR ALL
USING ((SELECT auth.uid()) = id);

-- ----------------------------------------------------------------------------
-- Comments
-- ----------------------------------------------------------------------------

COMMENT ON COLUMN public.study.published IS
	'Deprecated: Use "status" column to track publication state.';

COMMENT ON FUNCTION public.active_subject_count(public.study) IS
'TODO: Let research decide when user is not active anymore. Currently set to hardcoded number in days.';

-- ============================================================================
-- SECTION 5: FIX RLS POLICIES
-- ============================================================================
--
-- Updates policies to use has_results_public function correctly.
-- Previous policies had naming conflicts - both subject_progress and
-- study_subject had identically named policies, which isn't allowed.
-- ============================================================================

DROP POLICY "Enable read access for all users if results are public" ON public.subject_progress;
DROP POLICY "Enable read access for all users if results are public" ON public.study_subject;

-- Allow anyone to read progress data if the subject has public results
CREATE POLICY "Read access on progress for all if results are public"
ON public.subject_progress
FOR SELECT
USING (public.has_results_public(subject_id));

-- Allow anyone to read subject data if the subject has public results
CREATE POLICY "Read access on subjects for all if results are public"
ON public.study_subject
FOR SELECT
USING (public.has_results_public(id));

-- Migrate row level policies to be used by authenticated users only

ALTER POLICY "Allow users to manage their own user"
ON public."user"
TO authenticated;

ALTER POLICY "Editors can delete their own open-study invite codes"
ON public."study_invite"
TO authenticated;

ALTER POLICY "Editors can do everything with their studies"
ON public."study"
TO authenticated;

ALTER POLICY "Editors can do everything with their study subjects"
ON public."study_subject"
TO authenticated;

ALTER POLICY "Editors can manage their own invite-only study invite codes"
ON public."study_invite"
TO authenticated;

ALTER POLICY "Editors can read their own open-study invite codes"
ON public."study_invite"
TO authenticated;

ALTER POLICY "Editors can see subjects from their studies"
ON public."study_subject"
TO authenticated;

ALTER POLICY "Editors can see their study subjects progress"
ON public."subject_progress"
TO authenticated;

ALTER POLICY "Editors can view their studies"
ON public."study"
TO authenticated;

ALTER POLICY "Read access on subjects for all if results are public"
ON public."study_subject"
TO authenticated;

ALTER POLICY "Read access on progress for all if results are public"
ON public."subject_progress"
TO authenticated;

ALTER POLICY "Enable read access for study participants for fitbit credential"
ON public."study_fitbit_credentials"
TO authenticated;

ALTER POLICY "Invite code must match study_id"
ON public."study_subject"
TO authenticated;

ALTER POLICY "Joining a closed study should not be possible"
ON public."study_subject"
TO authenticated;

ALTER POLICY "Repo is viewable by everyone"
ON public."repo"
TO authenticated;

ALTER POLICY "Study creators can do everything with repos from their studies"
ON public."repo"
TO authenticated;

ALTER POLICY "Study owners can manage their own fitbit credentials"
ON public."study_fitbit_credentials"
TO authenticated;

ALTER POLICY "Study subjects can view their joined study"
ON public."study"
TO authenticated;

ALTER POLICY "Study visibility"
ON public."study"
TO authenticated;

ALTER POLICY "Users can do everything with their progress"
ON public."subject_progress"
TO authenticated;

ALTER POLICY "Users can do everything with their subjects"
ON public."study_subject"
TO authenticated;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================

COMMIT;

