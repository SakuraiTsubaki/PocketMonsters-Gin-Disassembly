SECTION "Pokedex Flag Reconstruction", ROM0

CountSetBits::
    ld c, 0
.next
    ld a, [hli]
    ld e, a
    ld d, 8
.count
    srl e
    ld a, 0
    adc c
    ld c, a
    dec d
    jr nz, .count
    dec b
    jr nz, .next
    ld a, c
    ld [wNumSetBits], a
    ret
