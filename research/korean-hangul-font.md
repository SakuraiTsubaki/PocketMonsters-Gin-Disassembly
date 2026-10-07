# Korean retail Hangul font tables

The verified Korean Silver retail ROM (`SHA-1 cb22d7e03a74dc3a563fde6be8626626b2b392e7`, `SHA-256 ebbac63c0c4309c82dbb6723e7163369784f962b4fd3e2f486075307c3008a22`) stores its two-tile-high Hangul glyph data as uncompressed Game Boy 1bpp tiles.

The three full font banks are ROM banks `0x78`, `0x79`, and `0x7a`, beginning at file offsets `0x1e0000`, `0x1e4000`, and `0x1e8000`. Each bank contains four 4096-byte tables. Tables `0` through `a` are published; the final 4096 bytes of bank `0x7a` repeat table `0` exactly.

The runtime interpretation is corroborated by `Narishma-gb/pokegold-kr` at commit `c90f31dadef17f033a8f1bdada701b26cef18241`: `gfx/hangul.asm` groups four 1bpp tables per bank, while `engine/dumps/bank7f.asm` selects a table entry and expands two 1bpp tiles for VRAM. The symbols build at `77b4875b2d9ef95eb0db51f577b7754ee873c0a6` places the three sections in decimal banks 120–122, or hexadecimal `0x78–0x7a`.

The reference repository is used only to explain the layout. Every PNG and analysis report here is regenerated from the locally verified retail ROM with `SakuraiTsubaki/Disassembly tools/extract_gb_1bpp.py`. No ROM bytes are committed. The grayscale PNGs are deterministic 4× previews of the original 1bpp tiles; their logical dimensions are 128×256 pixels.

Korean Gold and Korean Silver contain byte-identical data for all three font banks. This is verified independently in each game repository so that each artifact retains evidence tied to its own retail ROM identity.
