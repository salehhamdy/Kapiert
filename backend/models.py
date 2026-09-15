"""Pydantic response models aligned with the Flutter WordModel JSON contract."""

from __future__ import annotations

from pydantic import BaseModel, Field


class WordResponse(BaseModel):
    """Single noun lookup result — matches flutter_app/lib/models/word_model.dart."""

    word: str
    article: str = Field(description='Article: "der", "die", or "das"')
    gender: str = Field(description='Gender code: "m", "f", or "n"')
    plural: str | None = None
    translation: str | None = None
    source: str = Field(description='Source: "dataset" or "wiktionary"')
    found: bool = True


class HealthResponse(BaseModel):
    service: str
    version: str
    status: str
    nouns_loaded: int
    dataset_ready: bool
    supabase_configured: bool
    endpoints: list[str]


class ErrorResponse(BaseModel):
    detail: str
