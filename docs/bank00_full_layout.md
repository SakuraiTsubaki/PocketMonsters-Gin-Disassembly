# Bank 00 Full Layout

Bank 00 is being completed before work advances to Bank 01.

## Scope

The complete US/EU Silver Bank 00 (`0x0000-0x3FFF`) resolves into 53 contiguous HOME source components, from `home/header.asm` through `home/audio.asm`. The canonical include order is recorded by `pret/pokegold`'s `home.asm`, while exact US/EU component starts are resolved from the generated `pokesilver.sym` on the `symbols` branch.

See:

- `analysis/bank00_us_component_ranges.csv`
- `analysis/bank00_component_starts_matrix.csv`
- `tools/map_bank00_components.py`

## Multi-region mapping

The component-start matrix covers:

- JP Rev 0
- JP Rev A
- KR Rev 0
- USA/Europe Rev 0
- Germany Rev 0
- France Rev 0
- Italy Rev 0
- Spain Rev 0

The initial automatic pass compares LR35902 opcode identities while ignoring immediate operands. With 16-opcode signatures, 338 non-reference release/component entries resolve to one unique exact match. Components that fail or produce ambiguous matches are intentionally not guessed by the tool; they are resolved with ROM-byte inspection, adjacent component boundaries, known source length, or independently reconstructed regional source.

Examples of manually resolved semantic/layout exceptions include Korean `lcd`, `init`, `text`, `string`, `sram`, `copy_tilemap`, and `tilemap`, localized `names`, regional `print_bcd`, and the beginning of `audio`.

## Important regional structure

The early HOME prefix is highly shared. `vblank`, `delay`, `time_palettes`, and `fade` begin at the same addresses in all eight releases. After localization-specific routines and text handling, file boundaries shift by region but the overall HOME component order remains stable.

Korean semantic differences already verified include:

- RST `WaitHBlank` / `WaitOneLine` helpers;
- the LCD interrupt VBlank guard;
- the initialization path;
- serial timing constants and an additional long-delay loop;
- different graphics-request synchronization code;
- Korean text handling and double-byte character support;
- Korean SRAM bank validation/state tracking;
- far-called tilemap copy helpers.

## Japanese revisions

JP Rev 0 and Rev A use the same Bank 00 component boundaries. Their Bank 00 byte differences are confined to three components:

- `header`: 4 bytes (`0x014C-0x014F`)
- `sprite_anims`: 1 byte (`0x3C6B`)
- `audio`: 174 bytes in the late Bank 00 audio region

The exact contiguous runs are stored in `analysis/jp_bank00_revision_diff_runs.csv`.

## Reconstruction rule

Bank 00 will be represented as shared RGBDS source wherever logic is equivalent. Release-specific conditionals are used only for verified semantic or data differences. Pure address relocation is expected to fall out of the linker and is not treated as a separate source copy.

Bank 01 work does not begin until Bank 00 source coverage, assembly scaffolding, and byte-for-byte verification are complete for the supported source releases.
