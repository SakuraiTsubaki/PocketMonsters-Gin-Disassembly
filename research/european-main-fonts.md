# European main fonts

The official German, French, Spanish, and Italian Silver releases store their 128-tile 1bpp standard fonts at bank 62 address `0x42F2`, file offset `0xF82F2`. The shared loader layout and `Font` boundary are corroborated by `pret/pokegold` source commit `ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8` and symbols commit `5bb78aa382e2b1b9eff48a0d7eb8c09a4fe81ddc`; every local retail ROM was independently identity-gated before extraction.

German and French share range SHA-256 `90aeb16144678c87d77cc5cfdda8feb2336501d1f241232c44ae75f15c3eee37`. Spanish and Italian share `34dd768b3736dadb0fb79c035849a32cdf193fb4ecd24b7cdd58df002ffc9980`. Separate language PNG paths preserve direct provenance even when the glyph bytes match.

All PNGs are deterministic 4× nearest-neighbour renderings. No ROM image or raw ROM range is published.
