CREATE OR REPLACE FUNCTION public.migrate_db(participant_user_id uuid, participant_subject_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$begin
  UPDATE study_subject SET user_id = participant_user_id WHERE id = participant_subject_id;
end;$function$
;
