# Release Matrix — Pocket Monsters Gin / Pokémon Silver

Started: 2026-09-14

This matrix is rebuilt from public sources only. A listed checksum is a public reference, not proof of local ROM possession or local byte-for-byte verification.

## Retail lineage

| Lineage | Market / language | Publicly reported identity | SHA-1 | Evidence | Status |
| --- | --- | --- | --- | --- | --- |
| Origin | Japan / Japanese | Pocket Monsters Gin, Rev.0 | `fa8c51059c1642faa570db56ef089f54d1d2011f` | Narishma-gb/pokesilver; TASVideos | Two public sources | `CROSS_VERIFIED` |
| Origin revision | Japan / Japanese | Pocket Monsters Gin, Rev.1 / Rev A | `a11d5ddc26eb826086593f82370b15d16404d33e` | Narishma-gb/pokesilver; TASVideos/Dorando | Multiple public sources | `CROSS_VERIFIED` |
| International | USA/Europe / English | Pokemon - Silver Version (USA, Europe) | `49b163f7e57702bc939d642a18f591de55d92dae` | pret/pokegold; TASVideos/Dorando | Multiple public sources | `CROSS_VERIFIED` |
| Localization | Germany / German | Pokemon - Silberne Edition | `8ecc58d621faaedf2a934bd2583d527220df7bb9` | OpenRetro No-Intro import; Dorando | Two public catalogues | `CROSS_VERIFIED` |
| Localization | France / French | Pokemon - Version Argent | `a4a7e8079b7a53e4d9ef43382bbb1090b9d45d1a` | OpenRetro No-Intro import; Dorando | Two public catalogues | `CROSS_VERIFIED` |
| Localization | Italy / Italian | Pokemon - Versione Argento | `c9eca9d0a837beb9137bb7d779e469c54e9f8d77` | OpenRetro No-Intro import; Dorando | Two public catalogues | `CROSS_VERIFIED` |
| Localization | Spain / Spanish | Pokemon - Edicion Plata | `05bd978ab2cb104b0aff3f696896e30885203a18` | OpenRetro No-Intro import; Dorando | Two public catalogues | `CROSS_VERIFIED` |
| Localization | Korea / Korean | Pocket Monsters Eun | `cb22d7e03a74dc3a563fde6be8626626b2b392e7` | Narishma-gb/pokegold-kr; OpenRetro/Dorando | Multiple public sources | `CROSS_VERIFIED` |

## Non-retail / development references kept separate

| Identity | SHA-1 | Classification | Public source |
| --- | --- | --- | --- |
| MONSSD.COM (Debug Silver Rev.1) | `4b5fabfb7004ad1f1ea46a527d808434020f1139` | Debug/development | Narishma-gb/pokesilver |
| Debug Silver Rev.1 with corrected header | `9efda93a1efddf17745d77bae0fae5bbb0649af5` | Debug/development reconstruction identity | Narishma-gb/pokesilver |
| mons2_slv_ps3_debug.bin | `4c2fafebdbc7551f4cd3f348bdd17e420b93b6e7` | Debug/development | pret/pokegold |
| DMGAAXP0.J57.patch | `a38c0dec807e8a9e3626a0ec0fdf96bfb795ef3a` | Patch/development artifact | pret/pokegold |
| Pokemon - Silberne Edition (Germany) (Beta) | `76fa60d66b2f22a035adc54c61aad9a415c894cd` | Beta candidate; not retail | OpenRetro No-Intro import |
| Space World material | see dedicated source project | Prototype/development | pret/pokegold-spaceworld |

The German beta identity currently has only a preservation-database reference in this pass and therefore remains `PUBLIC_REFERENCE`, not `CROSS_VERIFIED`.

## Sources used in this pass

- https://github.com/Narishma-gb/pokesilver
- https://github.com/pret/pokegold
- https://github.com/Narishma-gb/pokegold-kr
- https://tasvideos.org/Games/294/Versions/List
- https://openretro.org/gbc/pokemon-silver-version/edit
- https://dorando.emuverse.com/html/pocket-monsters-gin.html

## Unresolved census tasks

- Independently verify the German beta identity and determine its provenance/date/build relationship.
- Verify whether additional retail revisions exist for any localized Silver release.
- Record cartridge product codes, header version bytes, ROM/header checksums and board/cartridge variants per identity.
- Find region-specific manuals, boxes, official sites and release notices for every localization.
- Distinguish physical-market variants that share identical ROM bytes from distinct binary releases.
- Trace localization source projects/forks where no dedicated complete disassembly is currently known.

No row is `BYTE_VERIFIED` locally.