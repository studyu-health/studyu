--
-- Name: create blob storage bucket for observations; Type: value; Schema: storage; Owner: postgres
--

insert into storage.buckets (id, name) values ('observations', 'observations');

--
-- Name: authenticated Users can view their uploaded data; Type: POLICY, Schema: storage
--

CREATE POLICY "Allow authenticated Users to view own observations" ON storage.objects FOR
SELECT
TO authenticated USING (((bucket_id = 'observations'::text) AND (owner = auth.uid())));

--
-- Name: authenticated Users can upload observations to storage; Type: POLICY, Schema: storage
--

CREATE POLICY "Allow authenticated Users to upload observations" ON storage.objects FOR
INSERT
TO authenticated WITH CHECK ((bucket_id = 'observations'::text));

--
-- Name: authenticated Users can delete own observations; Type: POLICY, Schema: storage
--

CREATE POLICY "Allow authenticated Users to delete own observations" ON storage.objects FOR
DELETE
TO authenticated USING (((bucket_id = 'observations'::text) AND (owner = auth.uid())));

--
-- Name: Researchers can view observations of studies which they created; Type: POLICY, Schema: storage
--

CREATE POLICY "Allow Researchers to view observations of own studies" ON storage.objects FOR
SELECT
TO public USING (((bucket_id = 'observations'::text) AND
    (name ~~ ANY (SELECT ('%'::text || ((public.study.id)::text || '%'::text)) AS study_id
    FROM public.study
    WHERE ((public.study.user_id)::text = (auth.uid())::text)))));
