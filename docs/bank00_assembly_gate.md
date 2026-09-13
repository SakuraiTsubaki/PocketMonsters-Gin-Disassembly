# Bank 00 assembly gate

Bank 00 HOME now assembles as a standalone RGBDS object for all eight preserved Silver/Gin release configurations.

## Clean assembly baseline

GitHub Actions run `34760033830` assembled all eight targets successfully with RGBDS `v1.0.3` and produced zero RGBASM warnings.

The machine-readable target matrix is `analysis/bank00_assembly_matrix.csv`.

| release | result | RGBASM warnings |
| --- | --- | ---: |
| US-EU Rev 0 | clean | 0 |
| JP Rev 0 | clean | 0 |
| JP Rev A | clean | 0 |
| KR Rev 0 | clean | 0 |
| DE Rev 0 | clean | 0 |
| FR Rev 0 | clean | 0 |
| IT Rev 0 | clean | 0 |
| ES Rev 0 | clean | 0 |

The root `Makefile` now passes `-Werror`, so future RGBASM warnings fail the Bank 00 assembly gate instead of being accepted silently.

## Warning fixes that established the clean baseline

Two Japanese literals had been generalized incorrectly while merging region sources. Japanese retail uses the full-width blank character `　` in `BlankBGMap` and `_InitString`; the shared sources now select that literal only for `_JAPANESE` and retain the Western blank for other non-Korean releases.

The Italian and Spanish weekday strings also require localized glyph mappings absent from the baseline `pret/pokegold` charmap. The values were verified directly from the preserved Silver ROM bytes and are applied by `config/bank00/preinclude.asm`:

- Italian `Ì` = `$C8`
- Spanish `É` = `$C7`
- Spanish `Á` = `$BF`

Exact ROM offsets/evidence are recorded in `analysis/bank00_regional_charmap_overrides.csv`.

## What this gate proves

A clean object build proves that all 53 Bank 00 source components parse and assemble together under each region/revision feature set, with all compile-time constants, macros, charmaps, and symbols needed by RGBASM present.

It does **not** by itself prove final linked addresses or byte identity. External references may remain relocatable inside the object until RGBLINK places Bank 00 with the rest of the game.

## Next gate: full reference linking

`.github/workflows/bank00-reference-link.yml` overlays this repository's reconstructed `home.asm`, `home/`, and Bank 00 revision garbage into the pinned full public disassemblies for USA/Europe, Japanese Rev 0/Rev A, and Korean Silver. It then links complete ROM images inside the ephemeral CI workspace and checks their SHA-1 values against the reference projects' known retail hashes.

No generated ROM binary is committed or uploaded as an artifact; only verification status and hashes are emitted to the CI log.

After the reference-link gate passes, the remaining independent-link work is to reproduce the German, French, Italian, and Spanish Bank 00 address environments and compare their generated Bank 00 bytes with the preserved originals.
