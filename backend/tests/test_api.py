"""API contract tests — verify responses match the Flutter WordModel contract."""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)

WORD_FIELDS = {"word", "article", "gender", "plural", "translation", "source", "found"}


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "Der Die Das API"
    assert "nouns_loaded" in data
    assert "endpoints" in data
    assert "GET /lookup/{word}" in data["endpoints"]


def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] in {"ok", "degraded"}


def test_lookup_not_found_without_dataset():
    response = client.get("/lookup/xyznotaword12345")
    assert response.status_code == 404
    assert "detail" in response.json()


def test_random_returns_503_without_dataset():
    response = client.get("/random")
    if response.status_code == 503:
        assert response.json()["detail"] == "Dataset not loaded"
    else:
        data = response.json()
        assert WORD_FIELDS.issubset(data.keys())


def test_random_batch_returns_503_or_list():
    response = client.get("/random/batch/5")
    if response.status_code == 503:
        assert response.json()["detail"] == "Dataset not loaded"
    else:
        data = response.json()
        assert isinstance(data, list)
        if data:
            assert WORD_FIELDS.issubset(data[0].keys())
