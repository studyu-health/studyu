BEGIN;

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE TYPE "public"."git_provider" AS ENUM (
    'gitlab'
);


ALTER TYPE "public"."git_provider" OWNER TO "postgres";


CREATE TYPE "public"."participation" AS ENUM (
    'open',
    'invite'
);


ALTER TYPE "public"."participation" OWNER TO "postgres";


CREATE TYPE "public"."result_sharing" AS ENUM (
    'public',
    'private',
    'organization'
);


ALTER TYPE "public"."result_sharing" OWNER TO "postgres";


CREATE TYPE "public"."study_status" AS ENUM (
    'draft',
    'running',
    'closed'
);


ALTER TYPE "public"."study_status" OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."study" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "contact" "jsonb" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text" NOT NULL,
    "icon_name" "text" NOT NULL,
    "published" boolean DEFAULT false NOT NULL,
    "status" "public"."study_status" DEFAULT 'draft'::"public"."study_status" NOT NULL,
    "registry_published" boolean DEFAULT false NOT NULL,
    "questionnaire" "jsonb" NOT NULL,
    "eligibility_criteria" "jsonb" NOT NULL,
    "observations" "jsonb" NOT NULL,
    "interventions" "jsonb" NOT NULL,
    "consent" "jsonb" NOT NULL,
    "schedule" "jsonb" NOT NULL,
    "report_specification" "jsonb" NOT NULL,
    "results" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "participation" "public"."participation" DEFAULT 'invite'::"public"."participation" NOT NULL,
    "result_sharing" "public"."result_sharing" DEFAULT 'private'::"public"."result_sharing" NOT NULL,
    "collaborator_emails" "text"[] DEFAULT '{}'::"text"[] NOT NULL
);


ALTER TABLE "public"."study" OWNER TO "postgres";


COMMENT ON COLUMN "public"."study"."published" IS 'Deprecated: Use "status" column to track publication state.';



COMMENT ON COLUMN "public"."study"."user_id" IS 'UserId of study creator';



CREATE OR REPLACE FUNCTION "public"."active_subject_count"("study" "public"."study") RETURNS integer
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
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


ALTER FUNCTION "public"."active_subject_count"("study" "public"."study") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."active_subject_count"("study" "public"."study") IS 'TODO: Let research decide when user is not active anymore. Currently set to hardcoded number in days.';



CREATE OR REPLACE FUNCTION "public"."allow_updating_only_study"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $_$
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
$_$;


ALTER FUNCTION "public"."allow_updating_only_study"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_edit"("user_id" "uuid", "study_param" "public"."study") RETURNS boolean
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  SELECT study_param.user_id = user_id
    OR (SELECT email FROM public.user WHERE id = user_id) = ANY (study_param.collaborator_emails);
$$;


ALTER FUNCTION "public"."can_edit"("user_id" "uuid", "study_param" "public"."study") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_study_record_from_invite"("invite_code" "text") RETURNS "public"."study"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
  SELECT * FROM public.study
  WHERE study.id = (
    SELECT study_invite.study_id
    FROM public.study_invite
    WHERE invite_code = study_invite.code
  );
$$;


