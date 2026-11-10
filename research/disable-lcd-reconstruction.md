# Gin DisableLCD

The Japanese release `gin-jp-rev0` is the origin reference. All 8 cataloged releases (Japanese, Korean, English, German, Spanish, French, Italian) contain exactly one ROM0 implementation. It preserves IE, disables the VBlank interrupt while waiting for LY=145, clears LCDC bit 7, clears IF and restores IE. Evidence records release identity, address and code hash without ROM bytes. Korean precedes English where available; release status is unchanged.
