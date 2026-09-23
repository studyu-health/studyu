"""CLI: export ARB -> docx review table, import docx -> ARB.

Composes arb.py, document.py, validate.py. No file-format knowledge of its
own beyond the per-row decision table described in the design spec.
"""
import argparse
import sys
from collections import Counter
from datetime import date
from pathlib import Path
from typing import List, NamedTuple, Optional, Tuple

import arb
import document
import validate

OUT_DIR = Path(__file__).resolve().parent / "out"


class Skip(NamedTuple):
    key: Optional[str]
    reason: str


class Report(NamedTuple):
    module: str
    locale: str
    applied: List[Tuple[str, str]]
    skipped: List[Skip]
    comments: List[Tuple[str, str, str]]

    def render(self) -> str:
        lines = [
            "%s/%s: %d applied, %d skipped, %d comments"
            % (self.module, self.locale, len(self.applied), len(self.skipped), len(self.comments)),
        ]
        for key, reason in self.skipped:
            lines.append("  SKIP  %-40s %s" % (key or "(no key)", reason))
        return "\n".join(lines)


def import_docx(
    docx_path,
    base: Optional[Path] = None,
    apply: bool = True,
    expected_module: Optional[str] = None,
    expected_locale: Optional[str] = None,
) -> Report:
    module, locale, imported = document.read(docx_path)
    if expected_module and module != expected_module:
        raise ValueError("document is for module %r, expected %r" % (module, expected_module))
    if expected_locale and locale != expected_locale:
        raise ValueError("document is for locale %r, expected %r" % (locale, expected_locale))

    en = arb.load(module, "en", base)
    target = arb.load(module, locale, base)
    key_counts = Counter(row.key for row in imported if row.key)

    applied: List[Tuple[str, str]] = []
    skipped: List[Skip] = []
    comments: List[Tuple[str, str, str]] = []

    for row in imported:
        if row.key is None:
            skipped.append(Skip(None, "missing or unparseable marker"))
            continue
        if key_counts[row.key] > 1:
            skipped.append(Skip(row.key, "duplicated row (marker appears %d times)" % key_counts[row.key]))
            continue
        if row.key not in en or not isinstance(en[row.key], str):
            skipped.append(Skip(row.key, "key removed from English source since export"))
            continue
        current_en = en[row.key]
        if document.checksum(row.visible_english) != row.marker_checksum:
            skipped.append(Skip(row.key, "row edited (visible English no longer matches marker)"))
            continue
        if document.checksum(current_en) != row.marker_checksum:
            skipped.append(Skip(row.key, "English source changed since export"))
            continue

        if row.comment:
            comments.append((row.key, current_en, row.comment))
        if row.proposed is None:
            continue  # accept current translation, no-op

        violation = validate.compare(current_en, row.proposed)
        if violation:
            skipped.append(Skip(row.key, "placeholder validation failed: %s" % violation))
            continue
        applied.append((row.key, row.proposed))

    if apply and applied:
        for key, value in applied:
            target[key] = value
        arb.save(module, locale, target, base)

    if apply and comments:
        comments_path = (base or OUT_DIR) / ("comments-%s-%s.md" % (locale, date.today().isoformat()))
        comments_path.parent.mkdir(parents=True, exist_ok=True)
        with comments_path.open("a", encoding="utf-8") as f:
            for key, english, comment in comments:
                f.write("- **%s** (_%s_): %s\n" % (key, english, comment))

    return Report(module=module, locale=locale, applied=applied, skipped=skipped, comments=comments)


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="l10n_docx")
    sub = parser.add_subparsers(dest="command", required=True)

    exp = sub.add_parser("export", help="ARB -> docx review table")
    exp.add_argument("--module", required=True, choices=sorted(arb.MODULES))
    exp.add_argument("--locale", required=True)
    exp.add_argument("--out", type=Path, default=None)

    imp = sub.add_parser("import", help="docx review table -> ARB")
    imp.add_argument("--module", required=True, choices=sorted(arb.MODULES))
    imp.add_argument("--locale", required=True)
    imp.add_argument("docx", type=Path)

    args = parser.parse_args(argv)

    if args.command == "export":
        rows = arb.rows(args.module, args.locale)
        out = args.out or (OUT_DIR / ("studyu-%s-%s.docx" % (args.module, args.locale)))
        out.parent.mkdir(parents=True, exist_ok=True)
        document.write(out, args.module, args.locale, rows)
        print("Wrote %s (%d rows)" % (out, len(rows)))
        return 0

    report = import_docx(args.docx, expected_module=args.module, expected_locale=args.locale)
    print(report.render())
    return 1 if report.skipped else 0


if __name__ == "__main__":
    sys.exit(main())
