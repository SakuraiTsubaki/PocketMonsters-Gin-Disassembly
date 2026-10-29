# Pocket Monsters Gin ClearBox disassembly

`gin-jp-rev0` is the Japanese origin reference. All 8 cataloged releases (Japanese, Korean, English, German, Spanish, French, Italian) have one verified ClearBox path. The routine fills a B-by-C rectangle at HL, preserving the row start and dimensions while advancing by the 20-tile screen width. Korean Gold/Silver use a ROM0 farcall wrapper and a bank 0x7F core that first clears attribute bit 3 at HL+0x0940 over the same B-by-C rectangle. Candidate status is retained; maps publish control-flow, operands, provenance and hashes, never ROM bytes.
