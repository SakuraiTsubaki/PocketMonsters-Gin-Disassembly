# PocketMonsters-Gin-Disassembly

Complete multi-region disassembly and source reconstruction project for **Pokémon Silver / Pocket Monsters Gin**.

The long-term goal is a fully source-based, reproducible build that can reconstruct each supported retail release from repository contents alone, without requiring a local base ROM.

## Project goals

- Reconstruct executable code as maintainable RGBDS assembly.
- Restore game data, maps, scripts, text, graphics, fonts, palettes, music, sound effects, and other ROM resources into editable source forms.
- Preserve region, language, and revision differences explicitly.
- Produce byte-identical builds for supported original releases where practical.
- Keep ROM binaries out of the repository.
- When graphics or sprite assets are reconstructed, commit editable/image outputs (for example PNG previews/sheets) alongside source metadata and extraction tooling; only ROM binaries remain excluded.

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
- **All 53 / 53 Bank 00 components now have local source in this repository.**
- The large map component is vendored as exact, provenance-tagged snapshots under `home/map_variants/`; `home/map.asm` selects the Western, Japanese, or Korean local source at build time. Building Bank 00 therefore no longer requires the reference submodules to be initialized.
- Bank 00 map binary verification is now reproducible with `tools/analyze_bank00_component_binary.py`. Exact slice hashes and all 28 pairwise comparisons are recorded under `analysis/` without committing ROM bytes.
- The JP Rev 0 and Rev A map components are confirmed **byte-identical**: both are 3801 bytes with SHA-1 `047969f4b6cdddb768918c139bf73e65c6e8ddc9`. No map-level Japanese revision split is needed.
- All Western map components are 3786 bytes; Korean is 3828 bytes. These boundary facts are now explicitly regression-tracked before source deduplication.
- `menu.asm` is reconstructed as shared logic with narrow Korean WRAM/far-call branches plus localized JP/KR/DE/FR/IT/ES data.
- `text.asm` is reconstructed with the Korean double-byte Hangul renderer, Japanese text-command/string rules, and Western language literal/weekday branches.
- The map comparison shows all Western releases have the same 3786-byte component length. Japanese adds 15 bytes primarily through three inline default event strings. The apparent Korean +42-byte boundary delta belongs to Korean far-call helpers and `DummyEndPredef` immediately before `FarCall_hl`, rather than opaque map logic.
- JP Rev 0 / Rev A late-Bank00 differences are separated correctly: core `audio.asm` code is shared, while JP Rev 0 alone carries a 177-byte trailing ROM0 garbage block and Rev A uses zero fill.
- Verified Korean semantic branches include RST/LCD timing, initialization, serial timing, SRAM state tracking, tilemap transfer, graphics request synchronization, double-byte string/name handling, palette bank preservation, video helpers, and menu/window WRAM handling.
- Verified Japanese semantic branches include VBlank handling, RTC carry behavior, joypad omissions, simplified graphics/video paths, Japanese name widths, localized number rendering, and inline default map-event strings.

## Map provenance

The locally vendored snapshots are generated from these exact public-source revisions:

- `home/map_variants/western.asm`: `pret/pokegold` @ `656583c939d30f920a316177311a502dd222b57c`
- `home/map_variants/japanese.asm`: `Narishma-gb/pokesilver` @ `edbe53978ef1777fc5c41019e17b7544070eab92`
- `home/map_variants/korean.asm`: `Narishma-gb/pokegold-kr` @ `f4496dda3003ccc5fc26f2757171a3b111e65307`

The reference gitlinks and vendoring tool remain for provenance/reproducibility; the actual Bank 00 map source is now present locally. See `docs/bank00_map_source_provenance.md`.

## Bank 00 analysis

- `docs/bank00_full_layout.md`
- `docs/bank00_initial_map.md`
- `docs/bank00_home_phase1.md`
- `docs/bank00_map_source_provenance.md`
- `docs/bank00_map_binary_verification.md`
- `analysis/bank00_us_component_ranges.csv`
- `analysis/bank00_component_starts_matrix.csv`
- `analysis/bank00_opcode_equivalence.csv`
- `analysis/jp_bank00_revision_diff_runs.csv`
- `analysis/home_source_status.csv`
- `analysis/bank00_pairwise_diffs.csv`
- `analysis/bank00_map_binary_summary.csv`
- `analysis/bank00_map_binary_pairwise.csv`
- `tools/map_bank00_components.py`
- `tools/analyze_home_prefix.py`
- `tools/analyze_roms.py`
- `tools/vendor_map_source.py`
- `tools/analyze_bank00_component_binary.py`

Additional source helpers include regional `print_num.asm`, shared `battle_vars.asm`, shared `hm_moves.asm`, and exact JP Rev 0 reconstruction data under `garbage/rev_0/bank00.asm`.

## Next Bank 00 milestone

The binary verification baseline for the map component is complete; the source-collapse and assembly gate remains:

1. Collapse the three locally vendored map snapshots to shared code plus narrow `_JAPANESE` / `_KOREAN` conditionals, using the new byte-level reports as regression evidence.
2. Add the minimum constants, macros, symbols, memory definitions, and build scaffold needed to assemble Bank 00.
3. Assemble all eight release variants.
4. Compare every generated Bank 00 byte-for-byte with its preserved original and resolve every mismatch.
5. Only after Bank 00 passes verification move to Bank 01.
