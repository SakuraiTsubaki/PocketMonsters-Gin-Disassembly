ResetMapBufferEventFlags::
	xor a
	ld hl, wEventFlags
	ld [hli], a
	ret

ResetBikeFlags::
	xor a
	ld hl, wBikeFlags
	ld [hli], a
	ld [hl], a
	ret

ResetFlashIfOutOfCave::
	ld a, [wEnvironment]
	cp ROUTE
	jr z, .outdoors
	cp TOWN
	jr z, .outdoors
	ret
.outdoors
	ld hl, wStatusFlags
	res STATUSFLAGS_FLASH_F, [hl]
	ret

EventFlagAction::
	ld hl, wEventFlags
	call FlagAction
	ret

FlagAction::
	ld a, e
	and 7
rept 3
	srl d
	rr e
endr
	add hl, de
	ld c, 1
	rrca
	jr nc, .one
	rlc c
.one
	rrca
	jr nc, .two
	rlc c
	rlc c
.two
	rrca
	jr nc, .three
	swap c
.three
	ld a, b
	cp SET_FLAG
	jr c, .clearbit
	jr z, .setbit
	ld a, [hl]
	and c
	ld c, a
	ret
.setbit
	ld a, [hl]
	or c
	ld [hl], a
	ret
.clearbit
	ld a, c
	cpl
	and [hl]
	ld [hl], a
	ret

CheckReceivedDex::
	ld de, ENGINE_POKEDEX
	ld b, CHECK_FLAG
	farcall EngineFlagAction
	ld a, c
	and a
	ret

CheckBPressedDebug::
	ld a, [wDebugFlags]
	bit DEBUG_FIELD_F, a
	ret z
	ldh a, [hJoyDown]
	bit B_BUTTON_F, a
	ret

xor_a::
	xor a
	ret

xor_a_dec_a::
	xor a
	dec a
	ret

CheckFieldDebug::
	push hl
	ld hl, wDebugFlags
	bit DEBUG_FIELD_F, [hl]
	pop hl
	ret
