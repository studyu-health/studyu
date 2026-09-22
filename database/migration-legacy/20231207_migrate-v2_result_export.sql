BEGIN;

-- Function: has_results_public(uuid)
CREATE FUNCTION public.has_results_public(psubject_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
    RETURN (
        SELECT EXISTS(
            SELECT 1
            FROM study, study_subject
            WHERE (study_subject.study_id = study.id AND psubject_id = study_subject.id AND study.result_sharing = 'public'::public.result_sharing)
        )
    );
END;
$$;

ALTER FUNCTION public.has_results_public(psubject_id uuid) OWNER TO postgres;

-- Policy: Enable read access for all users if results are public (subject_progress)
CREATE POLICY "Enable read access for all users if results are public" ON public.subject_progress
    USING (public.has_results_public(subject_id));

-- Policy: Enable read access for all users if results are public (study_subject)
CREATE POLICY "Enable read access for all users if results are public" ON public.study_subject
    USING (public.has_results_public(id));

-- Row Security: study_progress_export
ALTER VIEW public.study_progress_export SET (security_invoker = on);

COMMIT;