ALTER FUNCTION "public"."get_study_record_from_invite"("invite_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
  insert into public.user (id, email)
  values (new.id, new.email);
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_results_public"("psubject_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
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


ALTER FUNCTION "public"."has_results_public"("psubject_id" "uuid") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."study_subject" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "study_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "started_at" timestamp with time zone DEFAULT "now"(),
    "selected_intervention_ids" "text"[] NOT NULL,
    "invite_code" "text",
    "is_deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."study_subject" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_study_ended"("subject" "public"."study_subject") RETURNS boolean
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  SELECT public.study_length(s.*) < (DATE(now()) - DATE(subject.started_at))
  FROM public.study s
  WHERE s.id = subject.study_id;
$$;


ALTER FUNCTION "public"."has_study_ended"("subject" "public"."study_subject") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_active_subject"("psubject_id" "uuid", "days_active" integer) RETURNS boolean
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO ''
    AS $$
BEGIN
  RETURN (
    SELECT
      (DATE(now()) - public.last_completed_task (psubject_id)) <= days_active);
END;
$$;


ALTER FUNCTION "public"."is_active_subject"("psubject_id" "uuid", "days_active" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_study_subject_of"("_user_id" "uuid", "_study_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.study_subject
    WHERE study_subject.user_id = _user_id AND study_subject.study_id = _study_id
  )
$$;


ALTER FUNCTION "public"."is_study_subject_of"("_user_id" "uuid", "_study_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."last_completed_task"("psubject_id" "uuid") RETURNS "date"
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO ''
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


ALTER FUNCTION "public"."last_completed_task"("psubject_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_active_days"("study_param" "public"."study") RETURNS integer[]
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  SELECT ARRAY_AGG(public.subject_total_active_days(study_subject))
  FROM public.study_subject
  WHERE study_subject.study_id = study_param.id;
$$;


ALTER FUNCTION "public"."study_active_days"("study_param" "public"."study") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_ended_count"("study" "public"."study") RETURNS integer
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
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


ALTER FUNCTION "public"."study_ended_count"("study" "public"."study") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_length"("study_param" "public"."study") RETURNS integer
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
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


ALTER FUNCTION "public"."study_length"("study_param" "public"."study") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_missed_days"("study_param" "public"."study") RETURNS integer[]
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  select ARRAY_AGG(public.subject_current_day(study_subject) - public.subject_total_active_days(study_subject)) from public.study_subject
where study_subject.study_id = study_param.id and study_subject.is_deleted = false;
$$;


ALTER FUNCTION "public"."study_missed_days"("study_param" "public"."study") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_participant_count"("study" "public"."study") RETURNS integer
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  select count(1)::int
    from public.study_subject
    where study_id = study.id
      and study_subject.is_deleted = false;
$$;


ALTER FUNCTION "public"."study_participant_count"("study" "public"."study") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_total_tasks"("subject" "public"."study_subject") RETURNS integer
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  select count(1)::int
    from public.subject_progress
    where subject_id = subject.id;
$$;


ALTER FUNCTION "public"."study_total_tasks"("subject" "public"."study_subject") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."subject_current_day"("subject" "public"."study_subject") RETURNS integer
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  SELECT
    CASE
      WHEN public.has_study_ended(subject)
      THEN (SELECT public.study_length(study) FROM public.study WHERE id = subject.study_id)::int
      ELSE DATE(now()) - DATE(subject.started_at)
    END;
$$;


ALTER FUNCTION "public"."subject_current_day"("subject" "public"."study_subject") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."subject_total_active_days"("subject" "public"."study_subject") RETURNS integer
    LANGUAGE "sql" STABLE
    SET "search_path" TO ''
    AS $$
  SELECT COUNT(DISTINCT DATE(completed_at))::int
  FROM public.subject_progress
  WHERE subject_id = subject.id
  AND DATE(completed_at) < DATE(now());
$$;


ALTER FUNCTION "public"."subject_total_active_days"("subject" "public"."study_subject") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."app_config" (
    "id" "text" NOT NULL,
    "app_min_version" "text" NOT NULL,
    "app_privacy" "jsonb" NOT NULL,
    "app_terms" "jsonb" NOT NULL,
    "designer_privacy" "jsonb" NOT NULL,
    "designer_terms" "jsonb" NOT NULL,
    "imprint" "jsonb" NOT NULL,
    "contact" "jsonb" DEFAULT '{"email": "hpi-info@hpi.de", "phone": "+49-(0)331 5509-0", "website": "https://hpi.de/", "organization": "Hasso Plattner Institute"}'::"jsonb" NOT NULL,
    "analytics" "jsonb"
);


ALTER TABLE "public"."app_config" OWNER TO "postgres";


COMMENT ON TABLE "public"."app_config" IS 'Stores app config for different envs';



CREATE TABLE IF NOT EXISTS "public"."repo" (
    "project_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "study_id" "uuid" NOT NULL,
    "provider" "public"."git_provider" NOT NULL
);


ALTER TABLE "public"."repo" OWNER TO "postgres";


COMMENT ON TABLE "public"."repo" IS 'Git repo where the generated project is stored';



CREATE TABLE IF NOT EXISTS "public"."study_fitbit_credentials" (
    "study_id" "uuid" NOT NULL,
    "fitbit_credentials" "jsonb" NOT NULL
);


ALTER TABLE "public"."study_fitbit_credentials" OWNER TO "postgres";


COMMENT ON TABLE "public"."study_fitbit_credentials" IS 'Fitbit credentials for studies';



CREATE TABLE IF NOT EXISTS "public"."study_invite" (
    "code" "text" NOT NULL,
    "study_id" "uuid" NOT NULL,
    "preselected_intervention_ids" "text"[]
);


ALTER TABLE "public"."study_invite" OWNER TO "postgres";


COMMENT ON TABLE "public"."study_invite" IS 'Study invite codes';



COMMENT ON COLUMN "public"."study_invite"."preselected_intervention_ids" IS 'Intervention Ids (and order) preselected by study creator';



CREATE TABLE IF NOT EXISTS "public"."subject_progress" (
    "completed_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "subject_id" "uuid" NOT NULL,
    "intervention_id" "text" NOT NULL,
    "task_id" "text" NOT NULL,
    "result_type" "text" NOT NULL,
    "result" "jsonb" NOT NULL
);


ALTER TABLE "public"."subject_progress" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."study_progress_export" WITH ("security_invoker"='on') AS
 SELECT "subject_progress"."completed_at",
    "subject_progress"."intervention_id",
    "subject_progress"."task_id",
    "subject_progress"."result_type",
    "subject_progress"."result",
    "subject_progress"."subject_id",
    "study_subject"."user_id",
    "study_subject"."study_id",
    "study_subject"."started_at",
    "study_subject"."selected_intervention_ids"
   FROM "public"."study_subject",
    "public"."subject_progress"
  WHERE ("study_subject"."id" = "subject_progress"."subject_id");


ALTER TABLE "public"."study_progress_export" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user" (
    "id" "uuid" NOT NULL,
    "email" "text",
    "preferences" "jsonb"
);


ALTER TABLE "public"."user" OWNER TO "postgres";


COMMENT ON TABLE "public"."user" IS 'Users get automatically added, when a new user is created in auth.users';



ALTER TABLE ONLY "public"."app_config"
    ADD CONSTRAINT "AppConfig_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subject_progress"
    ADD CONSTRAINT "participant_progress_pkey" PRIMARY KEY ("completed_at", "subject_id");



ALTER TABLE ONLY "public"."repo"
    ADD CONSTRAINT "repo_pkey" PRIMARY KEY ("project_id");



ALTER TABLE ONLY "public"."study_fitbit_credentials"
    ADD CONSTRAINT "study_fitbit_credentials_pkey" PRIMARY KEY ("study_id");



ALTER TABLE ONLY "public"."study_invite"
    ADD CONSTRAINT "study_invite_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."study"
    ADD CONSTRAINT "study_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."study_subject"
    ADD CONSTRAINT "study_subject_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_pkey" PRIMARY KEY ("id");



CREATE OR REPLACE TRIGGER "handle_updated_at" BEFORE UPDATE ON "public"."study" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "study_status_update_permissions" BEFORE UPDATE ON "public"."study" FOR EACH ROW EXECUTE FUNCTION "public"."allow_updating_only_study"('updated_at', 'status', 'registry_published', 'result_sharing');



ALTER TABLE ONLY "public"."subject_progress"
    ADD CONSTRAINT "participant_progress_subjectId_fkey" FOREIGN KEY ("subject_id") REFERENCES "public"."study_subject"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."repo"
    ADD CONSTRAINT "repo_studyId_fkey" FOREIGN KEY ("study_id") REFERENCES "public"."study"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."repo"
    ADD CONSTRAINT "repo_userId_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."study_fitbit_credentials"
    ADD CONSTRAINT "study_fitbit_credentials_studyId_fkey" FOREIGN KEY ("study_id") REFERENCES "public"."study"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."study_invite"
    ADD CONSTRAINT "study_invite_studyId_fkey" FOREIGN KEY ("study_id") REFERENCES "public"."study"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."study_subject"
    ADD CONSTRAINT "study_subject_loginCode_fkey" FOREIGN KEY ("invite_code") REFERENCES "public"."study_invite"("code") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."study_subject"
    ADD CONSTRAINT "study_subject_studyId_fkey" FOREIGN KEY ("study_id") REFERENCES "public"."study"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."study_subject"
    ADD CONSTRAINT "study_subject_userId_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");



ALTER TABLE ONLY "public"."study"
    ADD CONSTRAINT "study_userId_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");



