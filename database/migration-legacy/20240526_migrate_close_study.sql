CREATE TYPE public.study_status AS ENUM (
    'draft',
    'running',
    'closed'
);

ALTER TYPE public.study_status OWNER TO postgres;

ALTER TABLE public.study
ADD COLUMN status public.study_status DEFAULT 'draft'::public.study_status NOT NULL;

-- Migrate existing studies from published to study_status
UPDATE public.study SET status = CASE
    WHEN status != 'draft'::public.study_status THEN status
    WHEN published THEN 'running'::public.study_status
    ELSE status
END;

-- Migrate policy
--DROP POLICY "Editors can do everything with their studies" ON public.study;

DROP POLICY "Everybody can view designated published studies" ON public.study;

CREATE POLICY "Study visibility" ON public.study FOR SELECT
USING ((status = 'running'::public.study_status OR status = 'closed'::public.study_status)
AND (registry_published = true OR participation = 'open'::public.participation OR result_sharing = 'public'::public.result_sharing));

CREATE POLICY "Editors can view their studies" ON public.study FOR SELECT USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.allow_updating_only_study()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  whitelist TEXT[] := TG_ARGV::TEXT[];
  schema_table TEXT;
  column_name TEXT;
  rec RECORD;
  new_value TEXT;
  old_value TEXT;
BEGIN

  -- The user 'postgres' should be able to update any record, e.g. when using Supabase Studio
  IF CURRENT_USER = 'postgres' THEN
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

ALTER FUNCTION public.allow_updating_only_study() OWNER TO postgres;

-- Only allow updating status, registry_published and result_sharing of the study table when in draft mode
CREATE OR REPLACE TRIGGER study_status_update_permissions
  BEFORE UPDATE
  ON public.study
  FOR EACH ROW
  EXECUTE FUNCTION public.allow_updating_only_study('updated_at', 'status', 'registry_published', 'result_sharing');

CREATE POLICY "Joining a closed study should not be possible" ON public.study_subject
    AS RESTRICTIVE
    FOR INSERT
    WITH CHECK (NOT EXISTS (
    SELECT 1
    FROM public.study
    WHERE study.id = study_subject.study_id
      AND study.status = 'closed'::public.study_status
));
