# Gin far-ROM access reconstruction

gin-jp-rev0 is the Japanese origin reference. All 8 cataloged releases (Japanese, Korean, English, German, Spanish, French, Italian) independently verify adjacent GetFarByte and GetFarWord routines. Both save the current ROM bank, switch to the bank in A, read through HL, restore the previous bank, and return without publishing ROM bytes. The gs profile records its distinct temporary-storage convention.
