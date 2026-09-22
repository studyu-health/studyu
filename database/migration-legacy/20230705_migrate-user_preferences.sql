ALTER TABLE public."user" ADD COLUMN preferences jsonb;


--
-- Name: Allow users to manage their own user; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow users to manage their own user"
ON public."user" FOR ALL
USING (
  auth.uid() = id
);
