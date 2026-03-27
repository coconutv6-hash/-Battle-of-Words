#!/usr/bin/env python3
"""One-time repair for words.json: broken UTF-8 mojibake in Polish strings.

The source file stored Polish letters as pairs of Unicode characters (e.g. Ĺ+‚
instead of ł). This script rewrites JSON with correct Polish letters.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

# Order matters: apply these exact pair replacements first.
_REPLACEMENTS: list[tuple[str, str]] = [
    ("\u0139\u201a", "\u0142"),  # Ĺ + ‚ -> ł
    ("\u0139\u203a", "\u015b"),  # Ĺ + › -> ś
    ("\u0139\u201e", "\u0144"),  # Ĺ + „ -> ń
    ("\u0139\u013d", "\u017c"),  # Ĺ + Ľ -> ż
    ("\u0139\u015f", "\u017a"),  # Ĺ + ş -> ź
    ("\u0102\u0142", "\u00f3"),  # Ă + ł -> ó
    ("\u00c4\u2122", "\u0119"),  # Ä + ™ -> ę
    ("\u00c4\u2021", "\u0107"),  # Ä + ‡ -> ć
    ("\u00c4\u2026", "\u0105"),  # Ä + … -> ą
]


def fix_string(s: str) -> str:
    out = s
    for bad, good in _REPLACEMENTS:
        out = out.replace(bad, good)
    return out


def fix_file(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    data = json.loads(text)
    changed = False
    for item in data:
        if "pl" in item and isinstance(item["pl"], str):
            new_pl = fix_string(item["pl"])
            if new_pl != item["pl"]:
                item["pl"] = new_pl
                changed = True
    if not changed:
        print(f"{path}: nothing to change", file=sys.stderr)
        return
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"{path}: fixed")


def main() -> None:
    paths = [Path(p) for p in sys.argv[1:]]
    if not paths:
        root = Path(__file__).resolve().parents[1]
        paths = [
            root / "bow_client" / "assets" / "words.json",
            root / "assets" / "assets" / "words.json",
            root / "assets" / "assets" / "data" / "words.json",
        ]
    for p in paths:
        if p.exists():
            fix_file(p)
        else:
            print(f"skip missing: {p}", file=sys.stderr)


if __name__ == "__main__":
    main()
