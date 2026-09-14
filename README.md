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
- The large map component has exact, provenance-tagged snapshots under `home/map_variants/`. The map source itself is local; the reference submodules are not required to obtain its code.
- Korean/Western map logic is now deduplicated correctly: the shorter Korean snapshot is the common structural body. Western builds append the 17-byte `DummyEndPredef` tail; Korean omits it. Region-specific constants/macros are still selected by the build environment.
- Japanese map comparison is reduced to three retail inline event-text stubs plus a `_DEBUG`-only validation block. JP Rev 0 and Rev A have no map-level source split.
- Bank 00 map binary verification is reproducible with `tools/analyze_bank00_component_binary.py`. Exact slice hashes and all 28 pairwise comparisons are recorded under `analysis/` without committing ROM bytes.
- The JP Rev 0 and Rev A map components are confirmed **byte-identical**: both are 3801 bytes with SHA-1 `047969f4b6cdddb768918c139bf73e65c6e8ddc9`.
- All Western map components are 3786 bytes; Korean is 3828 bytes. These boundary facts are explicitly regression-tracked before final source collapse/link verification.
- `menu.asm` is reconstructed as shared logic with narrow Korean WRAM/far-call branches plus localized JP/KR/DE/FR/IT/ES data.
- `text.asm` is reconstructed with the Korean double-byte Hangul renderer, Japanese text-command/string rules, and Western language literal/weekday branches.
- JP Rev 0 / Rev A late-Bank00 differences are separated correctly: core `audio.asm` code is shared, while JP Rev 0 alone carries a 177-byte trailing ROM0 garbage block and Rev A uses zero fill.
- Verified Korean semantic branches include RST/LCD timing, initialization, serial timing, SRAM state tracking, tilemap transfer, graphics request synchronization, double-byte string/name handling, palette bank preservation, video helpers, and menu/window WRAM handling.
- Verified Japanese semantic branches include VBlank handling, RTC carry behavior, joypad omissions, simplified graphics/video paths, Japanese name widths, localized number rendering, and inline default map-event strings.
- A Bank 00 bootstrap `Makefile` now defines all eight regional/revision assembly targets. During this bootstrap stage it uses the pinned reference submodules only for their regional constants/macros/charmaps; no ROM image is read.
- `.github/workflows/bank00-assemble.yml` runs a clean RGBDS assembly of all eight HOME variants and uploads the generated object files on success. This CI gate is being used to expose and eliminate remaining assembly dependencies before linking.

## Map provenance

The locally vendored snapshots are generated from these exact public-source revisions:

- `home/map_variants/western.asm`: `pret/pokegold` @ `656583c939d30f920a316177311a502dd222b57c`
- `home/map_variants/japanese.asm`: `Narishma-gb/pokesilver` @ `edbe53978ef1777fc5c41019e17b7544070eab92`
- `home/map_variants/korean.asm`: `Narishma-gb/pokegold-kr` @ `f4496dda3003ccc5fc26f2757171a3b111e65307`

The reference gitlinks and vendoring tools remain for provenance/reproducibility. See `docs/bank00_map_source_provenance.md`, `docs/bank00_map_binary_verification.md`, and `docs/bank00_map_source_delta.md`.

## Bank 00 analysis

- `docs/bank00_full_layout.md`
- `docs/bank00_initial_map.md`
- `docs/bank00_home_phase1.md`
- `docs/bank00_map_source_provenance.md`
- `docs/bank00_map_binary_verification.md`
- `docs/bank00_map_source_delta.md`
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
- `Makefile`
- `.github/workflows/bank00-assemble.yml`

Additional source helpers include regional `print_num.asm`, shared `battle_vars.asm`, shared `hm_moves.asm`, and exact JP Rev 0 reconstruction data under `garbage/rev_0/bank00.asm`.

## Next Bank 00 milestone

The source inventory and map binary baseline are complete, Korean/Western map duplication is reduced to one common body plus a single Western tail, and the assembly harness is now in place. Remaining Bank 00 gates are:

1. Move the three Japanese inline map-event text stubs into narrow `_JAPANESE` branches so all retail map logic uses one common source.
2. Make the eight-target Bank 00 assembly CI pass, vendoring/reconstructing any remaining constants, macros, symbols, or memory definitions required by HOME.
3. Link Bank 00 for all eight releases and compare every generated byte with the preserved originals.
4. Resolve every mismatch and record the verified hashes/ranges.
5. Only after the complete Bank 00 gate passes move to Bank 01.

## 📚 Documentation

| Document | Purpose |
| --- | --- |
| [Documentation Hub](docs/README.md) | Central entry point for project documentation |
| [Project Status](docs/PROJECT_STATUS.md) | Reconstruction and matching status |
| [Version Coverage](docs/VERSIONS.md) | Supported releases, revisions, sizes, and hashes |
| [Disassembly Standards](docs/DISASSEMBLY_STANDARDS.md) | Source reconstruction and provenance standards |
| [Build and Matching](docs/BUILD_AND_MATCHING.md) | Reproducible build and exact-match workflow |
| [Verification](docs/VERIFICATION.md) | Evidence levels and matching criteria |
| [Asset Workflow](docs/ASSET_WORKFLOW.md) | Graphics, sprites, deduplication, manifests, and review batches |
| [Contributing](CONTRIBUTING.md) | Contribution and pull-request guidance |
