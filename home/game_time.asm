ResetGameTime::
	xor a
	ld [wGameTimeCap], a
	ld [wGameTimeHours], a
	ld [wGameTimeHours + 1], a
	ld [wGameTimeMinutes], a
	ld [wGameTimeSeconds], a
	ld [wGameTimeFrames], a
	ret

GameTimer::
	nop
	ld a, [wGameLogicPaused]
	and a
	ret nz
	ld hl, wGameTimerPaused
	bit GAME_TIMER_COUNTING_F, [hl]
	ret z
	ld hl, wGameTimeCap
	bit GAME_TIME_CAPPED, [hl]
	ret nz

	ld hl, wGameTimeFrames
	ld a, [hl]
	inc a
	cp 60
	jr nc, .second
	ld [hl], a
	ret
.second:
	xor a
	ld [hl], a

	ld hl, wGameTimeSeconds
	ld a, [hl]
	inc a
	cp 60
	jr nc, .minute
	ld [hl], a
	ret
.minute:
	xor a
	ld [hl], a

	ld hl, wGameTimeMinutes
	ld a, [hl]
	inc a
	cp 60
	jr nc, .hour
	ld [hl], a
	ret
.hour:
	xor a
	ld [hl], a

	ld a, [wGameTimeHours]
	ld h, a
	ld a, [wGameTimeHours + 1]
	ld l, a
	inc hl
	ld a, h
	cp HIGH(1000)
	jr c, .ok
	ld a, l
	cp LOW(1000)
	jr c, .ok

	ld hl, wGameTimeCap
	set GAME_TIME_CAPPED, [hl]
	ld a, 59
	ld [wGameTimeMinutes], a
	ld [wGameTimeSeconds], a
	ret
.ok:
	ld a, h
	ld [wGameTimeHours], a
	ld a, l
	ld [wGameTimeHours + 1], a
	ret
