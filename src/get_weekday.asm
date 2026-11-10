SECTION "Weekday Reconstruction", ROM0

GetWeekday::
    ld a, [wCurDay]
.mod
    sub 7
    jr nc, .mod
    add 7
    ret
