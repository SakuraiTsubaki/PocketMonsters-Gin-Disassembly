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

The initial eight-release structural survey is complete and Bank 00 source reconstruction has started.

- JP Rev 0 / Rev A are 1 MiB (64 ROM banks).
- KR and the English/German/French/Italian/Spanish releases are 2 MiB (128 ROM banks).
- All eight source images pass header and global checksum verification.
- Same-index banks `0C`, `2A`, `30`, `37`, `3B`, `3C`, and `3D` are byte-identical across all eight releases.
- JP Rev 0 and Rev A differ in 19,150 bytes across 16 banks, but are byte-identical through the mapped Bank 00 HOME prefix from `0150` to `0AD9`.
- Bank 00 reset/RST/interrupt vectors and release-specific entry targets are mapped.
- HOME component boundaries are mapped through `serial.asm` and `joypad.asm`, with `decompress.asm` start identified for every release family.
- Korean-specific semantic differences are confirmed in the RST timing helpers, LCD interrupt guard, initialization path, and serial timing.
- Actual reconstructed source now exists under `home/`: `header.asm`, `delay.asm`, and `lcd.asm`.

See:

- `docs/initial_rom_survey.md`
- `docs/bank00_initial_map.md`
- `docs/bank00_home_phase1.md`
- `analysis/header_matrix.csv`
- `analysis/bank00_pairwise_diffs.csv`
- `analysis/shared_bank_groups.csv`
- `analysis/jp_revision_bank_diffs.csv`
- `analysis/home_prefix_ranges.csv`
- `analysis/home_prefix_diff_vs_us.csv`
- `tools/analyze_roms.py`
- `tools/analyze_home_prefix.py`

## Next milestone

Continue source reconstruction through `time_palettes.asm`, `fade.asm`, `time.asm`, `init.asm`, `serial.asm`, `joypad.asm`, and `decompress.asm`; add the minimum constants/symbol/build scaffold required to assemble Bank 00; then begin byte-for-byte verification against each preserved release.
