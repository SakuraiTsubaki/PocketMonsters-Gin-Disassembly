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

ROM binaries are intentionally excluded. Source code, reconstructed data, scripts, documentation, extracted/reconstructed assets, build tooling, manifests, symbols, patches, logs, and verification metadata belong in this repository.

## Current status — Bank 00 first

Bank 00 (`0x0000-0x3FFF`) is being completed in full before Bank 01 work begins.

- All eight source images pass header and global checksum verification.
- JP Rev 0 / Rev A are 1 MiB (64 ROM banks); KR and the English/German/French/Italian/Spanish releases are 2 MiB (128 banks).
- The complete Bank 00 HOME layout is mapped into **53 contiguous source components**, from `header.asm` through `audio.asm`.
- Component start addresses are mapped for **all eight releases**.
- Of the 52 non-header HOME components, **31 are opcode-structure-identical across all eight releases** when relocation/immediate operands are ignored.
- Reconstructed source currently exists for **21 / 53 Bank 00 components**.
- JP Rev 0 and Rev A Bank 00 differences are confined to `header`, `sprite_anims`, and late `audio` data/code runs.
- Verified Korean semantic branches include RST timing helpers, LCD scanline guarding, boot/HRAM/BG-map initialization, serial timing, SRAM safeguards/state tracking, and far-called tilemap-copy helpers.
- Verified Japanese semantic branches include VBlank cutscene interrupt handling, one RTC carry instruction, and two joypad/automatic-input omissions.

Currently reconstructed under `home/`:

`header`, `vblank`, `delay`, `time_palettes`, `fade`, `lcd`, `time`, `init`, `serial`, `joypad`, `decompress`, `sram`, `call_regs`, `clear_sprites`, `copy`, `copy_tilemap`, `copy_name`, `array`, `math`, `queue_script`, and `compare`.

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

## Next milestone

Continue filling the remaining Bank 00 components, prioritizing opcode-identical shared source (`map_objects`, `sine`, `movement`, `printer`, `game_time`, `farcall`, `predef`, `window`, `flag`, `sprite_updates`, `region`, `item`, `random`, `pokedex_flags`, `scrolling_menu`, `stone_queue`, `trainers`, `pokemon`, `sprite_anims`) while separately reconstructing the regional branches in `palettes`, `gfx`, `text`, `video`, `menu`, `map`, `string`, `print_text`, `tilemap`, `names`, `print_bcd`, `battle`, and `audio`.

After all Bank 00 source is present, add the minimum constants/macros/symbol/build scaffold, assemble each release variant, and perform byte-for-byte Bank 00 verification before moving to Bank 01.
