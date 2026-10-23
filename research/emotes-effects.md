# Pokemon Silver overworld emotes and effects

The Japanese release `gin-jp-rev0` is the origin reference. Its complete 608-byte block is byte-identical in all 8 verified releases (Japanese, Korean, English, German, Spanish, French, Italian), including Korean where officially available. The block contains eight 16x16 emotes followed by shadow, fishing-rod, boulder-dust, and grass-rustle field graphics.

The two PNG atlases are regenerated directly from verified local ROM ranges; the layout JSON retains each asset's source-relative range and rendered rectangle. Per-release evidence records identities, absolute offsets, and hashes without publishing raw ROM bytes. Names and ordering follow `pret/pokegold` at `fc702b6d922aecce274782d68bba8639936a1182`, `gfx/emotes.asm`.
