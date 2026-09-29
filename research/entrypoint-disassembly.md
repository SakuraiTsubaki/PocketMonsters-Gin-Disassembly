# Japanese cartridge entry disassembly

The exact-hash Japanese origin candidate stores `00c3c505` at cartridge offset `0x0100`. This decodes as `nop` followed by `jp $05c5`. The committed RGBDS source reconstructs all four bytes, and tests bind the encoded bytes to both the analysis report and source-slice SHA-256 `5c71cda44b541ba24b009cdc7d73e32840f44a52c5625535354b0a0cea04b1c1`.

This establishes the fixed cartridge entry only. It neither promotes the candidate release nor claims that the branch target's complete routine has been disassembled.

