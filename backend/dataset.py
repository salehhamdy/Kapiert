"""In-memory german-nouns dataset loader."""

from __future__ import annotations

from pathlib import Path

import pandas as pd

from config import get_settings

GENDER_TO_ARTICLE = {"m": "der", "f": "die", "n": "das"}

_noun_dict: dict[str, dict] = {}


def get_noun_dict() -> dict[str, dict]:
    return _noun_dict


def nouns_loaded() -> int:
    return len(_noun_dict)


def dataset_ready() -> bool:
    return len(_noun_dict) > 0


def lookup_in_dataset(word: str) -> dict | None:
    return _noun_dict.get(word.strip().lower())


def load_dataset() -> None:
    """Load nouns.csv into an in-memory lookup dictionary."""
    global _noun_dict
    _noun_dict = {}

    settings = get_settings()
    candidates: list[Path] = []

    if settings.nouns_csv_path:
        candidates.append(Path(settings.nouns_csv_path))

    backend_dir = Path(__file__).parent
    candidates.extend(
        [
            backend_dir / "nouns.csv",
            backend_dir.parent / "nouns.csv",
        ]
    )

    csv_path = next((path for path in candidates if path.exists()), None)
    if csv_path is None:
        print("WARNING: nouns.csv not found — dataset lookup will be empty")
        print("         Run: python scripts/download_nouns.py")
        return

    df = pd.read_csv(
        csv_path,
        usecols=["lemma", "genus", "nominativ plural"],
        dtype=str,
        keep_default_na=False,
        encoding="utf-8",
    )

    for _, row in df.iterrows():
        lemma = row["lemma"].strip()
        genus = row["genus"].strip().lower()
        plural = row["nominativ plural"].strip() or None

        if genus not in GENDER_TO_ARTICLE:
            first_gender = genus.split(",")[0].strip() if "," in genus else None
            if first_gender and first_gender in GENDER_TO_ARTICLE:
                genus = first_gender
            else:
                continue

        article = GENDER_TO_ARTICLE[genus]
        _noun_dict[lemma.lower()] = {
            "word": lemma,
            "article": article,
            "gender": genus,
            "plural": plural,
            "translation": None,
            "source": "dataset",
        }

    print(f"Loaded {len(_noun_dict):,} nouns from {csv_path}")
