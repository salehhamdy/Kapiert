"""
Der Die Das — FastAPI Backend
Serves German noun articles from the german-nouns dataset (~100k words)
with automatic fallback to the Wiktionary REST API.
"""

import os
import re
from pathlib import Path

import httpx
import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

# ---------------------------------------------------------------------------
# App setup
# ---------------------------------------------------------------------------
app = FastAPI(
    title="Der Die Das API",
    description="German noun article lookup with Wiktionary fallback",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Dataset loading
# ---------------------------------------------------------------------------
GENDER_TO_ARTICLE = {"m": "der", "f": "die", "n": "das"}
GENDER_LABELS = {"m": "masculine", "f": "feminine", "n": "neuter"}

# In-memory dictionary: lowercase noun -> {word, article, gender, plural}
_noun_dict: dict[str, dict] = {}


def _load_dataset() -> None:
    """Load nouns.csv into an in-memory lookup dictionary."""
    # Allow override via environment variable (useful for cloud deployments)
    env_path = os.environ.get("NOUNS_CSV_PATH")
    if env_path:
        csv_path = Path(env_path)
    else:
        csv_path = Path(__file__).parent / "nouns.csv"
        if not csv_path.exists():
            # Also check one level up (workspace root)
            csv_path = Path(__file__).parent.parent / "nouns.csv"
    if not csv_path.exists():
        print("WARNING: nouns.csv not found — dataset lookup will be empty")
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

        # Skip rows without a valid gender
        if genus not in GENDER_TO_ARTICLE:
            # Some nouns have multiple genders like "m,f" — take the first
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

    print(f"Loaded {len(_noun_dict):,} nouns from dataset")


@app.on_event("startup")
async def startup() -> None:
    _load_dataset()


# ---------------------------------------------------------------------------
# Wiktionary fallback
# ---------------------------------------------------------------------------
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

async def _wiktionary_lookup(word: str) -> dict | None:
    """Attempt to find the word on Wiktionary and extract gender + translation."""
    headers = {"User-Agent": "DerDieDas_App/1.0 (https://github.com/example) httpx/0.28"}
    
    async with httpx.AsyncClient(timeout=5.0, follow_redirects=True, headers=headers) as client:
        # Try capitalised form first (German nouns are capitalised)
        for variant in [word.capitalize(), word, word.lower()]:
            try:
                # 1. Fetch wikitext for gender
                wiki_url = f"https://en.wiktionary.org/w/api.php?action=query&prop=revisions&titles={variant}&rvprop=content&rvslots=main&format=json"
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
                    match = re.search(r'==\s*German\s*==(.*?)((?:\n==[^=]+==)|$)', content, re.DOTALL)
                    german_text = match.group(1) if match else content
                    
                    noun_match = re.search(r'\{\{de-(?:proper )?noun\|([mfn])', german_text)
                    if noun_match:
                        gender = noun_match.group(1)

                # Fallback to de.wiktionary if English one failed
                if not gender:
                    de_url = f"https://de.wiktionary.org/w/api.php?action=query&prop=revisions&titles={variant}&rvprop=content&rvslots=main&format=json"
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
                            de_gender_match = re.search(r'\|Genus=([mfn])', de_content)
                            if de_gender_match:
                                gender = de_gender_match.group(1)
                            de_plural_match = re.search(r'\|Nominativ Plural=([^\|\n]+)', de_content)
                            if de_plural_match:
                                p = de_plural_match.group(1).strip()
                                if p and p not in ('—', '-'):
                                    plural = p

                if not gender:
                    continue
                
                # 2. Fetch definition for translation
                translation = None
                try:
                    def_resp = await client.get(
                        f"{WIKTIONARY_API}/{variant}",
                        headers={"Accept": "application/json", **headers},
                    )
                    if def_resp.status_code == 200:
                        def_data = def_resp.json()
                        translation = _extract_translation(def_data)
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
            except (httpx.HTTPError, Exception) as e:
                print(f"Wiktionary lookup error for {variant}: {e}")
                continue
                
    return None


# ---------------------------------------------------------------------------
# API endpoint
# ---------------------------------------------------------------------------
@app.get("/")
async def root():
    return {
        "service": "Der Die Das API",
        "version": "1.0.0",
        "nouns_loaded": len(_noun_dict),
        "usage": "GET /lookup/{word}",
    }


@app.get("/lookup/{word}")
async def lookup_word(word: str):
    """
    Look up the article for a German noun.
    1. Check in-memory dataset first (instant).
    2. Fall back to Wiktionary REST API.
    3. Return 404 if not found anywhere.
    """
    # Normalise the lookup key
    key = word.strip().lower()

    # 1️⃣ Dataset lookup
    if key in _noun_dict:
        return {**_noun_dict[key], "found": True}

    # 2️⃣ Wiktionary fallback
    wikt_result = await _wiktionary_lookup(word)
    if wikt_result:
        return {**wikt_result, "found": True}

    # 3️⃣ Not found
    raise HTTPException(
        status_code=404,
        detail=f"'{word}' was not found in the dataset or Wiktionary.",
    )


@app.get("/random")
async def random_word():
    """Return a random noun from the dataset (used by the Quiz screen)."""
    import random

    if not _noun_dict:
        raise HTTPException(status_code=503, detail="Dataset not loaded")

    entry = random.choice(list(_noun_dict.values()))
    return {**entry, "found": True}


@app.get("/random/batch/{count}")
async def random_words(count: int = 10):
    """Return a batch of random nouns (used by Quiz screen for pre-fetching)."""
    import random

    if not _noun_dict:
        raise HTTPException(status_code=503, detail="Dataset not loaded")

    count = min(count, 50)  # Cap at 50
    entries = random.sample(list(_noun_dict.values()), min(count, len(_noun_dict)))
    return [({**entry, "found": True}) for entry in entries]

if __name__ == "__main__":
    import uvicorn
    # Bind to 0.0.0.0 so that Android emulators and physical devices on the same network can connect
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

