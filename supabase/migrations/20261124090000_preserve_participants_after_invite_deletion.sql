BEGIN;

ALTER TABLE public.study_subject
    DROP CONSTRAINT "study_subject_loginCode_fkey",
    ADD CONSTRAINT "study_subject_loginCode_fkey"
        FOREIGN KEY (invite_code) REFERENCES public.study_invite(code)
        ON DELETE SET NULL;

COMMIT;