CREATE POLICY "Allow users to manage their own user" ON "public"."user" TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Config is viewable by everyone" ON "public"."app_config" FOR SELECT USING (true);



CREATE POLICY "Editors can delete their own open-study invite codes" ON "public"."study_invite" FOR DELETE TO "authenticated" USING (( SELECT "public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*) AS "can_edit"
   FROM "public"."study"
  WHERE (("study"."id" = "study_invite"."study_id") AND ("study"."participation" = 'open'::"public"."participation"))));



CREATE POLICY "Editors can do everything with their studies" ON "public"."study" TO "authenticated" USING ("public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*));



CREATE POLICY "Editors can do everything with their study subjects" ON "public"."study_subject" TO "authenticated" USING (( SELECT "public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*) AS "can_edit"
   FROM "public"."study"
  WHERE ("study"."id" = "study_subject"."study_id")));



CREATE POLICY "Editors can manage their own invite-only study invite codes" ON "public"."study_invite" TO "authenticated" USING (( SELECT "public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*) AS "can_edit"
   FROM "public"."study"
  WHERE (("study"."id" = "study_invite"."study_id") AND ("study"."participation" = 'invite'::"public"."participation"))));



CREATE POLICY "Editors can read their own open-study invite codes" ON "public"."study_invite" FOR SELECT TO "authenticated" USING (( SELECT "public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*) AS "can_edit"
   FROM "public"."study"
  WHERE (("study"."id" = "study_invite"."study_id") AND ("study"."participation" = 'open'::"public"."participation"))));



CREATE POLICY "Editors can see subjects from their studies" ON "public"."study_subject" FOR SELECT TO "authenticated" USING (( SELECT "public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*) AS "can_edit"
   FROM "public"."study"
  WHERE ("study"."id" = "study_subject"."study_id")));



CREATE POLICY "Editors can see their study subjects progress" ON "public"."subject_progress" FOR SELECT TO "authenticated" USING (( SELECT "public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*) AS "can_edit"
   FROM "public"."study",
    "public"."study_subject"
  WHERE (("study"."id" = "study_subject"."study_id") AND ("study_subject"."id" = "subject_progress"."subject_id"))));



CREATE POLICY "Editors can view their studies" ON "public"."study" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Enable read access for study participants for fitbit credential" ON "public"."study_fitbit_credentials" FOR SELECT TO "authenticated" USING ((( SELECT "public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*) AS "can_edit"
   FROM "public"."study"
  WHERE ("study"."id" = "study_fitbit_credentials"."study_id")) OR "public"."is_study_subject_of"(( SELECT "auth"."uid"() AS "uid"), "study_id")));



