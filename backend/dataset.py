"""In-memory german-nouns dataset loader."""

from __future__ import annotations

from pathlib import Path

import pandas as pd

from config import get_settings
from translations import get_curated_translation

GENDER_TO_ARTICLE = {"m": "der", "f": "die", "n": "das"}

_noun_dict: dict[str, dict] = {}
_plural_dict: dict[str, str] = {}
_quiz_pools: dict[str, list[dict]] = {"der": [], "die": [], "das": []}


def get_noun_dict() -> dict[str, dict]:
    return _noun_dict


def get_quiz_pools() -> dict[str, list[dict]]:
    return _quiz_pools


def nouns_loaded() -> int:
    return len(_noun_dict)


def plurals_loaded() -> int:
    return len(_plural_dict)


def dataset_ready() -> bool:
    return len(_noun_dict) > 0


_ARTICLE_PREFIXES = (
    "der ",
    "die ",
    "das ",
    "ein ",
    "eine ",
    "einen ",
    "einem ",
    "einer ",
    "eines ",
    "den ",
    "dem ",
    "des ",
)


def normalize_word(word: str) -> str:
    """Normalize input query by stripping whitespace, punctuation, and leading articles."""
    cleaned = word.strip().strip(".,!?:;\"'()[]{}«»„“”")
    lower = cleaned.lower()
    for prefix in _ARTICLE_PREFIXES:
        if lower.startswith(prefix):
            cleaned = cleaned[len(prefix):].strip()
            break
    return cleaned.strip(".,!?:;\"'()[]{}«»„“”")


def generate_transcription_variants(word: str) -> list[str]:
    """Generate umlaut and eszett candidate spellings for foreign keyboards."""
    variants: list[str] = []
    has_umlaut = any(d in word for d in ("ae", "oe", "ue"))
    has_ss = "ss" in word

    if has_umlaut:
        # 1. Umlauts only (preserves double s, e.g. schluessel -> schlüssel)
        v1 = word.replace("ae", "ä").replace("oe", "ö").replace("ue", "ü")
        variants.append(v1)
        if has_ss:
            # 2. Both umlauts and ss -> ß
            variants.append(v1.replace("ss", "ß"))

    if has_ss:
        # 3. ss -> ß only (e.g. strasse -> straße, fuss -> fuß)
        variants.append(word.replace("ss", "ß"))

    return variants


def lookup_in_dataset(word: str) -> dict | None:
    """
    Look up a word in the in-memory dataset:
    1. Exact lemma match (e.g. 'Buch' -> das Buch)
    2. Transcription variant lemma match (e.g. 'Strasse' -> die Straße, 'Maedchen' -> das Mädchen)
    3. Plural form match (e.g. 'Bücher' -> das Buch)
    4. Plural form match with transcription (e.g. 'Buecher' -> das Buch)
    """
    cleaned = normalize_word(word)
    if not cleaned:
        return None

    cleaned_lower = cleaned.lower()

    # 1. Exact match by lemma
    entry = _noun_dict.get(cleaned_lower)
    if entry:
        return entry

    # 2. Transcription variants as lemma (e.g. Swiss keyboard 'Strasse' -> die Straße)
    t_variants = generate_transcription_variants(cleaned_lower)
    for variant in t_variants:
        entry = _noun_dict.get(variant)
        if entry:
            return entry

    # 3. Match by plural form (e.g. 'Bücher' -> das Buch)
    lemma_key = _plural_dict.get(cleaned_lower)
    if lemma_key and lemma_key in _noun_dict:
        return _noun_dict[lemma_key]

    # 4. Match transcription variants by plural form (e.g. 'Buecher' -> das Buch)
    for variant in t_variants:
        lemma_key = _plural_dict.get(variant)
        if lemma_key and lemma_key in _noun_dict:
            return _noun_dict[lemma_key]

    return None


def lookup_compound_fallback(word: str) -> dict | None:
    """
    Find article by compound noun head (last noun element).
    In German, the gender and article of a compound noun is always
    determined by its final noun (Grundwort).
    """
    cleaned = normalize_word(word)
    cleaned_lower = cleaned.lower()
    if len(cleaned_lower) < 6:
        return None

    candidates = [cleaned_lower] + generate_transcription_variants(cleaned_lower)

    for cand in candidates:
        for i in range(2, len(cand) - 2):
            suffix = cand[i:]
            if len(suffix) >= 3 and suffix in _noun_dict:
                base = _noun_dict[suffix]
                base_tr = base.get("translation") or get_curated_translation(suffix)
                tr = f"compound of {base['word']} ({base_tr})" if base_tr else None
                return {
                    "word": cleaned.capitalize(),
                    "article": base["article"],
                    "gender": base["gender"],
                    "plural": None,
                    "translation": tr,
                    "source": "dataset",
                }
    return None


def load_dataset() -> None:
    """Load nouns.csv into an in-memory lookup dictionary and plural index."""
    global _noun_dict, _plural_dict, _quiz_pools
    _noun_dict = {}
    _plural_dict = {}
    _quiz_pools = {"der": [], "die": [], "das": []}

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
        lemma_lower = lemma.lower()
        translation = get_curated_translation(lemma_lower)
        entry = {
            "word": lemma,
            "article": article,
            "gender": genus,
            "plural": plural,
            "translation": translation,
            "source": "dataset",
        }
        _noun_dict[lemma_lower] = entry

        # Valid quiz word: standard German noun (not affix or suffix, >= 3 chars, starts with capital)
        if not lemma.startswith("-") and len(lemma) >= 3 and lemma[0].isupper() and lemma.isalpha():
            _quiz_pools[article].append(entry)

        # Index plural forms for reverse lookup
        if plural and plural not in ("-", "—", "kein Plural", "k. Pl."):
            for part in plural.split(","):
                p_clean = part.strip().lower()
                # Don't shadow an existing singular lemma
                if p_clean and p_clean not in _noun_dict and p_clean not in _plural_dict:
                    _plural_dict[p_clean] = lemma_lower

    print(
        f"Loaded {len(_noun_dict):,} nouns (quiz pools: {len(_quiz_pools['der']):,} der, "
        f"{len(_quiz_pools['die']):,} die, {len(_quiz_pools['das']):,} das) "
        f"and {len(_plural_dict):,} plural forms from {csv_path}"
    )
