"""Wiktionary fallback lookup and English translation enrichment engine."""

from __future__ import annotations

import json
from pathlib import Path
import re

import httpx

from config import get_settings
from dataset import GENDER_TO_ARTICLE, generate_transcription_variants
from translations import get_curated_translation

WIKTIONARY_API = "https://en.wiktionary.org/api/rest_v1/page/definition"
_TAG_STRIP = re.compile(r"<[^>]+>")
_TAXON_STRIP = re.compile(r",?\s*(?:\()?[A-Z][a-z]+ [a-z]+(?: [a-z]+)?(?:\))?")
_SPACE_NORM = re.compile(r"\s+")

# Persistent on-disk translation cache
_CACHE_PATH = Path(__file__).parent / "translations_cache.json"
_translation_cache: dict[str, str] = {}


def _load_cache() -> None:
    global _translation_cache
    if _CACHE_PATH.exists():
        try:
            with open(_CACHE_PATH, "r", encoding="utf-8") as f:
                _translation_cache = json.load(f)
        except Exception as exc:
            print(f"Warning: could not load translations cache: {exc}")
            _translation_cache = {}


def _save_cache() -> None:
    try:
        with open(_CACHE_PATH, "w", encoding="utf-8") as f:
            json.dump(_translation_cache, f, ensure_ascii=False, indent=2)
    except Exception as exc:
        print(f"Warning: could not save translations cache: {exc}")


# Initialize cache at module load time
_load_cache()


def get_cached_translations() -> dict[str, str]:
    """Return in-memory dynamic translations cache."""
    return _translation_cache


def _clean_definition(raw_text: str) -> str | None:
    """Clean Wiktionary raw definition into concise, readable English gloss."""
    if not raw_text:
        return None

    # 1. Strip HTML tags
    text = _TAG_STRIP.sub("", raw_text)
    # 2. Strip Latin taxonomic names, e.g. (Felis silvestris catus)
    text = _TAXON_STRIP.sub("", text)
    # 3. Normalize whitespace and remove leading bullet markers or numbers
    text = _SPACE_NORM.sub(" ", text).strip()
    text = re.sub(r"^[0-9]+[.)]\s*", "", text)
    text = re.sub(r"^[-–—*•]\s*", "", text)

    if not text:
        return None

    # 4. If definition has multiple semicolon-separated senses or newline senses,
    # take the primary 1-2 senses
    first_chunk = text.split("\n")[0].strip()
    raw_senses = [s.strip() for s in first_chunk.split(";") if s.strip()]
    senses = []
    for s in raw_senses:
        s_clean = re.sub(r"^[0-9]+[.)]\s*", "", s).strip()
        s_clean = re.sub(r"^[-–—*•]\s*", "", s_clean).strip()
        if s_clean:
            senses.append(s_clean)

    if len(senses) > 1:
        # Check if first sense is very verbose with parentheses
        primary = senses[0]
        secondary = senses[1]
        # If secondary is short and clear, combine: "dog, hound"
        if len(primary) < 35 and len(secondary) < 35 and not secondary.startswith("specific uses"):
            text = f"{primary}, {secondary}"
        else:
            text = primary
    elif senses:
        text = senses[0]

    # 5. Clean trailing punctuation
    text = text.rstrip(".;:,")

    # 6. Simplify long parenthetical descriptors if text is excessively long
    if len(text) > 85 and "(" in text and ")" in text:
        simplified = re.sub(r"\s*\([^)]*\)", "", text).strip().rstrip(".;:,")
        if len(simplified) >= 3:
            text = simplified

    # Cap maximum length to avoid UI overflows
    if len(text) > 95:
        text = text[:92].rstrip() + "..."

    return text if len(text) >= 2 else None


def _extract_translation(data: dict) -> str | None:
    """Extract English translation from Wiktionary REST definitions payload."""
    german_section = None
    for lang_section in data.get("de", data.get("en", [])):
        german_section = lang_section
        break

    if not german_section:
        return None

    for defn in german_section.get("definitions", []):
        defn_text = defn.get("definition", "")
        cleaned = _clean_definition(defn_text)
        if cleaned:
            return cleaned

    return None