CREATE POLICY "Invite code must match study_id" ON "public"."study_subject" AS RESTRICTIVE FOR INSERT TO "authenticated" WITH CHECK ((("invite_code" IS NULL) OR ("study_id" IN ( SELECT ("public"."get_study_record_from_invite"("study_subject"."invite_code"))."id" AS "id"))));



CREATE POLICY "Joining a closed study should not be possible" ON "public"."study_subject" AS RESTRICTIVE FOR INSERT TO "authenticated" WITH CHECK ((NOT (EXISTS ( SELECT 1
   FROM "public"."study"
  WHERE (("study"."id" = "study_subject"."study_id") AND ("study"."status" = 'closed'::"public"."study_status"))))));



CREATE POLICY "Read access on progress for all if results are public" ON "public"."subject_progress" FOR SELECT TO "authenticated" USING ("public"."has_results_public"("subject_id"));



CREATE POLICY "Read access on subjects for all if results are public" ON "public"."study_subject" FOR SELECT TO "authenticated" USING ("public"."has_results_public"("id"));



CREATE POLICY "Repo is viewable by everyone" ON "public"."repo" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Study creators can do everything with repos from their studies" ON "public"."repo" TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = ( SELECT "study"."user_id"
   FROM "public"."study"
  WHERE ("repo"."study_id" = "study"."id"))));



