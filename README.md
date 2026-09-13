# PocketMonsters-Gin-Disassembly

Complete multi-region disassembly and source reconstruction project for **Pokémon Silver / Pocket Monsters Gin**.

The long-term goal is a fully source-based, reproducible build that can reconstruct each supported retail release from repository contents alone, without requiring a local base ROM.

## Project goals

- Reconstruct executable code as maintainable RGBDS assembly.
- Restore game data, maps, scripts, text, graphics, fonts, palettes, music, sound effects, and other ROM resources into editable source forms.
- Preserve region, language, and revision differences explicitly.
- Produce byte-identical builds for supported original releases where practical.
- Keep ROM binaries out of the repository.

## Initial source set

Japanese, Korean, USA/Europe, German, French, Italian, and Spanish Silver releases, including the Japanese Rev A revision.

Exact checksums and release metadata are tracked under `config/versions/`.

## Build model

```text
repository sources/assets
        ↓
      RGBDS
        ↓
 rebuilt ROM image
        ↓
checksum verification against the preserved original
```

A completed build must not depend on `baserom.gb`, `baserom.gbc`, or any other local ROM image.

## Repository policy

ROM binaries are intentionally excluded. Source code, reconstructed data, scripts, documentation, extracted/reconstructed assets, build tooling, manifests, symbols, patches, logs, and verification metadata belong in this repository.

## Current status

The first structural survey of all eight source releases is complete.

- JP Rev 0 / Rev A are 1 MiB (64 ROM banks).
- KR and the five European-language/English 2 MiB releases are 2 MiB (128 ROM banks).
- All eight source images pass header and global checksum verification.
- Same-index banks `0C`, `2A`, `30`, `37`, `3B`, `3C`, and `3D` are byte-identical across all eight releases.
- JP Rev 0 and Rev A differ in 19,150 bytes across 16 banks.
- Bank 00 reset/RST/interrupt vectors and release-specific entry targets have been mapped.
- Korean Bank 00 has dedicated `WaitHBlank` / one-line delay RST helpers that are absent from the other seven releases.

See:

- `docs/initial_rom_survey.md`
- `docs/bank00_initial_map.md`
- `analysis/header_matrix.csv`
- `analysis/bank00_pairwise_diffs.csv`
- `analysis/shared_bank_groups.csv`
- `analysis/jp_revision_bank_diffs.csv`
- `tools/analyze_roms.py`

## Next milestone

Extend Bank 00 reconstruction from `0x0150` through the HOME routines, classify each difference as shared logic, relocation-only, localization-specific data, or genuinely release-specific code, then begin byte-identical RGBDS reconstruction.
