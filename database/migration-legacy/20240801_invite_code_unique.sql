ALTER TABLE
    public.study_invite
ADD
    CONSTRAINT study_invite_code_unique UNIQUE (code);
