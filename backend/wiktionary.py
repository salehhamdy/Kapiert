"""Wiktionary fallback lookup for words missing from the dataset."""

from __future__ import annotations

import re

import httpx

from config import get_settings
from dataset import GENDER_TO_ARTICLE

WIKTIONARY_API = "https://en.wiktionary.org/api/rest_v1/page/definition"
_TAG_STRIP = re.compile(r"<[^>]+>")


def _extract_translation(data: dict) -> str | None:
    german_section = None
    for lang_section in data.get("de", data.get("en", [])):
        german_section = lang_section
        break

    if not german_section:
        return None

    for defn in german_section.get("definitions", []):
        defn_text = defn.get("definition", "")
        stripped = _TAG_STRIP.sub("", defn_text).strip()
        if stripped and len(stripped) < 200:
            return stripped

    return None


async def wiktionary_lookup(word: str) -> dict | None:
    """Attempt to find the word on Wiktionary and extract gender + translation."""
    settings = get_settings()
    headers = {"User-Agent": settings.wiktionary_user_agent}

    async with httpx.AsyncClient(
        timeout=settings.wiktionary_timeout_seconds,
        follow_redirects=True,
        headers=headers,
    ) as client:
        for variant in [word.capitalize(), word, word.lower()]:
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

                translation = None
                try:
                    def_resp = await client.get(
                        f"{WIKTIONARY_API}/{variant}",
                        headers={"Accept": "application/json", **headers},
                    )
                    if def_resp.status_code == 200:
                        translation = _extract_translation(def_resp.json())
                except Exception:
                    pass

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
