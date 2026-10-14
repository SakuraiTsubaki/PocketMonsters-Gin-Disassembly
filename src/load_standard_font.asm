; Semantic reconstruction of the retail Generation II standard-font loaders.
; ROM ranges and hashes are recorded in analysis/*-standard-font-loader.json.

LoadStandardFont_Japanese::
    ld de, $42f2
    ld hl, $8800
    ld bc, $3e80
    jp Get1bpp_Japanese

LoadStandardFont_Global::
    ld de, $42f2
    ld hl, $8800
    ld bc, $3e80
    jp Get1bpp_Global

LoadStandardFont_Korean::
    call SetStandardHangulFont
    ld de, $42f5
    ld hl, $8800
    ld bc, $3e80
    jp Get1bpp_Korean
