BEGIN;

-- Explicit Data API grants for Supabase projects where public tables are not
-- exposed automatically. RLS policies continue to decide row-level access.

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

-- Public app configuration is intentionally readable before sign-in.
GRANT SELECT ON TABLE public.app_config TO anon, authenticated, service_role;

-- Authenticated users access application tables through existing RLS policies.
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.repo TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.study TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.study_fitbit_credentials TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.study_invite TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.study_subject TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.subject_progress TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public."user" TO authenticated, service_role;

-- Anonymous users need table-level SELECT for RLS to return zero rows instead
-- of failing before policy evaluation.
GRANT SELECT ON TABLE public.study TO anon;
GRANT SELECT ON TABLE public."user" TO anon;

-- Export view is read-only; security_invoker makes underlying table RLS apply.
GRANT SELECT ON TABLE public.study_progress_export TO authenticated, service_role;

-- RLS helper functions are callable by authenticated users through policies.
GRANT EXECUTE ON FUNCTION public.can_edit(uuid, public.study) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_study_subject_of(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_results_public(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(text) TO authenticated;

-- Computed-field functions exposed by PostgREST as virtual columns on the
-- study / study_subject resources. The canonical schema migration revokes
-- EXECUTE FROM public on these helpers, which also removes the inherited grant
-- from authenticated; without an explicit grant the Designer dashboard studies
-- fetch fails with permission denied (403) on any request that selects the
-- study_participant_count, study_ended_count, active_subject_count, or
-- study_missed_days computed columns. Grant to authenticated only; anon keeps
-- the revoked state since anonymous flows request plain columns, not computed
-- fields. Inner helper functions called transitively by the computed fields
-- (has_study_ended, study_length, is_active_subject, last_completed_task,
-- subject_current_day, subject_total_active_days, study_total_tasks,
-- study_active_days) are granted together because non-SECURITY-DEFINER sql
-- functions require EXECUTE on every function in the call chain.
GRANT EXECUTE ON FUNCTION public.study_participant_count(public.study) TO authenticated;
GRANT EXECUTE ON FUNCTION public.study_ended_count(public.study) TO authenticated;
GRANT EXECUTE ON FUNCTION public.active_subject_count(public.study) TO authenticated;
GRANT EXECUTE ON FUNCTION public.study_missed_days(public.study) TO authenticated;
GRANT EXECUTE ON FUNCTION public.study_active_days(public.study) TO authenticated;
GRANT EXECUTE ON FUNCTION public.study_length(public.study) TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_study_ended(public.study_subject) TO authenticated;
GRANT EXECUTE ON FUNCTION public.study_total_tasks(public.study_subject) TO authenticated;
GRANT EXECUTE ON FUNCTION public.subject_current_day(public.study_subject) TO authenticated;
GRANT EXECUTE ON FUNCTION public.subject_total_active_days(public.study_subject) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_active_subject(uuid, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.last_completed_task(uuid) TO authenticated;

COMMIT;
