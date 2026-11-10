SECTION "Disable LCD Reconstruction", ROM0

DisableLCD::
    ldh a, [rLCDC]
    bit B_LCDC_ENABLE, a
    ret z

    xor a
    ldh [rIF], a
    ldh a, [rIE]
    ld b, a
    res B_IE_VBLANK, a
    ldh [rIE], a
.wait
    ldh a, [rLY]
    cp LY_VBLANK + 1
    jr nz, .wait

    ldh a, [rLCDC]
    and ~LCDC_ON
    ldh [rLCDC], a
    xor a
    ldh [rIF], a
    ld a, b
    ldh [rIE], a
    ret
