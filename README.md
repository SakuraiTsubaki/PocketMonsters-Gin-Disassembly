# PocketMonsters-Gin-Disassembly

Complete multi-region disassembly and source reconstruction project for **Pokémon Silver / Pocket Monsters Gin**.

The long-term goal is a fully source-based, reproducible build that can reconstruct each supported retail release from repository contents alone, without requiring a local base ROM.

## Project goals

- Reconstruct executable code as maintainable RGBDS assembly.
- Restore game data, maps, scripts, text, graphics, fonts, palettes, music, sound effects, and other ROM resources into editable source forms.
- Preserve region, language, and revision differences explicitly.
- Produce byte-identical builds for supported original releases where practical.
- Keep ROM binaries out of the repository.
- When graphics or sprite assets are reconstructed, commit the editable/image outputs (for example PNG previews/sheets) alongside the source metadata and extraction tooling; only ROM binaries remain excluded.

## Initial source set

Japanese, Korean, USA/Europe, German, French, Italian, and Spanish Silver releases, including Japanese Rev A.

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

ROM binaries are intentionally excluded. Source code, reconstructed data, scripts, documentation, extracted/reconstructed assets, build tooling, manifests, symbols, patches, logs, verification metadata, and reconstructed graphics/images belong in this repository.

## Current status — Bank 00 first

Bank 00 (`0x0000-0x3FFF`) is being completed in full before Bank 01 work begins.

- All eight source images pass header and global checksum verification.
- JP Rev 0 / Rev A are 1 MiB (64 ROM banks); KR and the English/German/French/Italian/Spanish releases are 2 MiB (128 banks).
- The complete Bank 00 HOME layout is mapped into **53 contiguous source components**, from `header.asm` through `audio.asm`.
- Component start addresses are mapped for **all eight releases**.
- Of the 52 non-header HOME components, **31 are opcode-structure-identical across all eight releases** when relocation/immediate operands are ignored.
- Reconstructed source currently exists for **50 / 53 Bank 00 components**.
- Only `text.asm`, `menu.asm`, and `map.asm` remain to be reconstructed before the Bank 00 source-presence milestone is complete.
- JP Rev 0 / Rev A late-Bank00 differences are now separated correctly: core `audio.asm` code is shared, while JP Rev 0 alone carries a 177-byte trailing ROM0 garbage block and Rev A uses zero fill.
- Verified Korean semantic branches include RST/LCD timing, initialization, serial timing, SRAM state tracking, tilemap transfer, graphics request synchronization, double-byte string/name handling, palette bank preservation, and video helpers.
- Verified Japanese semantic branches include VBlank handling, RTC carry behavior, joypad omissions, simplified graphics/video paths, Japanese name widths, and localized number rendering.

## Bank 00 analysis

- `docs/bank00_full_layout.md`
- `docs/bank00_initial_map.md`
- `docs/bank00_home_phase1.md`
- `analysis/bank00_us_component_ranges.csv`
- `analysis/bank00_component_starts_matrix.csv`
- `analysis/bank00_opcode_equivalence.csv`
- `analysis/jp_bank00_revision_diff_runs.csv`
- `analysis/home_source_status.csv`
- `analysis/bank00_pairwise_diffs.csv`
- `tools/map_bank00_components.py`
- `tools/analyze_home_prefix.py`
- `tools/analyze_roms.py`

Additional source helpers now include regional `print_num.asm`, shared `battle_vars.asm`, shared `hm_moves.asm`, and exact JP Rev 0 reconstruction data under `garbage/rev_0/bank00.asm`.

## Remaining Bank 00 components

`text`, `menu`, and `map`.

These are the three largest localization-sensitive HOME components. They will be reconstructed by comparing the Western `pret/pokegold` source, Japanese `Narishma-gb/pokesilver` source, Korean `Narishma-gb/pokegold-kr` source, and the preserved DE/FR/IT/ES ROM bytes, keeping shared logic common and isolating only real regional differences.

After all Bank 00 source is present, add the minimum constants/macros/symbol/build scaffold, assemble each release variant, and perform byte-for-byte Bank 00 verification before moving to Bank 01.
