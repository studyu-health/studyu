BEGIN;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('nutrition-photos', 'nutrition-photos', false, 6000000, ARRAY['image/jpeg']);

CREATE POLICY nutrition_photos_read ON storage.objects
    FOR SELECT TO authenticated
    USING (bucket_id = 'nutrition-photos'
        AND split_part(name, '/', 1) = (SELECT auth.uid())::text);

CREATE POLICY nutrition_photos_add ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'nutrition-photos'
        AND split_part(name, '/', 1) = (SELECT auth.uid())::text
        AND name ~ ('^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/' ||
            '[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/(item|meal)/' ||
            '[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}[.]jpg$')
        AND EXISTS (
            SELECT 1 FROM public.study_subject AS subject
            WHERE subject.id::text = split_part(name, '/', 2)
              AND subject.user_id = (SELECT auth.uid())
              AND NOT subject.is_deleted
        ));

CREATE POLICY nutrition_photos_replace ON storage.objects
    FOR UPDATE TO authenticated
    USING (bucket_id = 'nutrition-photos'
        AND split_part(name, '/', 1) = (SELECT auth.uid())::text
        AND name ~ ('^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/' ||
            '[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/(item|meal)/' ||
            '[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}[.]jpg$')
        AND EXISTS (
            SELECT 1 FROM public.study_subject AS subject
            WHERE subject.id::text = split_part(name, '/', 2)
              AND subject.user_id = (SELECT auth.uid())
              AND NOT subject.is_deleted
        ))
    WITH CHECK (bucket_id = 'nutrition-photos'
        AND split_part(name, '/', 1) = (SELECT auth.uid())::text
        AND name ~ ('^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/' ||
            '[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/(item|meal)/' ||
            '[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}[.]jpg$')
        AND EXISTS (
            SELECT 1 FROM public.study_subject AS subject
            WHERE subject.id::text = split_part(name, '/', 2)
              AND subject.user_id = (SELECT auth.uid())
              AND NOT subject.is_deleted
        ));

CREATE POLICY nutrition_photos_delete ON storage.objects
    FOR DELETE TO authenticated
    USING (bucket_id = 'nutrition-photos'
        AND split_part(name, '/', 1) = (SELECT auth.uid())::text);

COMMIT;
