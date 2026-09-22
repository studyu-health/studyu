BEGIN;

INSERT INTO public.app_config (
    id,
    app_min_version,
    app_privacy,
    app_terms,
    designer_privacy,
    designer_terms,
    imprint,
    contact,
    analytics
)
VALUES (
    'prod',
    '2.6.0',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "email": "email@example.com", "phone": "1235678", "website": "example.com", "organization": "example" }',
    '{ "dsn": "example", "enabled": false, "samplingRate": 0 }'
)
ON CONFLICT (id) DO UPDATE SET
    app_min_version = EXCLUDED.app_min_version,
    app_privacy = EXCLUDED.app_privacy,
    app_terms = EXCLUDED.app_terms,
    designer_privacy = EXCLUDED.designer_privacy,
    designer_terms = EXCLUDED.designer_terms,
    imprint = EXCLUDED.imprint,
    contact = EXCLUDED.contact,
    analytics = EXCLUDED.analytics;

COMMIT;
