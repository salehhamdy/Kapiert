"""API contract tests — verify responses match the Flutter WordModel contract."""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from dataset import normalize_word
from main import app

WORD_FIELDS = {"word", "article", "gender", "plural", "translation", "source", "found"}


@pytest.fixture(scope="session")
def client():
    with TestClient(app) as test_client:
        yield test_client


def test_normalize_word():
    assert normalize_word("Buch") == "Buch"
    assert normalize_word("das Buch") == "Buch"
    assert normalize_word("der Hund") == "Hund"
    assert normalize_word("die Katze!") == "Katze"
    assert normalize_word(" ein Auto... ") == "Auto"
    assert normalize_word("  einen Apfel  ") == "Apfel"


def test_health_endpoint(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "Der Die Das API"
    assert "nouns_loaded" in data
    assert "endpoints" in data
    assert "GET /lookup/{word}" in data["endpoints"]


def test_root_endpoint(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] in {"ok", "degraded"}


def test_lookup_known_word(client):
    response = client.get("/lookup/Buch")
    assert response.status_code == 200
    data = response.json()
    assert data["word"].lower() == "buch"
    assert data["article"] == "das"
    assert data["gender"] == "n"
    assert data["source"] == "dataset"
    assert data["found"] is True
    assert data["example_sentence"] is not None
    assert "Buch" in data["example_sentence"]
    assert data["example_translations"]["en"] is not None
    assert data["example_translations"]["ar"] is not None
    assert data["example_translations"]["tr"] is not None


def test_example_sentence_multilingual(client):
    response = client.get("/lookup/Katze")
    assert response.status_code == 200
    data = response.json()
    assert data["article"] == "die"
    assert "Katze" in data["example_sentence"]
    assert "cat" in data["example_translation"].lower()
    assert "ar" in data["example_translations"]
    assert "tr" in data["example_translations"]


def test_lookup_with_article_prefix(client):
    response = client.get("/lookup/das%20Buch")
    assert response.status_code == 200
    data = response.json()
    assert data["article"] == "das"
    assert data["gender"] == "n"
    assert data["source"] == "dataset"


def test_lookup_compound_noun_fallback(client):
    # A compound noun ending in a known head noun like "Buch"
    response = client.get("/lookup/Notizbuch")
    assert response.status_code == 200
    data = response.json()
    assert data["article"] == "das"
    assert data["gender"] == "n"


def test_lookup_plural_form(client):
    # Looking up plural "Bücher" should resolve to "das Buch"
    response = client.get("/lookup/Bücher")
    assert response.status_code == 200
    data = response.json()
    assert data["word"] == "Buch"
    assert data["article"] == "das"
    assert data["gender"] == "n"
    assert data["plural"] == "Bücher"


def test_lookup_transcription_variant(client):
    # Foreign keyboards typing 'Strasse' or 'Maedchen'
    resp_strasse = client.get("/lookup/Strasse")
    assert resp_strasse.status_code == 200
    assert resp_strasse.json()["article"] == "die"

    resp_maedchen = client.get("/lookup/Maedchen")
    assert resp_maedchen.status_code == 200
    assert resp_maedchen.json()["article"] == "das"


def test_lookup_not_found(client):
    response = client.get("/lookup/xyznotaword12345")
    assert response.status_code == 404
    assert "detail" in response.json()


def test_random_returns_word(client):
    response = client.get("/random")
    assert response.status_code == 200
    data = response.json()
    assert WORD_FIELDS.issubset(data.keys())
    assert data["article"] in {"der", "die", "das"}


def test_random_batch_bounds(client):
    response = client.get("/random/batch/5")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 5
    assert WORD_FIELDS.issubset(data[0].keys())

    # Capped at max 50
    response_large = client.get("/random/batch/100")
    assert response_large.status_code == 200
    assert len(response_large.json()) <= 50


def test_random_batch_balanced_and_anti_clump(client):
    response = client.get("/random/batch/15")
    assert response.status_code == 200
    items = response.json()
    assert len(items) == 15

    articles = [item["article"] for item in items]
    der_count = articles.count("der")
    die_count = articles.count("die")
    das_count = articles.count("das")

    # In a batch of 15, each should have exactly 5
    assert der_count == 5
    assert die_count == 5
    assert das_count == 5

    # Check words are clean (no affixes starting with '-')
    for item in items:
        assert not item["word"].startswith("-")
        assert len(item["word"]) >= 3

    # Check anti-clumping: no 3 consecutive items have the same article
    for i in range(2, len(articles)):
        assert not (articles[i] == articles[i - 1] == articles[i - 2]), (
            f"Clumping detected at index {i}: {articles[i-2:i+1]}"
        )
