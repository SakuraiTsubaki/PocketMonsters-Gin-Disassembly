; Link-synchronised battle PRNG core reconstructed across all Silver releases.

_BattleRandom::
    ld a, [wLinkMode]
    and a
    jp z, Random
    push hl
    push bc
    ld a, [wLinkBattleRNCount]
    ld c, a
    ld b, 0
    ld hl, wLinkBattleRNs
    add hl, bc
    inc a
    ld [wLinkBattleRNCount], a
    cp SERIAL_RNS_LENGTH - 1
    ld a, [hl]
    pop bc
    pop hl
    ret c
    push hl
    push bc
    push af
    xor a
    ld [wLinkBattleRNCount], a
    ld hl, wLinkBattleRNs
    ld b, SERIAL_RNS_LENGTH
.loop
    ld a, [hl]
    ld c, a
    add a
    add a
    add c
    inc a
    ld [hli], a
    dec b
    jr nz, .loop
    pop af
    pop bc
    pop hl
    ret
