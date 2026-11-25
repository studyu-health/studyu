# Invite-code deletion regression

Jira: https://studyu.atlassian.net/jira/browse/STUDYU-162

The images render actual pgTAP output. The video replays that output as text. These files do not show browser testing.

The test creates two participants who share one invite code. Both have a saved answer. The study owner deletes the code.

Before the follow-up migration, five checks fail because cached invite codes prevent later subject updates. After the follow-up migration, all 21 checks pass.

- [Before image](before.png)
- [After image](after.png)
- [Video replay](regression-replay.mp4)
- [Before output](before.txt)
- [After output](after.txt)
- [Real Dart-client output](real-client.txt)

The real-client check used unchanged `SubjectProgress.save()` and `StudySubject.save(onlyUpdate: true)` against an isolated PostgREST API and database. It submitted two different answers through the same cached subject after the owner deleted its invite code. Both answers persisted exactly once. The subject was not reloaded.

Run `supabase/tests/rls/invite_deletion_test.sql` with the repository pgTAP helpers against a local test database. Apply the new migration before verification. The fixture changes roll back after each run.

Testing used a disposable database inside local Supabase. The existing local database and production were unchanged.
