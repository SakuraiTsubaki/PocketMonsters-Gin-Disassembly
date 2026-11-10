SECTION "HP Palette Reconstruction", ROM0

GetHPPal::
    ld d, HP_GREEN
    ld a, e
    cp 24
    ret nc
    inc d
    cp 10
    ret nc
    inc d
    ret
