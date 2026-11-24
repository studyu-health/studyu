# Invite-code deletion regression

Jira: https://studyu.atlassian.net/jira/browse/STUDYU-162

The images render actual pgTAP output. The video replays that output as text. These files do not show browser testing.

The test creates two participants who share one invite code. Both have a saved answer. The study owner deletes the code.

Before the migration, six checks fail because both participants and their answers disappear. After the migration, all 15 checks pass.

- [Before image](before.png)
- [After image](after.png)
- [Video replay](regression-replay.mp4)
- [Before output](before.txt)
- [After output](after.txt)

Run `supabase/tests/rls/invite_deletion_test.sql` with the repository pgTAP helpers against a local test database. Apply the new migration before verification. The fixture changes roll back after each run.

Testing used a disposable database inside local Supabase. The existing local database and production were unchanged.
