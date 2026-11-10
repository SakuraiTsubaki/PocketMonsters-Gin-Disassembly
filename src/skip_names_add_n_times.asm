SECTION "Array Stride Reconstruction", ROM0

SkipNames::
    ld bc, NAME_LENGTH
    and a
    ret z
.loop
    add hl, bc
    dec a
    jr nz, .loop
    ret

AddNTimes::
    and a
    ret z
.loop
    add hl, bc
    dec a
    jr nz, .loop
    ret
