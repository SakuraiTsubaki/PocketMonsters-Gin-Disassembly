SECTION "Array Search Reconstruction", ROM0

IsInArray::
    ld b, 0
    ld c, a
.loop
    ld a, [hl]
    cp -1
    jr z, .NotInArray
    cp c
    jr z, .InArray
    inc b
    add hl, de
    jr .loop
.NotInArray
    and a
    ret
.InArray
    scf
    ret
