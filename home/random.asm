Random::
	push bc
	ldh a, [rDIV]
	ld b, a
	ldh a, [hRandomAdd]
	adc b
	ldh [hRandomAdd], a
	ldh a, [rDIV]
	ld b, a
	ldh a, [hRandomSub]
	sbc b
	ldh [hRandomSub], a
	pop bc
	ret

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
