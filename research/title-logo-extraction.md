# Silver title-logo extraction

This unit preserves public PNG renderings and reproducible provenance for every
verified Silver-language ROM in the local release catalog. Japanese is the
origin reference, followed by Korean, English, and the remaining official
European languages. No ROM bytes or compressed streams are committed.

## Code-derived locations

The title loader places an LZ stream address in `HL`, a VRAM destination in
`DE`, and the source bank in `A` before calling the far decompressor. The file
offset is `bank * 0x4000 + (address - 0x4000)`. This instruction evidence—not
an unconstrained search for valid compressed data—determines every offset.

Japanese revisions 0 and 1 both use loader `0x6469` and the same combined
118-tile logo at `0xE4410`. Korean loader `0x6355` selects a distinct combined
127-tile logo at `0x98000`.

The five European-language builds use lower and upper streams. Their localized
lower logos start at `0x98000` and have five distinct decompressed hashes. The
shared upper Silver Pokémon mark starts at `0x98498` in English and `0x98706`
in German, French, Italian, and Spanish. All five upper streams decompress to
the same 60-tile hash.

## Public-source cross-reference and reproduction

`pret/pokegold` commit `62388c7204e5d13aa05b4231e220b6760584d1b5`
names the Silver lower and upper graphics in `gfx/misc.asm`; its
`engine/movie/title.asm` shows the same decompression order and VRAM targets.

Run `tools/extract_gb_lz_2bpp.py` from `SakuraiTsubaki/Disassembly` using the
complete-ROM SHA-256, source offset, and 20 tiles per row recorded in each JSON
report. The extractor hash-gates the ROM and publishes only deterministic PNGs
and provenance metadata.
