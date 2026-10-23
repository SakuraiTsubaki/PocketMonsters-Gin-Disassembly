# Pokemon Silver party icons

The Japanese release `gin-jp-rev0` is the origin reference. The complete 4,864-byte party-icon table is byte-identical in all 8 verified releases (Japanese, Korean, English, German, Spanish, French, Italian), including Korean where officially available. It contains 38 icon types, each stored as an uncompressed 16x32 2bpp image.

`graphics/pokemon/party-icons-atlas.png` is regenerated directly from the verified ROM range. Its JSON companion maps every named icon to logical and scaled PNG rectangles. Per-release evidence preserves identities, offsets, and hashes without publishing raw ROM bytes. Naming and storage order follow `pret/pokegold` at `fc702b6d922aecce274782d68bba8639936a1182`, `gfx/icons.asm`.
