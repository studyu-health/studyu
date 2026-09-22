ALTER TABLE public.app_config
ADD COLUMN analytics jsonb;

ALTER TABLE public.study
DROP COLUMN fhir_questionnaire;
