# Pocket Monsters Gin SpeechTextbox disassembly

`gin-jp-rev0` is the Japanese origin reference. All 8 cataloged releases (Japanese, Korean, English, German, Spanish, French, Italian) contain one 10-byte entry that loads the release-specific textbox tilemap pointer, sets a 4-by-18 interior, and tail-jumps to the independently verified Textbox entry. Candidate status is retained; evidence contains hashes and decoded operands, not ROM bytes.
