SECTION "Long Byte Comparison Reconstruction", ROM0

CompareBytesLong::
.loop
    ld a, [de]
    cp [hl]
    jr nz, .diff
    inc de
    inc hl
    dec bc
    ld a, b
    or c
    jr nz, .loop
    scf
    ret
.diff
    and a
    ret
