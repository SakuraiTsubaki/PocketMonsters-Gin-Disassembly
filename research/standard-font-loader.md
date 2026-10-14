# Standard-font loader provenance

Every catalogued Silver retail ROM was independently identity-gated before its standard-font loader was located. Japanese revisions 0 and 1 and the English, German, French, Italian, and Spanish releases load 128 1bpp tiles from bank `0x3e`, address `0x42f2`, into VRAM `0x8800`. The 13-byte loader begins at file offset `0xf8000`.

Korean Silver keeps the loader at `0xf8000`, first calls the Hangul-font initializer at `0x1470`, and then loads the standard font from address `0x42f5`. This produces a distinct 16-byte routine and preserves the Korean renderer path rather than treating it as a global binary.

The structure and names are corroborated by `pret/pokegold` commit `ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8` and `Narishma-gb/pokegold-kr` commit `c90f31dadef17f033a8f1bdada701b26cef18241`. The local ROM hashes and generated reports are authoritative here. No ROM bytes are published.
