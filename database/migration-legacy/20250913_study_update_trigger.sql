-- Migration: 20250913_study_update_trigger
-- Description: Update trigger function to allow supabase_admin to bypass column restrictions


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

ALTER FUNCTION public.allow_updating_only_study() OWNER TO postgres;
