# Sprite-first extraction and deduplication pipeline

Sprite reconstruction is now the first active asset track for this repository. Uploads are deliberately split into small species batches instead of one large commit.

## Fixed rules

- Source ROMs are read-only verification inputs and are never committed.
- Human-viewable PNG images are committed alongside reconstruction data.
- Identical sprites from multiple language/region/revision ROMs are stored **once**.
- Every source release still gets a manifest row recording its original bank/address/file offset and hashes.
- Deduplication is verified at three levels: exact compressed LZ3 bytes, decompressed 2bpp bytes, and decoded pixel indices.
- A palette entry is also hashed so visually distinct palette variants cannot be collapsed accidentally.
- Upload batches stay small; the initial batch is National Dex `#001-#005`.

## Gen II Pokémon sprite format used here

The retail Silver releases in this project use the Pokémon pic pointer table at ROM bank `0x12`, address `0x4000`. Each species has a 6-byte entry: three bytes for front and three for back. A pic pointer stores a defined bank followed by a little-endian address. The engine repairs three historical defined-bank values before reading the compressed data:

- `0x13 -> 0x1F`
- `0x14 -> 0x20`
- `0x1F -> 0x2E`

The sprite payload is Gen II LZ3. Front sprites decompress to 5x5, 6x6, or 7x7 tiles; back sprites decompress to 6x6 tiles. Pokémon graphics use RGBGFX column-major tile ordering (`--columns`).

The Pokémon palette table is located per ROM by the unique Bulbasaur normal middle-color signature. Each species owns 8 bytes: 4 bytes for the normal middle colors and 4 bytes for shiny middle colors. White and black are implicit outer colors for preview rendering.

## Batch output

For each canonical sprite:

- `front.2bpp.lz` / `back.2bpp.lz` — exact compressed source bytes needed for byte-identical reconstruction.
- `front.png` / `back.png` — normal-color human-viewable image.
- `front_shiny.png` / `back_shiny.png` — shiny-color preview using the same bitmap.
- `analysis/sprites/batch_*.json` — canonical hashes plus per-release source locations.
- `analysis/sprites/batch_*.csv` — flat review table.

`tools/extract_pokemon_sprites.py` reproduces the extraction and aborts rather than silently merging a batch if any supplied release differs in compressed bytes, decoded 2bpp, pixels, or palette data.
