#!/usr/bin/env python3
"""Download the german-nouns dataset into backend/nouns.csv."""

from __future__ import annotations

import sys
import urllib.request
from pathlib import Path

DATASET_URL = (
    "https://raw.githubusercontent.com/gambolputty/german-nouns/master/"
    "german_nouns/nouns.csv"
)
OUTPUT_PATH = Path(__file__).resolve().parent.parent / "nouns.csv"


def main() -> int:
    print(f"Downloading german-nouns dataset to {OUTPUT_PATH} ...")
    try:
        urllib.request.urlretrieve(DATASET_URL, OUTPUT_PATH)
    except Exception as exc:
        print(f"ERROR: download failed: {exc}")
        print("Manual fallback:")
        print("  git clone https://github.com/gambolputty/german-nouns")
        print("  cp german-nouns/german_nouns/nouns.csv backend/nouns.csv")
        return 1

    size_mb = OUTPUT_PATH.stat().st_size / (1024 * 1024)
    print(f"Done — {size_mb:.1f} MB saved to {OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
