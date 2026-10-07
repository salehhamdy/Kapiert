"""Random noun endpoints used by the Quiz screen with balanced, varied distribution."""

from __future__ import annotations

import random

from fastapi import APIRouter, HTTPException

from dataset import dataset_ready, get_noun_dict, get_quiz_pools
from models import WordResponse
from sentences import get_example_sentence

router = APIRouter(tags=["random"])

_ARTICLES = ("der", "die", "das")


def _enrich(entry: dict) -> dict:
    res = dict(entry)
    sent = get_example_sentence(res["word"], res["article"])
    res["example_sentence"] = sent["de"]
    res["example_translation"] = sent["en"]
    res["example_translations"] = sent
    return res


def _anti_clump(entries: list[dict]) -> list[dict]:
    """Ensure no more than 2 consecutive items share the same article."""
    n = len(entries)
    if n <= 2:
        return entries

    res = list(entries)
    for i in range(2, n):
        if res[i]["article"] == res[i - 1]["article"] == res[i - 2]["article"]:
            # Find a later element with a different article to swap
            for j in range(i + 1, n):
                if res[j]["article"] != res[i]["article"]:
                    res[i], res[j] = res[j], res[i]
                    break
    return res


@router.get("/random", response_model=WordResponse)
async def random_word() -> WordResponse:
    """Return a random noun with balanced 1/3 probability across der, die, and das."""
    if not dataset_ready():
        raise HTTPException(status_code=503, detail="Dataset not loaded")

    quiz_pools = get_quiz_pools()
    # Try random article with equal probability
    shuffled_articles = list(_ARTICLES)
    random.shuffle(shuffled_articles)

    for art in shuffled_articles:
        pool = quiz_pools.get(art, [])
        if pool:
            return WordResponse(**_enrich(random.choice(pool)))

    # Fallback to entire noun dict if pools are empty
    noun_dict = get_noun_dict()
    entry = random.choice(list(noun_dict.values()))
    return WordResponse(**_enrich(entry))


@router.get("/random/batch/{count}", response_model=list[WordResponse])
async def random_words(count: int = 10) -> list[WordResponse]:
    """
    Return a batch of random nouns with equal distribution across der, die, and das,
    shuffled and checked to avoid consecutive same-gender clumping.
    """
    if not dataset_ready():
        raise HTTPException(status_code=503, detail="Dataset not loaded")

    batch_size = min(max(count, 1), 50)
    quiz_pools = get_quiz_pools()

    # Determine per-article quotas
    base_per_article = batch_size // len(_ARTICLES)
    remainder = batch_size % len(_ARTICLES)

    quotas: dict[str, int] = {art: base_per_article for art in _ARTICLES}
    # Randomly assign remainder
    extra_articles = random.sample(_ARTICLES, remainder)
    for art in extra_articles:
        quotas[art] += 1

    batch: list[dict] = []
    fallback_needed = 0

    for art in _ARTICLES:
        quota = quotas[art]
        pool = quiz_pools.get(art, [])
        if len(pool) >= quota and quota > 0:
            batch.extend(random.sample(pool, quota))
        elif pool:
            batch.extend(pool)
            fallback_needed += quota - len(pool)
        else:
            fallback_needed += quota

    if fallback_needed > 0:
        noun_dict = get_noun_dict()
        existing_words = {e["word"].lower() for e in batch}
        available = [e for e in noun_dict.values() if e["word"].lower() not in existing_words]
        if available:
            batch.extend(random.sample(available, min(fallback_needed, len(available))))

    random.shuffle(batch)
    batch = _anti_clump(batch)

    return [WordResponse(**_enrich(entry)) for entry in batch]
