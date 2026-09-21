BEGIN;

-- Return the participant-facing study payload and invite intervention selection
-- in one RPC. Anonymous callers cannot read study_invite directly, so the
-- SECURITY DEFINER function must include the preselected intervention IDs.

-- PostgreSQL cannot replace a function with a different return type. Drop the
-- dependent policy before replacing the composite-returning function with jsonb.
DROP POLICY IF EXISTS "Invite code must match study_id" ON public.study_subject;
DROP FUNCTION IF EXISTS public.get_study_record_from_invite(text);

CREATE FUNCTION public.get_study_record_from_invite(invite_code text)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT jsonb_build_object(
    'id', s.id,
    -- Study.fromJson requires user_id, but invite callers do not need the
    -- owner UUID. Return a neutral UUID instead of leaking editor identity.
    'user_id', '00000000-0000-0000-0000-000000000000',
    'title', s.title,
    'description', s.description,
    'participation', s.participation,
    'result_sharing', s.result_sharing,
    'contact', s.contact,
    'icon_name', s.icon_name,
    'published', s.published,
    'status', s.status,
    'questionnaire', s.questionnaire,
    'eligibility_criteria', s.eligibility_criteria,
    'consent', s.consent,
    'interventions', s.interventions,
    'observations', s.observations,
    'schedule', s.schedule,
    'report_specification', s.report_specification,
    'results', s.results,
    -- Editor emails are not participant-facing invite data.
    'collaborator_emails', '[]'::jsonb,
    'registry_published', s.registry_published,
    'preselected_intervention_ids', si.preselected_intervention_ids
  )
  FROM public.study s
  JOIN public.study_invite si ON si.study_id = s.id
  WHERE invite_code = si.code;
$$;

REVOKE EXECUTE ON FUNCTION public.get_study_record_from_invite(
    text
) FROM public;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(
    text
) TO authenticated;

CREATE POLICY "Invite code must match study_id" ON public.study_subject
AS RESTRICTIVE FOR INSERT TO authenticated
WITH CHECK (
    invite_code IS NULL
    OR study_id IN (
        SELECT (
            public.get_study_record_from_invite(study_subject.invite_code)
            ->> 'id'
        )::uuid
    )
);

COMMIT;
