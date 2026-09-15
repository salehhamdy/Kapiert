"""Word lookup endpoint."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException

from dataset import lookup_in_dataset
from models import WordResponse
from wiktionary import wiktionary_lookup

router = APIRouter(tags=["lookup"])


@router.get("/lookup/{word}", response_model=WordResponse)
async def lookup_word(word: str) -> WordResponse:
    """
    Look up the article for a German noun.
    1. Check in-memory dataset first (instant).
    2. Fall back to Wiktionary REST API.
    3. Return 404 if not found anywhere.
    """
    dataset_result = lookup_in_dataset(word)
    if dataset_result:
        return WordResponse(**dataset_result)

    wikt_result = await wiktionary_lookup(word)
    if wikt_result:
        return WordResponse(**wikt_result)

    raise HTTPException(
        status_code=404,
        detail=f"'{word}' was not found in the dataset or Wiktionary.",
    )
