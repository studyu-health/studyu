CREATE FUNCTION public.list_nutrition_library(p_subject_id uuid)
RETURNS TABLE (
    id uuid,
    subject_id uuid,
    created_at timestamptz,
    updated_at timestamptz,
    snapshot jsonb
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
    WITH logged_food_ids AS (
        SELECT DISTINCT food_id #>> '{}' AS id
        FROM public.subject_progress AS progress
        CROSS JOIN LATERAL jsonb_path_query(
            progress.result, '$.result.meals[*].foods[*].foodId'
        ) AS food_id
        WHERE progress.subject_id = p_subject_id
          AND progress.result_type = 'DailyRecall'
    )
    SELECT definition.id, definition.subject_id, definition.created_at,
           definition.updated_at, version.snapshot
    FROM public.nutrition_food_definition AS definition
    JOIN public.nutrition_food_version AS version
      ON version.id = definition.current_version_id
     AND version.food_id = definition.id
    WHERE definition.subject_id = p_subject_id
      AND definition.deleted_at IS NULL
      AND (
          definition.library_visible
          OR definition.id::text IN (SELECT logged_food_ids.id FROM logged_food_ids)
      );
$$;

REVOKE ALL ON FUNCTION public.list_nutrition_library(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.list_nutrition_library(uuid) TO authenticated;

CREATE FUNCTION studyu_private.keep_nutrition_food_deleted()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    NEW.deleted_at := COALESCE(OLD.deleted_at, NEW.deleted_at);
    IF NEW.deleted_at IS NOT NULL THEN
        NEW.library_visible := false;
    END IF;
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION studyu_private.keep_nutrition_food_deleted()
FROM PUBLIC, anon, authenticated;

CREATE TRIGGER keep_nutrition_food_deleted
BEFORE UPDATE OF deleted_at ON public.nutrition_food_definition
FOR EACH ROW EXECUTE FUNCTION studyu_private.keep_nutrition_food_deleted();
