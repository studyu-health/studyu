"""ICU placeholder extraction and proposal validation. Pure functions."""
from typing import List, Optional


class InvalidBraces(ValueError):
    pass


def extract_placeholders(text: str) -> List[str]:
    """Top-level placeholder names, nesting-aware.

    "{total, plural, =1{1 study} other{{total} studies}}" -> ["total"]
    Raises InvalidBraces on unbalanced braces.
    """
    names: List[str] = []
    depth = 0
    start = -1
    for i, ch in enumerate(text):
        if ch == "{":
            if depth == 0:
                start = i + 1
            depth += 1
        elif ch == "}":
            if depth == 0:
                raise InvalidBraces("unmatched '}' at %d" % i)
            depth -= 1
            if depth == 0:
                inner = text[start:i]
                names.append(inner.split(",")[0].strip())
    if depth != 0:
        raise InvalidBraces("unclosed '{'")
    return names


def compare(source: str, proposal: str) -> Optional[str]:
    """Return None if the proposal preserves the source placeholders, else a
    human-readable reason to reject it."""
    try:
        want = extract_placeholders(source)
        got = extract_placeholders(proposal)
    except InvalidBraces as e:
        return "invalid braces: %s" % e
    if sorted(want) != sorted(got):
        return "placeholders %s != source %s" % (sorted(got), sorted(want))
    return None
