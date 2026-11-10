SECTION "Set HP Palette Reconstruction", ROM0

SetHPPal::
    call GetHPPal
    ld [hl], d
    ret
