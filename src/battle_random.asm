; Battle RNG wrapper reconstructed across all catalogued Silver releases.

BattleRandom::
    ldh a, [hROMBank]
    push af
    ld a, BANK(_BattleRandom)
    rst Bankswitch
    call _BattleRandom
    ld [wPredefHL + 1], a
    pop af
    rst Bankswitch
    ld a, [wPredefHL + 1]
    ret
