# Unicode 17.0.0 data provenance

This directory vendors the Unicode Character Database source files used to generate Yamintto's deterministic folder-name canonicalizer.

Normative publisher: Unicode Consortium  
Release: Unicode 17.0.0  
Official distribution: https://www.unicode.org/Public/17.0.0/ucd/  
License and terms: [Unicode License v3](https://www.unicode.org/terms_of_use.html), reproduced in [LICENSE.txt](LICENSE.txt).

The UCD files are publisher source copies, not runtime-derived approximations. `DerivedNormalizationProps.txt`, `UnicodeData.txt` and `NormalizationTest.txt` are byte-identical to the Unicode Consortium's `unicodetools` UCD 17.0.0 release data; the pinned mirror's verification notes and publisher repository commit are documented at:
https://github.com/UOR-Foundation/lexlean-mcp/tree/6abea22c506c7f454fa2380b520052e80ab0bcda/crates/nfc-tables/ucd

`PropList.txt` is the Unicode 17.0.0 publisher file mirrored in Swift's Unicode 17 generator inputs at commit `524c8a3ac087013701326296e6972df40da9f4a1`:
https://github.com/swiftlang/swift/blob/524c8a3ac087013701326296e6972df40da9f4a1/utils/gen-unicode-data/Data/17/PropList.txt
Its official header identifies `PropList-17.0.0.txt`; its SHA-256 is pinned below and checked by the generator.

| File | SHA-256 | Used for |
|---|---|---|
| DerivedNormalizationProps.txt | 71fd6a206a2c0cdd41feb6b7f656aa31091db45e9cedc926985d718397f9e488 | NFKC_CF mappings and Full_Composition_Exclusion |
| PropList.txt | 130dcddcaadaf071008bdfce1e7743e04fdfbc910886f017d9f9ac931d8c64dd | Unicode 17.0 White_Space property |
| UnicodeData.txt | 2e1efc1dcb59c575eedf5ccae60f95229f706ee6d031835247d843c11d96470c | Canonical decomposition and canonical combining classes |
| NormalizationTest.txt | 5019ffd530751a741900c849c0e010332f142a3612234639bd200b82138a87db | Official normalization conformance vectors |

Regenerate the checked-in Dart tables from the repository root:

```sh
python3 tool/unicode/generate_unicode_17_data.py
```

The generator uses only Python's standard library, validates all source SHA-256 digests and Unicode version headers, and emits deterministic Dart string tables. The runtime implementation does not call host ICU, platform normalization APIs, or SQLite NOCASE. The source fixture is retained so that generated data can be independently audited.

The NFKC_Casefold property is read from the official NFKC_CF field. Per Unicode's data-file instructions, strings are mapped code point by code point and normalized to NFC after mapping. NFC tables are generated from canonical (non-compatibility) decompositions, combining classes, and the official Full_Composition_Exclusion property. Hangul decomposition and composition are handled algorithmically.
