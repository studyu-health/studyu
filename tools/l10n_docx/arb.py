"""ARB read/write for the l10n docx round-trip tool.

No Word knowledge lives here: rows() returns plain records, document.py
consumes them.
"""
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional

REPO = Path(__file__).resolve().parents[2]
MODULES = {
    "app": REPO / "app" / "lib" / "l10n",
    "designer": REPO / "designer_v2" / "lib" / "localization",
}
FIXTURES = Path(__file__).resolve().parent / "tests" / "fixtures"


@dataclass
class Row:
    key: str
    english: str
    current: Optional[str]  # None = key missing in target file
    section: Optional[str]


def arb_path(module: str, locale: str, base: Optional[Path] = None) -> Path:
    directory = base if base is not None else MODULES[module]
    return directory / f"app_{locale}.arb"


def load(module: str, locale: str, base: Optional[Path] = None) -> Dict:
    return json.loads(arb_path(module, locale, base).read_text(encoding="utf-8"))


def serialize(data: Dict) -> bytes:
    return (json.dumps(data, indent=2, ensure_ascii=False) + "\n").encode("utf-8")


def save(module: str, locale: str, data: Dict, base: Optional[Path] = None) -> None:
    arb_path(module, locale, base).write_bytes(serialize(data))


def section_title(key: str) -> str:
    # "@__________________GENERAL__________________" -> "General"
    return key.strip("@_").replace("_", " ").title()


def rows(module: str, locale: str, base: Optional[Path] = None) -> List[Row]:
    """Rows ordered by the English file; content comes from the target."""
    en = load(module, "en", base)
    target = load(module, locale, base)
    out: List[Row] = []
    section: Optional[str] = None
    for key, value in en.items():
        if key.startswith("@_"):  # section separator (also covers @@locale)
            section = section_title(key)
            continue
        if key.startswith("@"):
            continue  # @key metadata belonging to a sibling key
        if not isinstance(value, str):
            continue
        out.append(Row(key=key, english=value, current=target.get(key), section=section))
    return out
