import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import arb  # noqa: E402


def test_rows_follow_english_order_with_sections():
    rows = arb.rows("app", "ko", base=arb.FIXTURES)
    assert [r.key for r in rows] == [
        "loading",
        "greeting",
        "studies_count_total",
        "only_in_en",
        "brace_literal",
    ]
    # separator precedes every fixture key
    assert all(r.section == "General" for r in rows)


def test_missing_target_key_reports_none():
    rows = arb.rows("app", "ko", base=arb.FIXTURES)
    assert {r.key: r.current for r in rows}["only_in_en"] is None


def test_metadata_keys_never_become_rows():
    rows = arb.rows("app", "ko", base=arb.FIXTURES)
    assert not any(r.key.startswith("@") for r in rows)


def test_serialize_roundtrip_fixtures_is_byte_identical():
    for locale in ("en", "ko"):
        path = arb.arb_path("app", locale, base=arb.FIXTURES)
        assert arb.serialize(arb.load("app", locale, base=arb.FIXTURES)) == path.read_bytes()


def test_serialize_roundtrip_real_files_is_byte_identical():
    """The load-bearing guarantee: import with zero proposals must not touch
    any of the six real ARB files."""
    for module in arb.MODULES:
        for locale in ("en", "de", "ko"):
            path = arb.arb_path(module, locale)
            assert arb.serialize(arb.load(module, locale)) == path.read_bytes(), (
                "%s/%s would be reformatted" % (module, locale)
            )
