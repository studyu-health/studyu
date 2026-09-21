---
name: asd-ste100
description: 'Rewrite text agents consume — commits, PR bodies, review comments, code comments, errors, docs — into unambiguous STE100. Use when writing or editing any text another agent or non-native reader will parse. Triggers on: disambiguate, simplify, STE100, "make clearer", "non-native", or any commit, PR, review, or comment edit. Not for creative or marketing copy.'
---

# Simplified Technical English

This skill adapts the MIT-licensed `danyuchn/asd-ste100-skill` for concise, unambiguous technical communication. It applies ASD-STE100 principles but does not include the official ASD dictionary and cannot certify formal ASD-STE100 compliance. See `LICENSE` for attribution.

## Modes

- Use **Strict** for procedures, error messages, tool descriptions, prompts, and inter-agent instructions.
- Use **STE-flavored** for PR descriptions, review comments, READMEs, changelogs, and explanatory prose.

Infer the mode from the text unless the user specifies one. Keep the choice internal unless the user asks for an explanation.

## Rules

- Preserve every fact, condition, exception, number, and scope qualifier.
- Preserve uncertainty. Do not change `may`, `could`, or `likely` into a factual claim.
- Use active voice when the actor is known and relevant.
- Give one instruction or main idea per sentence.
- Keep instructions at 20 words or fewer when precision permits. Keep descriptions at 25 words or fewer when precision permits.
- Prefer simple verb forms and direct verbs over nominalizations.
- Replace ambiguous phrasal verbs with a single plain verb.
- Use one term for one concept. Do not rotate synonyms for the same object or action.
- Keep noun clusters to three words when possible.
- Do not use semicolons. Split long compound sentences.
- Use lists for three or more steps or conditions.
- Remove empty hedges and marketing adjectives, but retain meaningful modality.
- Do not simplify past the point of accuracy.

## Process

1. Read the complete text for meaning before rewriting it.
2. Identify ambiguous terms, hidden actors, stacked clauses, dropped words, phrasal verbs, nominalizations, and inconsistent terminology.
3. Rewrite each problem while preserving the original claim strength and scope.
4. If a shorter version loses required precision, keep the precise wording.
5. Check that the result adds no new facts and removes no conditions.

## Output

By default, output only the rewritten text. Do not add a preamble, mode announcement, change summary, or closing offer.

If the user asks for reasoning, provide a table with `Rule`, `Original`, and `Simplified` columns, followed by the selected mode. If no rewrite is needed, state that the text is already clear.
