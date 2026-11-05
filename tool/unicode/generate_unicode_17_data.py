#!/usr/bin/env python3
"""Generate pinned Unicode 17.0 canonicalization tables for Yamintto.

Run from the repository root:
  python3 tool/unicode/generate_unicode_17_data.py
Uses only the Python standard library. The output is deterministic.
"""
from __future__ import annotations

import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
UCD = ROOT / "tool/unicode/17.0.0"
OUTPUT = ROOT / "lib/core/unicode/unicode_17_data.dart"
EXPECTED = {
    "DerivedNormalizationProps.txt": "71fd6a206a2c0cdd41feb6b7f656aa31091db45e9cedc926985d718397f9e488",
    "PropList.txt": "130dcddcaadaf071008bdfce1e7743e04fdfbc910886f017d9f9ac931d8c64dd",
    "NormalizationTest.txt": "5019ffd530751a741900c849c0e010332f142a3612234639bd200b82138a87db",
    "UnicodeData.txt": "2e1efc1dcb59c575eedf5ccae60f95229f706ee6d031835247d843c11d96470c",
}


def verify_sources() -> dict[str, str]:
    contents: dict[str, str] = {}
    for name, expected in EXPECTED.items():
        raw = (UCD / name).read_bytes()
        actual = hashlib.sha256(raw).hexdigest()
        if actual != expected:
            raise SystemExit(f"{name}: SHA-256 mismatch: {actual}")
        contents[name] = raw.decode("utf-8")
    headers = {
        "DerivedNormalizationProps.txt": "# DerivedNormalizationProps-17.0.0.txt",
        "PropList.txt": "# PropList-17.0.0.txt",
        "NormalizationTest.txt": "# NormalizationTest-17.0.0.txt",
    }
    for name, header in headers.items():
        if not contents[name].startswith(header):
            raise SystemExit(f"{name} is not Unicode 17.0.0")
    return contents


def codepoint_range(value: str) -> tuple[int, int]:
    parts = value.strip().split("..")
    return int(parts[0], 16), int(parts[-1], 16)


def compact_map(rows: dict[int, list[int]]) -> str:
    return "\n".join(
        f"{cp:04X}={','.join(f'{item:04X}' for item in values)}"
        for cp, values in sorted(rows.items())
    )


def dart_raw(name: str, value: str) -> str:
    return f"const String {name} = r'''\n{value}\n''';\n"


def main() -> None:
    sources = verify_sources()
    nfkc: dict[int, list[int]] = {}
    exclusions: set[int] = set()
    for line in sources["DerivedNormalizationProps.txt"].splitlines():
        fields = line.split("#", 1)[0].strip().split(";")
        if len(fields) < 2:
            continue
        prop = fields[1].strip()
        if prop == "NFKC_CF":
            start, end = codepoint_range(fields[0])
            mapping = (
                [int(value, 16) for value in fields[2].split()]
                if len(fields) > 2
                else []
            )
            for cp in range(start, end + 1):
                nfkc[cp] = mapping
        elif prop == "Full_Composition_Exclusion":
            start, end = codepoint_range(fields[0])
            exclusions.update(range(start, end + 1))

    decompositions: dict[int, list[int]] = {}
    combining: dict[int, int] = {}
    for line in sources["UnicodeData.txt"].splitlines():
        fields = line.split(";")
        cp = int(fields[0], 16)
        ccc = int(fields[3])
        if ccc:
            combining[cp] = ccc
        decomposition = fields[5].strip()
        if decomposition and not decomposition.startswith("<"):
            decompositions[cp] = [
                int(value, 16) for value in decomposition.split()
            ]

    compositions: dict[tuple[int, int], int] = {}
    for cp, sequence in decompositions.items():
        if (
            len(sequence) == 2
            and cp not in exclusions
            and combining.get(sequence[0], 0) == 0
        ):
            compositions[(sequence[0], sequence[1])] = cp

    whitespace: list[tuple[int, int]] = []
    for line in sources["PropList.txt"].splitlines():
        fields = line.split("#", 1)[0].strip().split(";")
        if len(fields) >= 2 and fields[1].strip() == "White_Space":
            whitespace.append(codepoint_range(fields[0]))

    ccc_text = "\n".join(
        f"{cp:04X}={value}" for cp, value in sorted(combining.items())
    )
    compose_text = "\n".join(
        f"{first:04X},{second:04X}={result:04X}"
        for (first, second), result in sorted(compositions.items())
    )
    whitespace_text = ",".join(
        f"{start:04X}-{end:04X}" for start, end in sorted(whitespace)
    )

    output = (
        "// GENERATED FILE — DO NOT EDIT.\n"
        "// Source: Unicode Character Database 17.0.0; see tool/unicode/17.0.0/README.md.\n"
        "const String unicodeDataVersion = '17.0.0';\n"
        + dart_raw("nfkcCasefoldMappings", compact_map(nfkc))
        + dart_raw(
            "canonicalDecompositionMappings", compact_map(decompositions)
        )
        + dart_raw("canonicalCombiningClasses", ccc_text)
        + dart_raw("canonicalCompositionMappings", compose_text)
        + dart_raw("unicodeWhiteSpaceRanges", whitespace_text)
    )
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(output, encoding="utf-8", newline="\n")
    print(f"Generated {OUTPUT.relative_to(ROOT)}")
    print(f"NFKC_CF entries: {len(nfkc)}")
    print(f"Canonical decompositions: {len(decompositions)}")
    print(f"Combining classes: {len(combining)}")
    print(f"Composition pairs: {len(compositions)}")
    print(f"White_Space ranges: {len(whitespace)}")


if __name__ == "__main__":
    main()
