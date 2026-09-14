# Public Source Census — Pocket Monsters Gin / Pokémon Silver

Started: 2026-09-14

## Research mandate

This census restarts the research from zero under the following rules:

- No local retail ROM is assumed to be available.
- Research must exhaust publicly accessible material as far as practical, not just one disassembly project.
- The Japanese retail release is the origin point. Every regional, language, and revision release is studied as a descendant/comparison target rather than treating the English release as the default original.
- Existing files in this repository are prior work and references; every factual claim may be re-audited.
- ROM binaries are not committed.
- Publicly reported hashes are references, not proof of local byte-for-byte verification.

## Evidence states

- `PUBLIC_REFERENCE` — reported by a public source.
- `CROSS_VERIFIED` — independently supported by multiple public sources.
- `SOURCE_RECONSTRUCTED` — reconstructed into repository source/assets with provenance.
- `BUILD_VERIFIED` — repository source can be built without relying on a retail ROM image for the reconstructed portion/target.
- `BYTE_VERIFICATION_PENDING` — direct comparison against an independently held retail ROM has not been performed locally.

## Source classes to exhaust

1. Nintendo / Pokémon / Game Freak / Creatures official pages and archived official material.
2. Retail manuals, packaging, guide material, advertisements, press and peripheral documentation when publicly accessible.
3. Japanese Gold/Silver disassemblies and revision/debug research.
4. International Gold/Silver disassemblies and regional/localization forks.
5. Korean Gold/Silver reverse-engineering and character-encoding research.
6. Development material: Space World prototypes, debug builds, prerelease screenshots/docs and other verifiable development remnants.
7. ROM/RAM/SRAM maps, symbols, address maps, text tables and hardware/RTC/link documentation.
8. Graphics, text, maps, audio, events, battle/data-system research.
9. Bugs, glitches, unused/dummy/inaccessible data and revision fixes.
10. Preservation databases, specialist wikis, archived forums and community research, traced back to primary sources where possible.
11. Later official material (VC, Stadium 2, HGSS, etc.) only as a separated comparison/verification layer.

## First confirmed source tranche

| Source | Class | Scope | Current use | Evidence state |
| --- | --- | --- | --- | --- |
| https://www.pokemon.co.jp/game/other/gbc-gs/ | Official | Japanese Gold/Silver product record; release date, hardware/peripheral summary, official overview | Japanese retail baseline metadata | `PUBLIC_REFERENCE` |
| https://www.nintendo.co.jp/n02/dmg/kingin/index.html | Official historical | Contemporary Nintendo Gold/Silver page | Japanese-era product/context cross-check | `PUBLIC_REFERENCE` |
| https://github.com/Narishma-gb/pokesilver | Public disassembly | Japanese Gold/Silver Rev.0, Rev.1 and debug targets | Primary public technical source for Japanese lineage | `PUBLIC_REFERENCE` |
| https://github.com/pret/pokegold | Public disassembly | UE Gold/Silver plus debug/patch targets | International source and Japanese→UE comparison target | `PUBLIC_REFERENCE` |
| https://github.com/Narishma-gb/pokegold-kr | Public disassembly | Korean Gold/Silver WIP; Korean character-map lineage; base-ROM-dependent portions | Korean regional research source, not a self-sufficient authority | `PUBLIC_REFERENCE` |
| https://github.com/pret/pokegold-spaceworld | Development disassembly | Space World prototype material | Development lineage only; never merged into retail facts | `PUBLIC_REFERENCE` |
| https://datacrystal.tcrf.net/wiki/Pok%C3%A9mon_Gold_and_Silver | Technical database | Release/header overview and links to ROM/RAM/text research | Secondary technical cross-check | `PUBLIC_REFERENCE` |
| https://datacrystal.tcrf.net/wiki/Pok%C3%A9mon_Gold_and_Silver%3AROM_map | Technical database | ROM map including localized high banks/data tables | Address/data cross-check; must be checked against modern disassemblies | `PUBLIC_REFERENCE` |
| https://datacrystal.tcrf.net/wiki/Pok%C3%A9mon_Gold_and_Silver%3ARAM_map | Technical database | Runtime memory notes | Secondary RAM cross-check | `PUBLIC_REFERENCE` |
| https://bulbapedia.bulbagarden.net/wiki/List_of_glitches_(Generation_II) | Community database | Generation II glitch catalogue | Discovery index; claims require source/code verification | `PUBLIC_REFERENCE` |
| https://www.nintendo.co.jp/3ds/pokemon_goldsilver_dlcard/index.html | Later official | 3DS VC Gold/Silver | Separated later-release comparison | `PUBLIC_REFERENCE` |

## Japanese-origin lineage currently established from public repositories

`Narishma-gb/pokesilver` publicly identifies these Japanese Silver targets:

- Silver Rev.0 — SHA-1 `fa8c51059c1642faa570db56ef089f54d1d2011f`
- Silver Rev.1 — SHA-1 `a11d5ddc26eb826086593f82370b15d16404d33e`
- Debug Silver Rev.1 `MONSSD.COM` — SHA-1 `4b5fabfb7004ad1f1ea46a527d808434020f1139`
- Debug Silver Rev.1 with corrected header — SHA-1 `9efda93a1efddf17745d77bae0fae5bbb0649af5`

These hashes are recorded as `PUBLIC_REFERENCE`, not local ROM verification.

## International/Korean public targets already identified

- `pret/pokegold` reports UE Silver SHA-1 `49b163f7e57702bc939d642a18f591de55d92dae` and additional debug/patch targets.
- `Narishma-gb/pokegold-kr` reports Korean Silver SHA-1 `cb22d7e03a74dc3a563fde6be8626626b2b392e7`; its README explicitly states that base ROMs are still required for that WIP project.

These are starting references only. German, French, Italian, Spanish and any other distinct retail/revision identities must be enumerated separately rather than inferred from language labels.

## Immediate census work remaining

- Enumerate every known retail Silver release identity by market, language, revision, header identity and publicly reported checksum.
- Enumerate official/manual/packaging/archive sources by territory.
- Trace forks, predecessor projects, symbols branches, tools and commit provenance for each disassembly.
- Catalogue prerelease/debug/prototype sources without mixing them into retail data.
- Build a claim-level source matrix so copied secondary claims are not counted as independent verification.
- Add machine-readable source registry and discovery log.

This file is a living census and is intentionally not marked complete.