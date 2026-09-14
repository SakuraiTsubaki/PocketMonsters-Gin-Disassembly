# Cartridge Identity Matrix — Pocket Monsters Gin / Pokémon Silver

Started: 2026-09-14

Purpose: track physical/product-code lineage separately from ROM checksum identity. Product-code equality/difference is not assumed to imply byte equality/difference without separate evidence.

Primary public hardware source in this pass: Game Boy Hardware Database (GBHWDB), cross-linked to No-Intro identities.

## Silver family product identities

| Origin/region | Public release identity | Product / ROM ID | Notes |
| --- | --- | --- | --- |
| Japan | Pocket Monsters Gin | `DMG-AAXJ-0` | Japanese origin retail Rev.0 |
| Japan | Pocket Monsters Gin Rev.1 | `DMG-AAXJ-1` | Japanese retail revision |
| Korea | Pocket Monsters Eun | `CGB-AAXK-0` | Korean release uses a CGB-prefixed product identity rather than the Japanese/localized DMG identities |
| USA/English | Pokemon Silver Version | `DMG-AAXE-0` | English market identity |
| Europe/Australia English | Pokemon Silver Version | `DMG-AAXP-0` | European/international English product identity |
| Germany | Pokemon Silberne Edition | `DMG-AAXD-0` | German localization |
| France | Pokemon Version Argent | `DMG-AAXF-0` | French localization |
| Italy | Pokemon Versione Argento | `DMG-AAXI-0` | Italian localization |
| Spain | Pokemon Edicion Plata | `DMG-AAXS-0` | Spanish localization |

## Observed board/hardware evidence

GBHWDB records Japanese `DMG-AAXJ-0` on a `DMG-KFDN-10` board with MBC3A in one public specimen. English `DMG-AAXE-0` specimens are recorded on `DMG-KGDU-10` with both MBC3A and MBC3B examples, while a German `DMG-AAXD-0` specimen is recorded on `DMG-KGDU-10` with MBC3B. These are specimen observations, not a complete production census.

Important separation:

- `ROM identity` = software/checksum/revision.
- `product identity` = region/language/catalogue code.
- `label/release suffix` = physical-market label such as USA/EUR/NOE.
- `board assembly` = PCB/mapper/RAM/supervisor/crystal components.

These layers must not be collapsed into one “version” field.

## Japanese-origin comparison rule

Every regional Silver identity above will ultimately be compared against Japanese `DMG-AAXJ-0` first, then Japanese `DMG-AAXJ-1` where chronology/code ancestry requires it. English is a comparison branch, not the origin.

## Evidence status

All rows are currently `PUBLIC_REFERENCE` from public hardware/catalogue evidence. The Japanese and regional ROM SHA-1 identities are tracked separately in `analysis/release_matrix.md`.

## Remaining hardware census

- Capture a dedicated GBHWDB/photographic entry for every regional product identity, not merely the variant index.
- Record label codes/stamps, PCB revisions, mapper manufacturer/revision, SRAM, supervisor/reset IC and 32.768 kHz crystal presence per observed cartridge.
- Distinguish multiple physical board populations that contain the same ROM identity.
- Investigate why Korean Silver is catalogued as `CGB-AAXK-0` and relate that physical identity to its 2 MiB ROM/data-layout differences.
- Investigate the separately catalogued German Silver beta identity without confusing it with the retail `DMG-AAXD-0` product.
- Cross-check product codes against boxes/manuals and official regional documentation.

Sources:
- https://gbhwdb.gekkio.fi/cartridges/DMG-AAXJ-0/
- https://gbhwdb.gekkio.fi/cartridges/DMG-AAXE-0/
- https://gbhwdb.gekkio.fi/cartridges/DMG-AAXD-0/
- https://gbhwdb.gekkio.fi/cartridges/gbc.html
