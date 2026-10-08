# Japanese main font

Japanese Silver stores its standard 128-tile 1bpp font at bank 62 address `0x42F2`, file offsets `0xF82F2` through `0xF86F2`. The standard loader begins at file offset `0xF8000` and loads the range into `vTiles1`.

The layout and loader semantics are corroborated by `pret/pokegold` source commit `ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8` (`engine/gfx/load_font.asm` and `gfx/font.asm`) and symbols commit `5bb78aa382e2b1b9eff48a0d7eb8c09a4fe81ddc` (`pokesilver.sym`: `_LoadStandardFont` at `3e:4000`, `Font` at `3e:42f2`). The Japanese retail ROM independently contains the same loader shape and pointer at that location.

Japanese revisions 0 and 1 share range SHA-256 `0902d141b40af70008d3176cf4cc13f5d5a10812ffaf08ecee5752fa7e31b8ca`. `graphics/font/main-font-jp.png` is a deterministic 4× nearest-neighbour rendering. No ROM image or raw ROM range is published.
