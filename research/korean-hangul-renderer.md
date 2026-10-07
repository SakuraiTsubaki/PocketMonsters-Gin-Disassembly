# Korean Hangul renderer

Korean Gold and Silver use a two-byte character path backed by a dynamic two-tile VRAM cache. The five reconstructed routines in `src/hangul_renderer_ko.asm` cover character placement, cache reclamation, free-slot selection, cache lookup, and transfer of a two-tile 1bpp glyph into VRAM.

The code lives in ROM bank `0x7f`. CPU addresses were taken from the current `Narishma-gb/pokegold-kr` symbols build at commit `77b4875b2d9ef95eb0db51f577b7754ee873c0a6`. The readable routine labels were cross-checked against `SakuraiTsubaki/pokegold-kr` historical commit `801b8bf5dc38d1aac121a68ce61bc707afe08e0c`, used strictly as historical reference because that repository's active branch is intentionally empty.

For each routine, the banked CPU address was converted to a file offset with `bank * 0x4000 + (address - 0x4000)`. The resulting ranges were hashed independently in the verified Korean Gold and Korean Silver retail ROMs. All five hashes match between the two releases. No raw ROM bytes are stored in the report.

The renderer uses the font tables documented by `manifests/korean-hangul-font.json`. `PlaceDoubleByteChar` reuses a cached glyph when possible, allocates or reclaims an even-aligned two-tile slot otherwise, marks both tilemap cells as VRAM-bank-1 glyphs, and writes the upper and lower tile indices. `DrawHangulChar` records the table and entry in WRAM, derives the source bank/address, expands the two 1bpp tiles into a WRAM transfer buffer, and selects HBlank or general-purpose VRAM DMA based on LCD state.

