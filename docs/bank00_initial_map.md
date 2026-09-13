# Bank 00 Initial Map

This is the first byte-verified map of ROM bank 00 across the eight preserved Silver releases. Addresses are CPU/ROM0 addresses unless otherwise stated.

## Reset and RST vectors

| Address | Role | JP Rev 0/A | KR | US/EU | DE | FR | IT | ES |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `0000` | reset / RST 00 | `di; jp 0100` | same | same | same | same | same | same |
| `0008` | FarCall entry | `jp 2DE3` | `jp 2EAE` | `jp 2E27` | `jp 2E54` | `jp 2E39` | `jp 2E4C` | `jp 2E4B` |
| `0010` | bank switch | common bytes | common bytes | common bytes | common bytes | common bytes | common bytes | common bytes |
| `0018` | RST 18 | `rst 38` | `WaitHBlank` start | `rst 38` | `rst 38` | `rst 38` | `rst 38` | `rst 38` |
| `0020` | RST 20 | `rst 38` | `WaitHBlank` continuation | `rst 38` | `rst 38` | `rst 38` | `rst 38` | `rst 38` |
| `0028` | jump-table helper | common bytes | common bytes | common bytes | common bytes | common bytes | common bytes | common bytes |
| `0038` | RST 38 | `rst 38` | `WaitOneLine` | `rst 38` | `rst 38` | `rst 38` | `rst 38` | `rst 38` |

The Korean routines at `0018`/`0020` poll LCD STAT mode and return on the next HBlank. The routine beginning at `0038` is a short delay loop. This matches the independently maintained Korean disassembly labels `WaitHBlank` and `WaitOneLine`.

## Hardware interrupt vectors

| Vector | Role | JP Rev 0/A | KR | US/EU / DE / FR / IT / ES |
| --- | --- | --- | --- | --- |
| `0040` | VBlank | `jp 0150` | `jp 0150` | `jp 0150` |
| `0048` | LCD | `jp 041B` | `jp 041B` | `jp 041B` |
| `0050` | Timer | `reti` | `reti` | `reti` |
| `0058` | Serial | `jp 06A9` | `jp 0698` | `jp 06AA` |
| `0060` | Joypad | `jp 08DE` | `jp 08D2` | `jp 08DF` |

These address shifts do not by themselves imply different semantics; later code/data layout changes can move an otherwise equivalent routine.

## Cartridge entry point

All releases use `nop; jp _Start` at `0100`.

- JP Rev 0/A: `_Start = 05C5`
- Korean: `_Start = 05CA`
- US/EU, German, French, Italian, Spanish: `_Start = 05C6`

The Nintendo logo bytes at `0104`–`0133` are identical across all eight source ROMs.

## Header-level release distinctions

The complete header fields and checksums are recorded in `analysis/header_matrix.csv`. Key Bank 00 distinctions include maker codes (`AAXJ`, `AAXK`, `AAXE`, `AAXD`, `AAXF`, `AAXI`, `AAXS`), ROM size, destination, CGB/SGB flags, revision byte, and checksums.

## Reconstruction direction

Bank 00 should not be represented as eight unrelated opaque blobs. The vector area already shows a better model:

- shared RST/reset/interrupt source where bytes and semantics agree;
- Korean-specific RST timing helpers;
- release-specific symbol addresses caused by layout differences;
- release-specific cartridge-header metadata generated at build time.

The next pass will extend this map from `0150` through the HOME routines and identify which differences are semantic versus relocation-only.
