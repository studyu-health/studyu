CREATE OR REPLACE FUNCTION public.study_length(study_param public.study)
RETURNS integer
LANGUAGE sql SECURITY DEFINER
AS $$
WITH s AS (
  SELECT schedule
  FROM study
  WHERE id = study_param.id
)
SELECT
  -- total study length
  (
    (schedule->>'phaseDuration')::int
    * (schedule->>'numberOfCycles')::int
    * (
        CASE
          -- if sequence = customized, count characters in sequenceCustom
          WHEN (schedule->>'sequence') = 'customized' THEN
            char_length(trim(both ' ' from COALESCE(schedule->>'sequenceCustom', '')))
          ELSE
            2 -- default for alternating, counterbalanced, random
        END
      )
  )
  +
  CASE
    WHEN (schedule->>'includeBaseline')::boolean
    THEN (schedule->>'phaseDuration')::int
    ELSE 0
  END AS length
FROM s;
$$;
