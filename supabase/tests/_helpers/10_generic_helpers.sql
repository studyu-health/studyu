SELECT plan(0);

-- Either one of the results must be true for the test to complete successfully
CREATE OR REPLACE FUNCTION tests.is_either_true(
    description text,
    VARIADIC results boolean[]
)
RETURNS TEXT AS $$
DECLARE
    result BOOLEAN;
    output TEXT;
    result_details TEXT;
BEGIN
    result := false;

    -- Check if any of the results is true
    FOR i IN 1..array_length(results, 1) LOOP
        IF results[i] = true THEN
            result := true;
            EXIT; -- Exit the loop once a true result is found
        END IF;
    END LOOP;

    output := extensions.ok(result, description);

    -- Build the result details only if there are false results
    IF NOT result THEN
        FOR i IN 1..array_length(results, 1) LOOP
            result_details := result_details || E'\nTest ' || i || ': ' || results[i];
        END LOOP;
    END IF;

    RETURN output || CASE result WHEN TRUE THEN '' ELSE E'\n' || extensions.diag(result_details) END;
END;
$$ LANGUAGE plpgsql;

-- Create a polymorphic function that checks if two input elements are not distinct from each other
CREATE OR REPLACE FUNCTION tests.is_equal(value1 anyelement, value2 anyelement)
RETURNS BOOLEAN
AS $$
BEGIN
  -- would prefer IS NOT DISTINCT FROM, but that is not supported in plpgsql
  RETURN NOT value1 IS DISTINCT FROM value2;
END;
$$ LANGUAGE plpgsql;
