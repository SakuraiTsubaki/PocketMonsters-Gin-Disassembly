# English main font

The official English Silver release stores its standard 128-tile 1bpp font at bank 62 address `0x42F2`, file offsets `0xF82F2` through `0xF86F2`. `pret/pokegold` source commit `ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8` and symbols commit `5bb78aa382e2b1b9eff48a0d7eb8c09a4fe81ddc` identify the same `Font` boundary and `_LoadStandardFont` transfer.

The verified retail range SHA-256 is `6e2437dd65c8f64b0a97c982ff1f8315a60d43cf88be0ca9cee81508692172d7`, shared with English Gold. `graphics/font/main-font-en.png` is a deterministic 4× nearest-neighbour rendering; raw ROM bytes are not published.
