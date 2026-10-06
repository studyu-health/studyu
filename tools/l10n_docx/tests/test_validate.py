import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import validate  # noqa: E402
import arb  # noqa: E402

REAL_ARB_FILES = [
    arb.arb_path("app", "en"),
    arb.arb_path("designer", "en"),
]


def real_placeholder_strings():
    import json

    out = []
    for path in REAL_ARB_FILES:
        data = json.loads(path.read_text(encoding="utf-8"))
        for key, value in data.items():
            if isinstance(value, str) and "{" in value:
                out.append((key, value))
    return out


def test_simple_named_placeholder():
    assert validate.extract_placeholders("Error syncing: {error}") == ["error"]


def test_multiple_top_level_placeholders_not_merged():
    assert validate.extract_placeholders("{start}\u2013{end} of {count}") == [
        "start",
        "end",
        "count",
    ]


def test_plural_collapses_to_one_top_level_name():
    text = "{total, plural, =1{1 study} other{{total} studies}}"
    assert validate.extract_placeholders(text) == ["total"]


def test_three_branch_plural_with_repeated_inner_placeholder():
    text = (
        "{count,plural, =0{Nobody has enrolled in the study with this code yet} "
        "=1{{count} participant is enrolled in the study with this code} "
        "other{{count} participants are enrolled in the study with this code}}"
    )
    assert validate.extract_placeholders(text) == ["count"]


def test_plural_branch_containing_plain_braced_text():
    text = (
        "{count,plural, =2{You must define at least two interventions to compare.} "
        "other{form_array_interventions_minlength}}"
    )
    assert validate.extract_placeholders(text) == ["count"]


def test_unmatched_close_brace_rejected():
    import pytest

    with pytest.raises(validate.InvalidBraces):
        validate.extract_placeholders("oops }")


def test_unclosed_open_brace_rejected():
    import pytest

    with pytest.raises(validate.InvalidBraces):
        validate.extract_placeholders("oops {count")


def test_every_real_placeholder_string_parses_without_error():
    strings = real_placeholder_strings()
    assert len(strings) > 50  # sanity: fixture drift would shrink this a lot
    for key, text in strings:
        validate.extract_placeholders(text)  # must not raise


def test_compare_accepts_identical_placeholder_set():
    assert validate.compare("Hi {name}", "\uc548\ub155 {name}") is None


def test_compare_rejects_dropped_placeholder():
    assert validate.compare("Hi {name}", "\uc548\ub155") is not None


def test_compare_rejects_renamed_placeholder():
    assert validate.compare("Hi {name}", "\uc548\ub155 {names}") is not None


def test_compare_rejects_extra_placeholder():
    assert validate.compare("Hi", "\uc548\ub155 {name}") is not None


def test_compare_rejects_unbalanced_braces():
    result = validate.compare("Hi {name}", "\uc548\ub155 {name")
    assert result is not None and "brace" in result


def test_compare_allows_reordered_placeholders():
    source = "Compare {nameA} and {nameB}"
    proposal = "\ube44\uad50 {nameB} \uc640 {nameA}"
    assert validate.compare(source, proposal) is None
