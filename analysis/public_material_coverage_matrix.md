# Public Material Coverage Matrix — Pocket Monsters Gin / Pokémon Silver

Started: 2026-09-14

## Rule

This project does not treat a handful of well-known repositories as an exhaustive survey. The survey remains open until every material class below has been searched for the Japanese origin release, each known Japanese revision/development lineage, and every official regional/localized release. `NOT_FOUND` never means nonexistence; it means no public source has yet been located in the searched corpus.

Status values: `NOT_STARTED`, `SEARCHING`, `FOUND`, `CROSS_VERIFIED`, `PRIMARY_SOURCE_FOUND`, `CONFLICT`, `NOT_FOUND`, `NOT_APPLICABLE`.

## Material classes

| Material class | JP origin | JP revisions / debug / prototype | KR | EN / UE | DE | FR | IT | ES | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Official product pages | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Modern and historical official pages kept separate |
| Contemporary Nintendo / Pokémon web pages | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Web Archive targets also required |
| Retail manuals / instruction booklets | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Scans, catalog metadata, OCR/transcripts tracked separately |
| Box / cartridge / inserts / registration material | SEARCHING | SEARCHING | FOUND | FOUND | FOUND | FOUND | FOUND | FOUND | Physical specimens and product codes tracked separately from ROM identity |
| Advertisements / print ads | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Magazines, newspapers, store ads |
| TV commercials / promotional video | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Official uploads and preserved broadcasts |
| Press releases / retailer sheets / press kits | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Contemporary documents prioritized |
| Official guidebooks | FOUND | SEARCHING | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Bibliography is not equivalent to full contents |
| Third-party contemporary guidebooks | FOUND | SEARCHING | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Errors must be cross-checked |
| Magazines / CoroCoro / Nintendo Power / regional press | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Includes release previews and event announcements |
| Official event-distribution announcements | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Mew/Celebi/egg campaigns etc. separated by game compatibility |
| Event-distribution research / preservation | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Community indexes are discovery aids, not final proof |
| Retail disassemblies | FOUND | FOUND | FOUND | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Japanese origin is baseline |
| Historical / abandoned disassemblies | FOUND | FOUND | FOUND | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Includes Greatpriceman Korean research |
| Forks / translation forks / restorations | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Derivative projects classified separately from primary disassemblies |
| Space World / prototype material | NOT_APPLICABLE | FOUND | NOT_APPLICABLE | NOT_APPLICABLE | NOT_APPLICABLE | NOT_APPLICABLE | NOT_APPLICABLE | NOT_APPLICABLE | Development lineage only |
| Debug builds / symbols / patches | NOT_APPLICABLE | FOUND | NOT_APPLICABLE | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Retail and debug must not be merged |
| ROM/checksum databases | FOUND | FOUND | FOUND | FOUND | FOUND | FOUND | FOUND | FOUND | Hashes are public references, not direct ROM verification by this project |
| Cartridge / PCB / component photography | FOUND | SEARCHING | FOUND | FOUND | FOUND | FOUND | FOUND | FOUND | Hardware archives and board photographs |
| ROM maps / address maps | FOUND | SEARCHING | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Reconcile old maps with modern symbols |
| WRAM / HRAM / SRAM / save maps | FOUND | SEARCHING | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Save/RTC research included |
| Link cable / Time Capsule protocol research | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Gen I compatibility is part of scope |
| RTC / MBC3 hardware research | FOUND | SEARCHING | FOUND | FOUND | FOUND | FOUND | FOUND | FOUND | General hardware docs + cartridge-specific evidence |
| Text encoding / charmap / fonts | FOUND | SEARCHING | FOUND | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Korean DBCS/Hangul is an independent localization track |
| Localization / censorship / text differences | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Must be grounded in source or scans |
| Pokémon / move / item / trainer data | FOUND | SEARCHING | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Full tables, not sample entries |
| Encounters / maps / scripts / NPC / event data | FOUND | SEARCHING | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Full map/event census required |
| Graphics / sprites / tiles / palettes / fonts | FOUND | SEARCHING | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | PNG previews plus source assets in repo when reconstructed |
| Audio / music / SFX / cries | FOUND | SEARCHING | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Track usage, unused tracks and regional differences |
| Bugs / glitches | FOUND | SEARCHING | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Trigger, cause, affected builds, fixes/revisions |
| Unused / cut / dummy / garbage data | FOUND | FOUND | SEARCHING | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | TCRF and source-level evidence both required |
| Save editors / emulators / debugger research | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Tool behavior is secondary evidence |
| Archived fan research / old forums / dead sites | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Wayback/archival searches required |
| Later official retrospectives | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Used only as later corroboration |
| Virtual Console patches / behavioral changes | FOUND | NOT_APPLICABLE | NOT_APPLICABLE | FOUND | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Strictly separated from original cartridge behavior |
| Stadium 2 / linked official software evidence | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | SEARCHING | Used to study transfer/distribution/link behavior |

## Sources newly added to the live census in this pass

- Nintendo official Gold/Silver retrospective series, including guidebook-production recollections and later official explanations of mechanics.
- Game Preservation Society catalog index and individual contemporary Japanese Gold/Silver guidebook records.
- `Greatpriceman/pokegold-ko` and `Greatpriceman/pokegold-kr` historical Korean disassembly/research lineages.
- `pret/pokegold-spaceworld` complete public Space World 1997 demo lineage plus derivative translation/restoration forks; derivatives are never treated as original prototype evidence without comparison.
- Bulbapedia Japanese Generation II event-distribution index as a discovery source for Space World 2000 Celebi, World Hobby Fair Celebi, Mystery Egg campaigns, and related distribution leads.
- `pret/pokecrystal` bugs/glitches documentation and unused-data documentation as cross-generation technical leads when Gold/Silver behavior is shared or explicitly contrasted.

## Completion rule

No source category is considered exhausted merely because one source was found. Each row must be searched across Japanese and original-language queries, known archives, GitHub/forks, bibliographic databases, contemporary press, and regional communities. Claims are promoted only after provenance and independence of sources are checked.