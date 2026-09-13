# Bank 00 HOME Phase 1

This pass maps and verifies the first HOME components in ROM bank 00 across all eight preserved Silver releases.

## Verified component boundaries

| Component | JP Rev 0/A | Korean | US/EU, DE, FR, IT, ES |
| --- | --- | --- | --- |
| `vblank.asm` | `0150-032E` | `0150-032E` | `0150-032E` |
| `delay.asm` | `032E-0343` | `032E-0343` | `032E-0343` |
| `time_palettes.asm` | `0343-0360` | `0343-0360` | `0343-0360` |
| `fade.asm` | `0360-041B` | `0360-041B` | `0360-041B` |
| `lcd.asm` | `041B-045B` | `041B-045F` | `041B-045B` |
| `time.asm` | `045B-05AF` | `045F-05B4` | `045B-05B0` |
| `init.asm` | `05AF-06A9` | `05B4-0698` | `05B0-06AA` |
| `serial.asm` begins | `06A9` | `0698` | `06AA` |

The boundaries are derived from ROM vectors, cartridge entry points, stable opcode signatures, and cross-checking against the public English and Korean disassembly source organization.

## Source-level classification

The current English `pret/pokegold` and Korean `Narishma-gb/pokegold-kr` sources are source-identical for `vblank.asm`, `delay.asm`, `time_palettes.asm`, `fade.asm`, and `time.asm`.

Raw ROM bytes can still differ in these components because absolute addresses, WRAM/HRAM locations, far-call banks, and layout-dependent operands differ between releases.

Confirmed semantic Korean differences in this prefix:

- RST timing helpers in the vector area (`WaitHBlank` / `WaitOneLine`).
- LCD interrupt guard: Korean checks `rLY >= 144` before applying the per-scanline override. It reuses the already-loaded `rLY` value, making `lcd.asm` four bytes longer overall rather than six.
- Initialization path: Korean keeps CGB/AGB boot-state handling, clears HRAM through a far call, and blanks both BG maps through a far call. Korean `init.asm` is 228 bytes versus 250 bytes in the other mapped releases.
- Serial timing begins immediately after this prefix and is genuinely different: English/JP/EU use wait immediate `48` and short-delay immediate `15`, while Korean uses `96` and `30`; Korean also has two consecutive `255` long-delay loops instead of one.

These timing differences are verified directly in the preserved Korean ROM, not inferred only from the public WIP source.

## Revision result

JP Rev 0 and JP Rev A are byte-identical from `0150` through the start of `serial.asm` at `06A9`. Their Bank 00 revision differences occur later.

## Reconstruction model

This prefix should be reconstructed as shared HOME source with narrowly scoped release conditionals, not as per-release opaque bank blobs. Address shifts caused by localization layout should fall out naturally from the linker rather than being hard-coded as separate source copies.

## Files

- `analysis/home_prefix_ranges.csv`
- `analysis/home_prefix_diff_vs_us.csv`
- `tools/analyze_home_prefix.py`
