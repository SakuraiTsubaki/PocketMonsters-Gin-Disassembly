; Multiply A by C with an 8-bit result in A.
SimpleMultiply::
    and a
    ret z
    push bc
    ld b, a
    xor a
.loop
    add c
    dec b
    jr nz, .loop
    pop bc
    ret
