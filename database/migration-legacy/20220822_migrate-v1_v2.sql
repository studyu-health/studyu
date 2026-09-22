-- ==================== TABLES ========================

--
-- Name: study_progress_export; Type: VIEW; Schema: public; Owner: supabase_admin
--

DROP VIEW IF EXISTS public.study_progress;
DROP VIEW IF EXISTS public.study_progress_export;

CREATE VIEW public.study_progress_export AS
 SELECT subject_progress.completed_at,
    subject_progress.intervention_id,
    subject_progress.task_id,
    subject_progress.result_type,
    subject_progress.result,
    subject_progress.subject_id,
    study_subject.user_id,
    study_subject.study_id,
    study_subject.started_at,
    study_subject.selected_intervention_ids
   FROM public.study_subject,
    public.subject_progress
  WHERE (study_subject.id = subject_progress.subject_id);


--
-- Name: study; Type: VIEW; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study
  ADD IF NOT EXISTS registry_published boolean DEFAULT false NOT NULL;

UPDATE public.study
    SET registry_published = true
    WHERE result_sharing = 'public';


--
-- Name: study_subject; Type: VIEW; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study_subject
  ADD IF NOT EXISTS is_deleted boolean DEFAULT false NOT NULL;


-- ==================== FUNCTIONS ========================

--
-- Name: is_subject_of(uuid, public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.is_study_subject_of(_user_id uuid, _study_id uuid) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM study_subject
    WHERE study_subject.user_id = _user_id AND study_subject.study_id = _study_id
  )
$$;


ALTER FUNCTION public.is_study_subject_of(_user_id uuid, _study_id uuid) OWNER TO supabase_admin;

-- ============================ ROW LEVEL SECURITY POLICIES ======================================

--
-- Name: study_subject Editors can do everything with their study subjects; Type: POLICY; Schema: public; Owner: supabase_admin
--

DROP POLICY IF EXISTS "Editors can do everything with their study subjects" ON public.study_subject;

CREATE POLICY "Editors can do everything with their study subjects"
ON public.study_subject
AS PERMISSIVE FOR ALL
TO public
USING (( SELECT can_edit(uid(), study.*) AS can_edit FROM study WHERE (study.id = study_subject.study_id)));


--
-- Name: study Everybody can view (published and open) studies; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Everybody can view (published and open) studies" ON public.study FOR SELECT USING ((published = true) AND (participation = 'open'::public.participation));

-- ======================== FOREIGN KEY CONTRAINTS ======================================================

--
-- Name: subject_progress participant_progress_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.subject_progress
DROP CONSTRAINT IF EXISTS "participant_progress_subjectId_fkey",
ADD CONSTRAINT "participant_progress_subjectId_fkey"
FOREIGN KEY (subject_id)
REFERENCES public.study_subject(id)
ON DELETE CASCADE;


--
-- Name: study_invite study_invite_studyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_invite
DROP CONSTRAINT IF EXISTS "study_invite_studyId_fkey",
ADD CONSTRAINT "study_invite_studyId_fkey"
FOREIGN KEY (study_id)
REFERENCES public.study(id)
ON DELETE CASCADE;


--
-- Name: study_subject study_subject_loginCode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_subject
DROP CONSTRAINT IF EXISTS "study_subject_loginCode_fkey",
ADD CONSTRAINT "study_subject_loginCode_fkey"
FOREIGN KEY (invite_code)
REFERENCES public.study_invite(code)
ON DELETE CASCADE;


--
-- Name: repo repo_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.repo
DROP CONSTRAINT IF EXISTS "repo_studyId_fkey",
ADD CONSTRAINT "repo_studyId_fkey"
FOREIGN KEY (study_id)
REFERENCES public.study(id)
ON DELETE CASCADE;


--
-- Name: study_subject study_subject_studyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study_subject
DROP CONSTRAINT IF EXISTS "study_subject_studyId_fkey",
ADD CONSTRAINT "study_subject_studyId_fkey"
FOREIGN KEY (study_id)
REFERENCES public.study(id)
ON DELETE CASCADE;


-- ======================== STUDY FUNCTIONS =====================================

--
-- Name: study_participant_count(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

DROP FUNCTION IF EXISTS public.study_participant_count(study public.study);
CREATE FUNCTION public.study_participant_count(study public.study) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select count(1)::int
    from study_subject
    where study_id = study.id
      and study_subject.is_deleted = false;
$$;

ALTER FUNCTION public.study_participant_count(study public.study) OWNER TO supabase_admin;


--
-- Name: active_subject_count(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

DROP FUNCTION IF EXISTS public.active_subject_count(study public.study);
CREATE FUNCTION public.active_subject_count(study public.study) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
    AS $$
    SELECT
            count(1)::int
        FROM (
            SELECT
                is_active_subject (study_subject.id, 3)
            FROM
                study_subject
            WHERE
                study_id = study.id
                AND study_subject.is_deleted = false
            ) AS s
        WHERE
            s.is_active_subject;

$$;

ALTER FUNCTION public.active_subject_count(study public.study) OWNER TO supabase_admin;


--
-- Name: study_ended_count(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

DROP FUNCTION IF EXISTS public.study_ended_count(study public.study);
CREATE FUNCTION public.study_ended_count(study public.study) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
    AS $$
    SELECT
        count(1)::int
    FROM (
        SELECT
            has_study_ended (study_subject.id) AS completed
        FROM
            study_subject
        WHERE
            study_id = study.id
            AND study_subject.is_deleted = false
        ) AS s
WHERE
    completed;

$$;

ALTER FUNCTION public.study_ended_count(study public.study) OWNER TO supabase_admin;

--
-- Name: study_missed_days(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

DROP FUNCTION IF EXISTS public.study_missed_days(study_param public.study);
CREATE FUNCTION public.study_missed_days(study_param public.study) RETURNS integer[]
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select ARRAY_AGG(subject_current_day(study_subject) - subject_total_active_days(study_subject)) from study_subject
where study_subject.study_id = study_param.id and study_subject.is_deleted = false;
$$;


ALTER FUNCTION public.study_missed_days(study_param public.study) OWNER TO supabase_admin;
