create or replace function handle_auto_verify_app_accounts()
returns trigger as $$
begin
  -- Automatically verify participant app accounts with fake emails
  if new.email like '%@fake-studyu-email-domain.com' then
    update auth.users
      set email_confirmed_at = now()
    where id = new.id;
  end if;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists auto_verify_app_accounts on auth.users;
create trigger auto_verify_app_accounts
after insert on auth.users
for each row execute function handle_auto_verify_app_accounts();
