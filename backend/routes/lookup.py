"""Word lookup endpoint."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException

from dataset import (
    lookup_compound_fallback,
    lookup_in_dataset,
    normalize_word,
)
from models import WordResponse
from wiktionary import wiktionary_lookup

router = APIRouter(tags=["lookup"])


@router.get("/lookup/{word}", response_model=WordResponse)
async def lookup_word(word: str) -> WordResponse:
    """
    Look up the article for a German noun.
    1. Normalize query (strip punctuation and leading articles like 'das', 'der', 'die').
    2. Check in-memory dataset first (instant).
    3. Fall back to Wiktionary REST API (for translations, rare words).
    4. Fall back to compound noun head matching.
    5. Return 404 if not found anywhere.
    """
    cleaned = normalize_word(word)
    if not cleaned:
        raise HTTPException(status_code=400, detail="Word cannot be empty.")

    # 1. Exact dataset match
    dataset_result = lookup_in_dataset(cleaned)
    if dataset_result:
        return WordResponse(**dataset_result)

    # 2. Wiktionary fallback
    wikt_result = await wiktionary_lookup(cleaned)
    if wikt_result:
        return WordResponse(**wikt_result)

    # 3. Compound noun fallback
    compound_result = lookup_compound_fallback(cleaned)
    if compound_result:
        return WordResponse(**compound_result)

    raise HTTPException(
        status_code=404,
        detail=f"'{word}' was not found in the dataset or Wiktionary.",
    )
