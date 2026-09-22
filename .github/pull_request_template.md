<!--
PR conventions:
- Jira-backed branch: `<type>/studyu-<ticket-number>-<short-description>`
- Jira-backed title: `[STUDYU-<ticket-number>] <type>[(<scope>)]: <description>`
- Approved maintenance exception: `<type>/<short-description>` and `<type>[(<scope>)]: <description>`
-->

## Jira ticket
<!-- Add the direct Jira link. For an approved ticketless maintenance PR, write: Not applicable — maintenance PR. -->

## Description
<!-- Explain the change and motivation. -->

## Visuals
<!-- Attach a screenshot for static UI changes or a screen recording for interactive UI changes. Remove this section when the PR has no visual impact. -->

## Database changes
<!-- Remove this section when the PR contains no database changes. Explain the overall reason for the database changes, then list each new migration file below. -->

### Why are these database changes needed?

<!-- Explain the overall reason this PR needs database changes. -->

### Migration details

| Migration file | What it changes | Why it is needed |
| --- | --- | --- |
| `path/to/migration.sql` | ... | ... |

## Testing Steps
<!-- Provide step-by-step instructions so reviewers can verify this change locally -->

## PR Checklist

- [ ] I tested the changes and affected user flows.
- [ ] I reviewed the full diff and checked for unintended changes.
- [ ] Screenshot or video attached, or this item removed for non-visual changes
