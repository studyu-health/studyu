ALTER TABLE public.app_config
ADD COLUMN app_min_version text NOT NULL DEFAULT '2.6.0';
