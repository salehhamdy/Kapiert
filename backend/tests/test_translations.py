"""Tests for English translation enrichment engine and Wiktionary integration."""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from main import app
from translations import CURATED_TRANSLATIONS, get_curated_translation
from wiktionary import _clean_definition, get_english_translation


@pytest.fixture(scope="session")
def client():
    with TestClient(app) as test_client:
        yield test_client


def test_curated_translation_bank():
    """Verify core vocabulary translations exist and return clean English glosses."""
    assert get_curated_translation("buch") == "book"
    assert get_curated_translation("hund") == "dog"
    assert get_curated_translation("katze") == "cat"
    assert get_curated_translation("apfel") == "apple"
    assert get_curated_translation("kühlschrank") == "refrigerator, fridge"
    assert get_curated_translation("kuehlschrank") == "refrigerator, fridge"
    assert get_curated_translation("nonexistentnoun123") is None


def test_clean_definition_formatter():
    """Verify Wiktionary raw HTML and markup is stripped into concise text."""
    raw_html = '<a href="/wiki/apple">apple</a> (fruit)'
    assert _clean_definition(raw_html) == "apple (fruit)"

    raw_taxon = "house cat, Felis silvestris catus"
    cleaned = _clean_definition(raw_taxon)
    assert cleaned is not None
    assert "Felis silvestris" not in cleaned
    assert "cat" in cleaned

    raw_bullet = "1. a large table; 2. a desk"
    assert _clean_definition(raw_bullet) == "a large table, a desk"

    assert _clean_definition("") is None
    assert _clean_definition("   ") is None


@pytest.mark.anyio
async def test_get_english_translation_curated_and_variants():
    """Verify get_english_translation resolves from curated tier and transcription variants."""
    res1 = await get_english_translation("Buch")
    assert res1 == "book"

    res2 = await get_english_translation("strae".replace("", "ß") if False else "straße")
    assert res2 is not None
    assert "street" in res2

    # Transcription variant
    res3 = await get_english_translation("strasse")
    assert res3 is not None
    assert "street" in res3


def test_lookup_endpoint_returns_english_translation(client):
    """Verify GET /lookup/{word} returns English translation for dataset words."""
    # Test core words
    for german_word, expected_substr in [
        ("Buch", "book"),
        ("Katze", "cat"),
        ("Hund", "dog"),
        ("Tisch", "table"),
        ("Apfel", "apple"),
        ("Wasser", "water"),
    ]:
        resp = client.get(f"/lookup/{german_word}")
        assert resp.status_code == 200
        data = resp.json()
        assert data["translation"] is not None, f"Expected translation for {german_word}"
        assert expected_substr.lower() in data["translation"].lower(), (
            f"Expected '{expected_substr}' in '{data['translation']}' for {german_word}"
        )


def test_lookup_compound_word_returns_translation(client):
    """Verify compound noun fallback provides an English translation gloss."""
    resp = client.get("/lookup/Küchentisch")
    assert resp.status_code == 200
    data = resp.json()
    assert data["translation"] is not None
    assert "table" in data["translation"].lower() or "tisch" in data["translation"].lower()


def test_lookup_plural_resolves_lemma_translation(client):
    """Verify plural lookups resolve lemma translation."""
    resp = client.get("/lookup/Bücher")
    assert resp.status_code == 200
    data = resp.json()
    assert data["word"] == "Buch"
    assert data["translation"] is not None
    assert "book" in data["translation"].lower()


def test_random_quiz_batch_includes_translations(client):
    """Verify quiz batch endpoint returns items with English translations populated."""
    resp = client.get("/random/batch/10")
    assert resp.status_code == 200
    items = resp.json()
    assert len(items) == 10
    translated_count = sum(1 for item in items if item.get("translation"))
    # In a balanced quiz of 10 items, high proportion or all have verified English translations
    assert translated_count >= 8, f"Expected at least 8/10 items with translations, got {translated_count}"
