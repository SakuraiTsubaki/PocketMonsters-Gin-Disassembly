# Gin SetHPPal

The Japanese release `gin-jp-rev0` is the origin reference. All 8 cataloged releases (Japanese, Korean, English, German, Spanish, French, Italian) contain exactly one five-byte wrapper directly before their verified `GetHPPal`. It calls the release-specific target, writes D to [HL], and returns. Evidence records both addresses and the wrapper hash without ROM bytes. Korean precedes English where available; release status is unchanged.
