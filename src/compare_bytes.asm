SECTION "Byte Comparison Reconstruction", ROM0

CompareBytes::
.loop
    ld a, [de]
    cp [hl]
    ret nz
    inc de
    inc hl
    dec c
    jr nz, .loop
    ret
