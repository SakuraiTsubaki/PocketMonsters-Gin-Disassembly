; Unsigned 8-bit division used by RandomRange.
SimpleDivide::
    ld b, 0
.loop
    inc b
    sub c
    jr nc, .loop
    dec b
    add c
    ret
