# AI-assisted refactoring iteration prompt — StudyU M3 migration

You are one iteration of a AI-assisted refactoring workflow. You get exactly ONE task. Fresh context: the
filesystem is your memory.

## Read first (in order)

1. `spec/m3/SUMMARY.md`
2. `spec/m3/DECISIONS.md` (locked decisions — do not reopen)
3. Last 15 entries of `spec/m3/ACTIVITY.md`
4. `spec/m3/tasks/tasks.json` — pick the lowest-numbered task with `status: "pending"`
   whose `depends_on` are all `"done"`. Prefer the task id passed by the runner, if any.
5. `spec/m3/tasks/TASK-<id>.json` — your task spec.
6. `.agents/skills/studyu-material3/SKILL.md` and exactly the files listed in the task's
   `skill_refs`. Do not read other skill references.

## Rules

- ONE task per invocation. No batching, no drive-by fixes outside `files_to_touch`.
- Respect `do_not_touch`. Respect DECISIONS.md.
- All UI strings via l10n (`tr.*`), en + de.
- Never introduce: raw `Colors.*`/`Color(0x…)`, inline `TextStyle(fontSize:)`,
  `BorderRadius.circular(` at call sites, unlabeled `InkWell`/`GestureDetector` actions,
  spacing off the 4/8 grid, hardcoded UI text.
- Intentional StudyU patterns (PrimaryButton API, TwoColumnLayout, ThemeConfig muted
  roles, brand linkColor) are preserved, not replaced.

## Execute

1. Explore only the files in the task spec + their immediate neighbors.
2. Write/adjust the failing test first if the task lists a test target.
3. Implement the minimal change meeting `acceptance_criteria`.
4. Run every command in `verification`. Fix failures within task scope only.
5. If blocked, set task `status: "blocked"` with a `blocked_reason`, append an ACTIVITY.md
   entry, and stop.

## Finish

1. Update `spec/m3/tasks/TASK-<id>.json` (`status: "done"` only if all verification passed)
   and the matching entry in `spec/m3/tasks/tasks.json`.
2. Append an ACTIVITY.md entry (format at top of that file) with commit sha, files,
   verification results, visual evidence note, and notes for the next iteration.
3. Commit: `<type>(<scope>): <description>` (Conventional Commits, lowercase) with
   trailer `[M3 TASK-<id>]`. Include DECISIONS/ACTIVITY/task-file updates in the
   same commit. Do NOT push; do NOT open a PR.
4. Stop.
