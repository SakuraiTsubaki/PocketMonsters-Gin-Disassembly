# Bank 00 map binary verification

This note records the byte-level verification pass used before collapsing the three vendored `home/map_variants/*.asm` snapshots into shared source with narrow region conditionals.

## Scope

The `map` component is defined by `analysis/bank00_component_starts_matrix.csv`: it begins at the `map` row and ends immediately before the `farcall` row for each release.

The analysis does **not** write extracted ROM bytes to the repository. It records only component boundaries, hashes, and pairwise alignment statistics.

## Reference inputs

All eight preserved Silver/Gin reference images used for this pass matched the size and SHA-1 values already recorded in `config/versions/releases.yml`.

| release | map range | bytes | map SHA-1 |
| --- | ---: | ---: | --- |
| US-EU | `0x1F5D-0x2E26` | 3786 | `65d48fe473c51b77bd7eb3b8e9bc9b066b61bbac` |
| JP-REV0 | `0x1F0A-0x2DE2` | 3801 | `047969f4b6cdddb768918c139bf73e65c6e8ddc9` |
| JP-REVA | `0x1F0A-0x2DE2` | 3801 | `047969f4b6cdddb768918c139bf73e65c6e8ddc9` |
| KR-REV0 | `0x1FBA-0x2EAD` | 3828 | `4633c8a10b807abcb303074d5ab6265c73cebadb` |
| DE-REV0 | `0x1F8A-0x2E53` | 3786 | `dec6e6f2da9e7a647362f940612c8c0633048e9e` |
| FR-REV0 | `0x1F6F-0x2E38` | 3786 | `6a79c4dc0a60cadaeb1d27464fdf1f22c13db96c` |
| IT-REV0 | `0x1F82-0x2E4B` | 3786 | `21fc0f902ef2f56be971afbd18f09e21f3eaf7ec` |
| ES-REV0 | `0x1F81-0x2E4A` | 3786 | `dd6ac2cb0dacac6100ca6b57fcfc205b8add7d39` |

The machine-readable form is `analysis/bank00_map_binary_summary.csv`.

## Findings

1. **Japanese Rev 0 and Rev A are byte-identical for the entire map component.** They have the same 3801-byte length and the same SHA-1. The shared source therefore needs only one `_JAPANESE` map path; no map-level Rev 0/Rev A split is justified.
2. **All Western releases have the same 3786-byte component length.** Their hashes differ because the assembled bytes contain release-specific addresses and localized dependencies. Equal component length plus the vendored source ancestry supports keeping a common Western source path rather than cloning one file per Western language.
3. **Japanese is 15 bytes longer than the Western component.** This agrees with the existing source-level mapping that attributes the Japanese delta primarily to inline default event strings. The collapse should encode those as narrow `_JAPANESE` data branches, not a second full copy of map logic.
4. **Korean is 42 bytes longer than the Western boundary.** Existing Bank 00 boundary analysis already places the apparent tail delta in Korean far-call/predef helper code immediately before `FarCall_hl`, rather than treating the entire +42 as opaque map logic. The shared-source pass must preserve that boundary fact and verify it by assembly before moving labels between components.
5. Raw byte alignment is only a diagnostic. Absolute ROM0 operands move when earlier components change size, so a changed operand byte does not by itself imply changed source logic. `analysis/bank00_map_binary_pairwise.csv` must not be used as a semantic diff by itself.

## Pairwise alignment highlights

- `JP-REV0` vs `JP-REVA`: ratio `1.000000`, 3801 matching bytes, byte-identical.
- `US-EU` vs Western localized releases: sequence ratios range from `0.929741` to `0.938193`.
- The strongest localized-Western pair in this pass is `IT-REV0` vs `ES-REV0`: ratio `0.946381`.
- `US-EU` vs `JP-REV0`: ratio `0.818242`.
- `US-EU` vs `KR-REV0`: ratio `0.767271`.

These ratios are produced by Python `difflib.SequenceMatcher(..., autojunk=False)` and are useful only for triage and regression tracking.

## Reproduction

`tools/analyze_bank00_component_binary.py` reads the existing component-start matrix and accepts repeated `--rom RELEASE=PATH` arguments. For example:

```sh
python tools/analyze_bank00_component_binary.py \
  --component map \
  --rom US-EU=/path/to/Pokemon-Silver-USA-Europe.gbc \
  --rom JP-REV0=/path/to/Pocket-Monsters-Gin-Japan.gbc \
  --rom JP-REVA=/path/to/Pocket-Monsters-Gin-Japan-Rev-A.gbc \
  --rom KR-REV0=/path/to/Pocket-Monsters-Eun-Korea.gbc \
  --rom DE-REV0=/path/to/Pokemon-Silberne-Edition-Germany.gbc \
  --rom FR-REV0=/path/to/Pokemon-Version-Argent-France.gbc \
  --rom IT-REV0=/path/to/Pokemon-Versione-Argento-Italy.gbc \
  --rom ES-REV0=/path/to/Pokemon-Edicion-Plata-Spain.gbc
```

The default outputs are:

- `analysis/bank00_map_binary_summary.csv`
- `analysis/bank00_map_binary_pairwise.csv`

## Collapse gate

The next source-editing pass is:

1. Use `home/map_variants/western.asm` as the common structural baseline.
2. Diff the Japanese and Korean snapshots by labels/source statements, not only by assembled bytes.
3. Introduce only the minimum `_JAPANESE` / `_KOREAN` branches required to reproduce their exact component bytes.
4. Keep JP Rev 0 and Rev A on the same map source path.
5. Assemble every release and compare the generated Bank 00 bytes with the preserved originals.
6. Do **not** start Bank 01 until the complete Bank 00 verification gate passes.
