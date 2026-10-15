; Unbiased bounded RNG reconstructed across all catalogued Silver releases.
RandomRange::
    push bc
    ld c, a
    xor a
    sub c
.mod
    sub c
    jr nc, .mod
    add c
    ld b, a
    push bc
.loop
    call Random
    ldh a, [hRandomAdd]
    ld c, a
    add b
    jr c, .loop
    ld a, c
    pop bc
    call SimpleDivide
    pop bc
    ret
