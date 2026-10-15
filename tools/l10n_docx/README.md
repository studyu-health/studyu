# l10n_docx

Round-trips StudyU's ARB localization files through a Word document so
non-technical collaborators can review and propose translations without
touching git or JSON.

## What it does

- **export**: reads `app_en.arb` + `app_<locale>.arb` for a module and writes
  a `.docx` review table — English, Current translation, a blank Proposed
  column, and a blank Comments column.
- **import**: reads a filled-in `.docx` back and writes accepted proposals
  into `app_<locale>.arb`, preserving that file's existing key order and
  formatting exactly. Prints a report of what was applied and what was
  skipped, and why.

Korean is already fully translated, so this is a **review** workflow: a
blank Proposed cell means "the current translation is fine," not "delete
this."

## Setup

```
cd tools/l10n_docx
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

## Usage

```
# Generate the review documents (one per module)
.venv/bin/python l10n_docx.py export --module app --locale ko
.venv/bin/python l10n_docx.py export --module designer --locale ko

# -> tools/l10n_docx/out/studyu-app-ko.docx
# -> tools/l10n_docx/out/studyu-designer-ko.docx
```

Send those two files to the translator. Ask them to:

- Fill in **Proposed** only where they'd change the current translation.
- Leave **Proposed** blank to accept the current translation as-is.
- Use **Comments** for anything else — tone, ambiguity, missing context.

They can return the file however they edited it — Word, LibreOffice, and
Google Docs (downloaded back to `.docx`) have all been verified to preserve
what the tool needs to read it back.

```
# Apply their proposals
.venv/bin/python l10n_docx.py import --module app --locale ko path/to/returned-app-ko.docx
.venv/bin/python l10n_docx.py import --module designer --locale ko path/to/returned-designer-ko.docx
```

This writes straight into `app/lib/l10n/app_ko.arb` (or the designer
equivalent) and prints a summary. **Review the result with `git diff` before
committing** — that diff is the safety net, not a confirmation prompt.

A non-zero exit code means at least one row was skipped; read the report to
see why. Common reasons:

| Reason | What happened |
|---|---|
| `placeholder validation failed` | The proposal dropped or renamed a `{placeholder}` that must survive — the app would crash or mis-render if this were applied. Ask the translator to keep it. |
| `row edited` | The English cell itself was changed, so the tool can no longer be sure which key the row belongs to. Undo that edit, or re-export and redo the change. |
| `duplicated row` | The same row was copied/pasted in the document, so its hidden identity marker now appears twice. Delete the extra copy. |
| `English source changed since export` | The English string changed in git after this document was generated. Re-export and ask for the proposal again. |
| `key removed from English source since export` | The key no longer exists in the app. Nothing to do. |
| `missing or unparseable marker` | A row lost its hidden identity marker (rare — usually from heavy reformatting). Redo that row from a fresh export. |

Translator comments land in `tools/l10n_docx/out/comments-<locale>-<date>.md`
in addition to the printed report — the ARB format has nowhere to store them.

## Adding a new locale or module

- **New locale** (e.g. Turkish): no code changes. Run
  `export --module app --locale tr`, etc. — it works as soon as
  `app_tr.arb` exists (even as `{"@@locale": "tr"}`, i.e. empty).
- **New module**: add one entry to `MODULES` in `arb.py`.

## Tests

```
.venv/bin/python -m pytest tests/ -q
```

Covers ARB ordering/round-trip fidelity (including a byte-identical check
against the real repo files), ICU placeholder parsing against every real
placeholder string in the codebase, document generation/parsing, and an
end-to-end import with deliberately injected violations.
