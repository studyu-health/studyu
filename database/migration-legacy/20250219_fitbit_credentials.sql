--
-- Name: study_fitbit_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.study_fitbit_credentials (
    study_id uuid NOT NULL PRIMARY KEY,
    fitbit_credentials jsonb NOT NULL
);

ALTER TABLE public.study_fitbit_credentials OWNER TO postgres;

COMMENT ON TABLE public.study_fitbit_credentials IS 'Fitbit credentials for studies';

--
-- Name: "Enable read access for study participants for fitbit credentials and owners"; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for study participants for fitbit credentials and owners"
  ON public.study_fitbit_credentials
  FOR SELECT
  USING (
    (
      SELECT public.can_edit(auth.uid(), study)
      FROM public.study
      WHERE study.id = study_fitbit_credentials.study_id
    )
    OR public.is_study_subject_of(auth.uid(), study_fitbit_credentials.study_id)
  );

--
-- Name: "Study owners can manage their own fitbit credentials"; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Study owners can manage their own fitbit credentials"
  ON public.study_fitbit_credentials
  FOR ALL
  USING (
    (
      SELECT public.can_edit(auth.uid(), study)
      FROM public.study
      WHERE study.id = study_fitbit_credentials.study_id
    )
  )
  WITH CHECK (
    (
      SELECT public.can_edit(auth.uid(), study)
      FROM public.study
      WHERE study.id = study_fitbit_credentials.study_id
    )
  );

--
-- Name: study_fitbit_credentials study_fitbit_credentials_studyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_fitbit_credentials
    ADD CONSTRAINT "study_fitbit_credentials_studyId_fkey"
    FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;

--
-- Name: study_fitbit_credentials; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.study_fitbit_credentials ENABLE ROW LEVEL SECURITY;
