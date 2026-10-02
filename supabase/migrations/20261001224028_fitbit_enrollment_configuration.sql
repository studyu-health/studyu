-- Allow Fitbit authorization before creating an eligible study subject.
-- Keep direct table access and account recovery permissions unchanged.
CREATE FUNCTION public.get_enrollment_fitbit_configuration(
    p_study_id uuid,
    p_invite_code text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT jsonb_build_object(
        'study_id', credentials.study_id,
        'fitbit_credentials', credentials.fitbit_credentials
    )
    FROM public.study AS study
    JOIN public.study_fitbit_credentials AS credentials
        ON credentials.study_id = study.id
    WHERE auth.uid() IS NOT NULL
        AND study.id = p_study_id
        AND study.status = 'running'::public.study_status
        AND (
            study.participation = 'open'::public.participation
            OR EXISTS (
                SELECT 1 FROM public.study_invite AS invite
                WHERE invite.study_id = study.id AND invite.code = p_invite_code
            )
        );
$$;

REVOKE ALL ON FUNCTION public.get_enrollment_fitbit_configuration(uuid, text)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_enrollment_fitbit_configuration(uuid, text)
    TO authenticated;