async def get_english_translation(word: str, client: httpx.AsyncClient | None = None) -> str | None:
    """
    Resolve English translation for any German noun with multi-tier fallback:
    1. Curated in-memory dictionary (<1ms)
    2. Dynamic persistent translation cache (<1ms)
    3. Live Wiktionary REST definition API
    4. Compound noun suffix decomposition
    """
    cleaned_lower = word.strip().lower()
    if not cleaned_lower:
        return None

    # Tier 1: Curated dictionary
    curated = get_curated_translation(cleaned_lower)
    if curated:
        return curated

    # Tier 2: Dynamic translation cache
    if cleaned_lower in _translation_cache:
        return _translation_cache[cleaned_lower]

    # Transcription variant check in curated or cache
    for tvar in generate_transcription_variants(cleaned_lower):
        if tvar in _translation_cache:
            return _translation_cache[tvar]
        tvar_curated = get_curated_translation(tvar)
        if tvar_curated:
            return tvar_curated

    # Tier 3: Live Wiktionary REST API lookup
    settings = get_settings()
    headers = {
        "User-Agent": settings.wiktionary_user_agent,
        "Accept": "application/json",
    }

    variants = [word.capitalize(), word, cleaned_lower]
    for tvar in generate_transcription_variants(cleaned_lower):
        if tvar not in variants:
            variants.extend([tvar.capitalize(), tvar])

    own_client = client is None
    http_client = (
        client
        if client is not None
        else httpx.AsyncClient(
            timeout=min(settings.wiktionary_timeout_seconds, 3.0),
            follow_redirects=True,
            headers=headers,
        )
    )

    try:
        for variant in variants:
            try:
                resp = await http_client.get(f"{WIKTIONARY_API}/{variant}")
                if resp.status_code == 200:
                    trans = _extract_translation(resp.json())
                    if trans:
                        _translation_cache[cleaned_lower] = trans
                        _save_cache()
                        return trans
            except Exception:
                continue
    finally:
        if own_client:
            await http_client.aclose()

    # Tier 4: Compound noun head decomposition (e.g. Küchentisch -> ends with Tisch -> table)
    if len(cleaned_lower) >= 6:
        for i in range(2, len(cleaned_lower) - 2):
            suffix = cleaned_lower[i:]
            if len(suffix) >= 3:
                head_trans = get_curated_translation(suffix) or _translation_cache.get(suffix)
                if head_trans:
                    compound_gloss = f"compound of {suffix.capitalize()} ({head_trans})"
                    _translation_cache[cleaned_lower] = compound_gloss
                    _save_cache()
                    return compound_gloss

    return None


async def wiktionary_lookup(word: str) -> dict | None:
    """Attempt to find a noun on Wiktionary and extract gender, article, plural, and translation."""
    settings = get_settings()
    headers = {"User-Agent": settings.wiktionary_user_agent}

    variants = [word.capitalize(), word, word.lower()]
    for tvar in generate_transcription_variants(word.lower()):
        if tvar not in variants:
            variants.extend([tvar.capitalize(), tvar])

    async with httpx.AsyncClient(
        timeout=settings.wiktionary_timeout_seconds,
        follow_redirects=True,
        headers=headers,
    ) as client:
        for variant in variants:
            try:
                wiki_url = (
                    "https://en.wiktionary.org/w/api.php"
                    f"?action=query&prop=revisions&titles={variant}"
                    "&rvprop=content&rvslots=main&format=json"
                )
                resp = await client.get(wiki_url)
                if resp.status_code != 200:
                    continue

                data = resp.json()
                pages = data.get("query", {}).get("pages", {})
                content = ""
                for page_id in pages:
                    if page_id == "-1":
                        continue
                    try:
                        content = pages[page_id]["revisions"][0]["slots"]["main"]["*"]
                    except KeyError:
                        pass

                gender = None
                plural = None
                if content:
                    match = re.search(
                        r"==\s*German\s*==(.*?)((?:\n==[^=]+==)|$)",
                        content,
                        re.DOTALL,
                    )
                    german_text = match.group(1) if match else content

                    noun_match = re.search(r"\{\{de-(?:proper )?noun\|([mfn])", german_text)
                    if noun_match:
                        gender = noun_match.group(1)

                if not gender:
                    de_url = (
                        "https://de.wiktionary.org/w/api.php"
                        f"?action=query&prop=revisions&titles={variant}"
                        "&rvprop=content&rvslots=main&format=json"
                    )
                    de_resp = await client.get(de_url)
                    if de_resp.status_code == 200:
                        de_data = de_resp.json()
                        de_pages = de_data.get("query", {}).get("pages", {})
                        de_content = ""
                        for pid in de_pages:
                            if pid != "-1":
                                try:
                                    de_content = de_pages[pid]["revisions"][0]["slots"]["main"]["*"]
                                except KeyError:
                                    pass
                        if de_content:
                            de_gender_match = re.search(r"\|Genus=([mfn])", de_content)
                            if de_gender_match:
                                gender = de_gender_match.group(1)
                            de_plural_match = re.search(
                                r"\|Nominativ Plural=([^\|\n]+)", de_content
                            )
                            if de_plural_match:
                                p = de_plural_match.group(1).strip()
                                if p and p not in ("—", "-"):
                                    plural = p

                if not gender:
                    continue

                # Fetch English translation
                translation = await get_english_translation(variant, client=client)

                article = GENDER_TO_ARTICLE[gender]
                return {
                    "word": word.capitalize(),
                    "article": article,
                    "gender": gender,
                    "plural": plural,
                    "translation": translation,
                    "source": "wiktionary",
                }
            except (httpx.HTTPError, Exception) as exc:
                print(f"Wiktionary lookup error for {variant}: {exc}")
                continue

    return None
