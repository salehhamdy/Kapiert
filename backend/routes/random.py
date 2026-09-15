"""Random noun endpoints used by the Quiz screen."""

from __future__ import annotations

import random

from fastapi import APIRouter, HTTPException

from dataset import dataset_ready, get_noun_dict
from models import WordResponse

router = APIRouter(tags=["random"])


@router.get("/random", response_model=WordResponse)
async def random_word() -> WordResponse:
    """Return a random noun from the dataset (used by the Quiz screen)."""
    noun_dict = get_noun_dict()
    if not dataset_ready():
        raise HTTPException(status_code=503, detail="Dataset not loaded")

    entry = random.choice(list(noun_dict.values()))
    return WordResponse(**entry)


@router.get("/random/batch/{count}", response_model=list[WordResponse])
async def random_words(count: int = 10) -> list[WordResponse]:
    """Return a batch of random nouns (used by Quiz screen for pre-fetching)."""
    noun_dict = get_noun_dict()
    if not dataset_ready():
        raise HTTPException(status_code=503, detail="Dataset not loaded")

    batch_size = min(max(count, 1), 50)
    entries = random.sample(list(noun_dict.values()), min(batch_size, len(noun_dict)))
    return [WordResponse(**entry) for entry in entries]
