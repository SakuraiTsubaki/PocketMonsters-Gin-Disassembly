SECTION "Enable LCD Reconstruction", ROM0

EnableLCD::
    ldh a, [rLCDC]
    set B_LCDC_ENABLE, a
    ldh [rLCDC], a
    ret
