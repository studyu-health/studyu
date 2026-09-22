-- Migrate policy
-- Drop existing policy

DROP POLICY "Editors can do everything with study invite codes" ON public.study_invite;

-- Create new policy

-- Name: study_invite Editors can manage their own invite-only study invite codes; Type: POLICY; Schema: public; Owner: postgres
CREATE POLICY "Editors can manage their own invite-only study invite codes" ON public.study_invite
USING (
 (
   SELECT public.can_edit(auth.uid(), study.*) AS can_edit
   FROM public.study
   WHERE study.id = study_invite.study_id
   AND study.participation = 'invite'::public.participation
 )
);

--
-- Name: study_invite Editors can read their own open-study invite codes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Editors can read their own open-study invite codes"
ON public.study_invite
FOR SELECT
USING (
 (
  SELECT public.can_edit(auth.uid(), study.*) AS can_edit
  FROM public.study
  WHERE study.id = study_invite.study_id
  AND study.participation = 'open'::public.participation
 )
);

--
-- Name: study_invite Editors can delete their own open-study invite codes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Editors can delete their own open-study invite codes"
ON public.study_invite
FOR DELETE
USING (
  (
    SELECT public.can_edit(auth.uid(), study.*) AS can_edit
    FROM public.study
    WHERE study.id = study_invite.study_id
    AND study.participation = 'open'::public.participation
  )
);
