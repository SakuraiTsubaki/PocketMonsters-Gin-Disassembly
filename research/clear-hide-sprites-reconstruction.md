# Gin ClearSprites and HideSprites

The Japanese release `gin-jp-rev0` is the origin reference. All 8 cataloged releases (Japanese, Korean, English, German, Spanish, French, Italian) contain exactly one adjacent ROM0 pair. The reports preserve the release-specific shadow OAM address and routine hashes without ROM bytes. `ClearSprites` clears 160 bytes; `HideSprites` writes Y=160 to 40 entries with stride four. Korean precedes English where available, and release status is unchanged.
