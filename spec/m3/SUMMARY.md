# StudyU M3 Migration — Summary

One-line: migrate `app/` + `designer_v2/` UI to Material 3 via small, verified,
spec-driven loop tasks; the skill `.agents/skills/studyu-material3/` is the design
source of truth.

## Phases

| Phase | Name | Tasks | Risk |
|---|---|---|---|
| 0 | Guardrails + bootstrap | 001-003 | low |
| 1 | Wording + links | 010-012 | low |
| 2 | Component-level migrations | 020-024 | low-med |
| 3 | Theme/token cleanup | 030-034 | med |
| 4 | Screen-by-screen migration | 040-050 | med |
| 5 | Structural migrations | 060-063, 070 | high |

## Loop rules

1. Read SUMMARY.md, DECISIONS.md, ACTIVITY.md tail, then the selected TASK-nnn.json.
2. Load the skill SKILL.md + exactly the task's `skill_refs`.
3. Do ONE task. Verify. Commit. Update task status + ACTIVITY.md. Stop.

## Measured drift baseline (2026-08-24)

- `SizedBox(width|height:)` literals: 416
- raw `Colors.*` usages: 235
- inline `fontSize:`: 80
- `BorderRadius.circular(`: 30
- `InkWell(`: 18
- `FormTableLayout` consumers: 27 files
