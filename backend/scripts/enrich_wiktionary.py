"""
Batch Wiktionary enrichment utility for German nouns.
Enriches in-memory dataset and persistent translations cache with clean English definitions.

Usage:
  python enrich_wiktionary.py --stats
  python enrich_wiktionary.py --words Apfel,Katze,Kühlschrank
  python enrich_wiktionary.py --enrich-top 50
"""

from __future__ import annotations

import argparse
import asyncio
from pathlib import Path
import sys

# Add backend directory to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent))

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

from dataset import get_quiz_pools, load_dataset
from translations import CURATED_TRANSLATIONS, get_curated_translation
from wiktionary import (
    get_cached_translations,
    get_english_translation,
)


async def show_stats() -> None:
    load_dataset()
    cached = get_cached_translations()
    curated_count = len(CURATED_TRANSLATIONS)
    cached_count = len(cached)

    pools = get_quiz_pools()
    total_quiz = sum(len(pool) for pool in pools.values())
    quiz_translated = sum(
        1
        for pool in pools.values()
        for item in pool
        if get_curated_translation(item["word"].lower()) or item["word"].lower() in cached
    )

    print("========================================")
    print("🌍 Kapiert Translation Coverage Stats")
    print("========================================")
    print(f"Curated In-Memory Translations : {curated_count:,}")
    print(f"Persistent Cached Translations : {cached_count:,}")
    print(f"Total Unique Translations Bank : {len(set(CURATED_TRANSLATIONS.keys()) | set(cached.keys())):,}")
    print(f"Active Quiz Pools Nouns        : {total_quiz:,}")
    print(f"Quiz Nouns with Translation    : {quiz_translated:,} ({quiz_translated / max(total_quiz, 1) * 100:.1f}%)")
    print("========================================")


async def enrich_words(words: list[str]) -> None:
    print(f"Enriching {len(words)} words via Wiktionary API...")
    for w in words:
        clean = w.strip()
        if not clean:
            continue
        trans = await get_english_translation(clean)
        print(f" - {clean:<20} -> {trans or '[not found]'}")
        await asyncio.sleep(0.1)
    print("Done!")


async def enrich_top_quiz_words(limit: int = 50) -> None:
    load_dataset()
    cached = get_cached_translations()
    pools = get_quiz_pools()

    missing: list[str] = []
    for art in ("der", "die", "das"):
        for item in pools.get(art, []):
            w = item["word"]
            w_lower = w.lower()
            if not get_curated_translation(w_lower) and w_lower not in cached:
                missing.append(w)
                if len(missing) >= limit:
                    break
        if len(missing) >= limit:
            break

    print(f"Found {len(missing)} quiz words without translations. Fetching from Wiktionary...")
    for i, w in enumerate(missing, 1):
        trans = await get_english_translation(w)
        print(f"[{i}/{len(missing)}] {w:<20} -> {trans or '[none]'}")
        await asyncio.sleep(0.15)
    print("Batch enrichment complete. Cache updated.")


def main():
    parser = argparse.ArgumentParser(description="Kapiert Wiktionary Translation Enrichment Tool")
    parser.add_argument("--stats", action="store_true", help="Display translation coverage statistics")
    parser.add_argument("--words", type=str, help="Comma-separated list of German nouns to enrich")
    parser.add_argument("--enrich-top", type=int, help="Fetch translations for the top N untranslated quiz nouns")

    args = parser.parse_args()

    if args.stats:
        asyncio.run(show_stats())
    elif args.words:
        word_list = [w.strip() for w in args.words.split(",") if w.strip()]
        asyncio.run(enrich_words(word_list))
    elif args.enrich_top:
        asyncio.run(enrich_top_quiz_words(args.enrich_top))
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
