---
name: kapiert-fastapi-backend
description: >-
  Covers the FastAPI Python 3.13 backend service, in-memory dictionary engine, Wiktionary fallback,
  balanced quiz batching, and Docker/pytest testing.
  Use when modifying backend routes, dataset normalizations (umlauts, ß, compounds), or API contracts.
---

# FastAPI Backend & Dataset Architecture

The Kapiert backend is a high-performance Python 3.13 service located in [`backend/`](file:///c:/Users/ASUS/Downloads/German_Articles/backend).

## Architecture & Data Flow

```text
HTTP Request (/lookup/{word} or /random/batch/{count})
  ├── 1. Query Normalization (lowercase, strip punctuation, strip leading articles)
  ├── 2. Exact Match in 90k In-Memory Dictionary (nouns.csv)
  ├── 3. Umlaut / Transliteration Expansion (ae -> ä, oe -> ö, ue -> ü, ss -> ß)
  ├── 4. Plural Reversal Lookup (Bücher -> das Buch)
  ├── 5. Compound Noun Head Matcher (Notizbuch -> Buch -> das)
  └── 6. Wiktionary REST Fallback (HTTP GET to de/en Wiktionary)
```

## Anti-Clumping & Balanced Quiz Generator

Located in [`backend/routes/random.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/routes/random.py).

When generating quiz batches:
- Equal distribution: Count is divided into 3 equal buckets (`der`, `die`, `das`).
- Anti-clumping constraint: No more than 2 consecutive nouns are allowed to share the same article.
- The algorithm verifies adjacency:
  ```python
  for i in range(2, len(batch)):
      if batch[i].article == batch[i-1].article == batch[i-2].article:
          # Swap with an item further down having a different article
          ...
  ```

## Running & Testing the Backend

### Local Python
```powershell
cd backend
python -m pytest tests/ -v
python main.py
# Server: http://127.0.0.1:8000
```

### Docker Compose
```powershell
docker compose up -d
# Healthcheck: http://127.0.0.1:8000/health
```