CREATE POLICY "Study owners can manage their own fitbit credentials" ON "public"."study_fitbit_credentials" TO "authenticated" USING (( SELECT "public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*) AS "can_edit"
   FROM "public"."study"
  WHERE ("study"."id" = "study_fitbit_credentials"."study_id"))) WITH CHECK (( SELECT "public"."can_edit"(( SELECT "auth"."uid"() AS "uid"), "study".*) AS "can_edit"
   FROM "public"."study"
  WHERE ("study"."id" = "study_fitbit_credentials"."study_id")));



CREATE POLICY "Study subjects can view their joined study" ON "public"."study" FOR SELECT TO "authenticated" USING ("public"."is_study_subject_of"(( SELECT "auth"."uid"() AS "uid"), "id"));



CREATE POLICY "Study visibility" ON "public"."study" FOR SELECT TO "authenticated" USING (((("status" = 'running'::"public"."study_status") OR ("status" = 'closed'::"public"."study_status")) AND (("registry_published" = true) OR ("participation" = 'open'::"public"."participation") OR ("result_sharing" = 'public'::"public"."result_sharing"))));



CREATE POLICY "Users can do everything with their progress" ON "public"."subject_progress" TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = ( SELECT "study_subject"."user_id"
   FROM "public"."study_subject"
  WHERE ("study_subject"."id" = "subject_progress"."subject_id"))));



CREATE POLICY "Users can do everything with their subjects" ON "public"."study_subject" TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



ALTER TABLE "public"."app_config" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."repo" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."study" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."study_fitbit_credentials" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."study_invite" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."study_subject" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subject_progress" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user" ENABLE ROW LEVEL SECURITY;


-- ----------------------------------------------------------------------------
-- Manually added code below this line should be preserved on re-generation
-- ----------------------------------------------------------------------------

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- REVOKING EXECUTE PRIVILEGES

-- Functions used in RLS policies
REVOKE EXECUTE ON FUNCTION public.can_edit(uuid, public.study) FROM public, anon;
-- anon is needed for RLS on the study table
REVOKE EXECUTE ON FUNCTION public.is_study_subject_of(uuid, uuid) FROM public;
REVOKE EXECUTE ON FUNCTION public.has_results_public(uuid) FROM public, anon;

-- Computed field functions (PostgREST calls these with elevated privileges)
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
REVOKE EXECUTE ON FUNCTION public.is_active_subject(uuid, integer) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.last_completed_task(uuid) FROM public, anon;

-- RPC/API functions
REVOKE EXECUTE ON FUNCTION public.get_study_record_from_invite(text) FROM public, anon;

-- Trigger functions
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.allow_updating_only_study() FROM public, anon;


-- MORE REVOKING
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.allow_updating_only_study() FROM authenticated;

-- ----------------------------------------------------------------------------
-- End of manually added code
-- ----------------------------------------------------------------------------

RESET ALL;

COMMIT;
