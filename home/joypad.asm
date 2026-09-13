Joypad::
; Placeholder joypad interrupt; normal input is updated from VBlank.
	reti

ClearJoypad::
	xor a
	ldh [hJoyPressed], a
	ldh [hJoyDown], a
	ret

UpdateJoypad::
	ld a, [wJoypadDisable]
	and (1 << JOYPAD_DISABLE_MON_FAINT_F) | (1 << JOYPAD_DISABLE_SGB_TRANSFER_F) | (1 << 4)
	ret nz

	ld a, [wGameLogicPaused]
	and a
	ret nz

	ld a, JOYP_GET_CTRL_PAD
	ldh [rJOYP], a
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	cpl
	and JOYP_INPUTS
	swap a
	ld b, a

	ld a, JOYP_GET_BUTTONS
	ldh [rJOYP], a
rept 6
	ldh a, [rJOYP]
endr
	cpl
	and JOYP_INPUTS
	or b
	ld b, a

	ld a, JOYP_GET_NONE
	ldh [rJOYP], a

	ldh a, [hJoypadDown]
	ld e, a
	xor b
	ld d, a
	and e
	ldh [hJoypadReleased], a
	ld a, d
	and b
	ldh [hJoypadPressed], a

	ld c, a
	ldh a, [hJoypadSum]
	or c
	ldh [hJoypadSum], a
	ld a, b
	ldh [hJoypadDown], a

	and PAD_BUTTONS
	cp PAD_BUTTONS
	jp z, Reset
	ret

GetJoypad::
	push af
	push hl
	push de
	push bc

	ld a, [wInputType]
	cp AUTO_INPUT
	jr z, .auto

	ldh a, [hJoypadDown]
	ld b, a
	ldh a, [hJoyDown]
	ld e, a
	xor b
	ld d, a
	and e
	ldh [hJoyReleased], a
	ld a, d
	and b
	ldh [hJoyPressed], a
	ld c, a
	ld a, b
	ldh [hJoyDown], a

.quit:
	pop bc
	pop de
	pop hl
	pop af
	ret

.auto:
	ldh a, [hROMBank]
	push af
	ld a, [wAutoInputBank]
	rst Bankswitch

	ld hl, wAutoInputAddress
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, [wAutoInputLength]
	and a
	jr z, .updateauto
	dec a
	ld [wAutoInputLength], a
	pop af
	rst Bankswitch
	jr .quit

.updateauto:
	ld a, [hli]
	cp -1
	jr z, .stopauto
	ld b, a

	ld a, [hli]
	ld [wAutoInputLength], a
IF !DEF(_JAPANESE)
	; JP Rev 0 / Rev A omit the indefinite-duration $ff special case.
	cp -1
	jr nz, .next
	dec hl
	dec hl
	ld b, NO_INPUT
	jr .finishauto
ENDC

.next:
	ld a, l
	ld [wAutoInputAddress], a
	ld a, h
	ld [wAutoInputAddress + 1], a
	jr .finishauto

.stopauto:
	call StopAutoInput
	ld b, NO_INPUT

.finishauto:
	pop af
	rst Bankswitch
	ld a, b
	ldh [hJoyPressed], a
	ldh [hJoyDown], a
	jr .quit

StartAutoInput::
	ld [wAutoInputBank], a
	ld a, l
	ld [wAutoInputAddress], a
	ld a, h
	ld [wAutoInputAddress + 1], a
	xor a
	ld [wAutoInputLength], a
	xor a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ldh [hJoyDown], a
	ld a, AUTO_INPUT
	ld [wInputType], a
	ret

StopAutoInput::
	xor a
	ld [wAutoInputBank], a
	ld [wAutoInputAddress], a
	ld [wAutoInputAddress + 1], a
	ld [wAutoInputLength], a
	ld [wInputType], a
	ret

JoyTitleScreenInput:: ; unreferenced
.loop:
	call DelayFrame
	push bc
	call JoyTextDelay
	pop bc
	ldh a, [hJoyDown]
	cp PAD_UP | PAD_SELECT | PAD_B
	jr z, .keycombo
	ldh a, [hJoyLast]
	and PAD_START | PAD_A
	jr nz, .keycombo
	dec c
	jr nz, .loop
	and a
	ret
.keycombo:
	scf
	ret

JoyWaitAorB::
.loop:
	call DelayFrame
	call GetJoypad
	ldh a, [hJoyPressed]
	and PAD_A | PAD_B
	ret nz
	call UpdateTimeAndPals
	jr .loop

WaitButton::
	ldh a, [hOAMUpdate]
	push af
	ld a, 1
	ldh [hOAMUpdate], a
	call WaitBGMap
	call JoyWaitAorB
	pop af
	ldh [hOAMUpdate], a
	ret

JoyTextDelay::
	call GetJoypad
	ldh a, [hInMenu]
	and a
	ldh a, [hJoyPressed]
	jr z, .ok
	ldh a, [hJoyDown]
.ok:
	ldh [hJoyLast], a
	ldh a, [hJoyPressed]
	and a
	jr z, .checkframedelay
	ld a, 15
	ld [wTextDelayFrames], a
	ret
.checkframedelay:
	ld a, [wTextDelayFrames]
	and a
	jr z, .restartframedelay
	xor a
	ldh [hJoyLast], a
	ret
.restartframedelay:
	ld a, 5
	ld [wTextDelayFrames], a
	ret

WaitPressAorB_BlinkCursor::
	ldh a, [hMapObjectIndex]
	push af
	ldh a, [hObjectStructIndex]
	push af
	xor a
	ldh [hMapObjectIndex], a
	ld a, 6
	ldh [hObjectStructIndex], a
.loop:
	push hl
	hlcoord 18, 17
	call BlinkCursor
	pop hl
	call JoyTextDelay
	ldh a, [hJoyLast]
	and PAD_A | PAD_B
	jr z, .loop
	pop af
	ldh [hObjectStructIndex], a
	pop af
	ldh [hMapObjectIndex], a
	ret

SimpleWaitPressAorB::
.loop:
	call JoyTextDelay
	ldh a, [hJoyLast]
	and PAD_A | PAD_B
	jr z, .loop
	ret

PromptButton::
	ld a, [wLinkMode]
	and a
	jr nz, .link
	call .wait_input
	push de
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	pop de
	ret
.link:
	ld c, 65
	jp DelayFrames
.wait_input:
	ldh a, [hOAMUpdate]
	push af
	ld a, 1
	ldh [hOAMUpdate], a
IF !DEF(_JAPANESE)
	; JP Rev 0 / Rev A omit this catching-tutorial auto-input dispatch.
	ld a, [wInputType]
	or a
	jr z, .input_wait_loop
	farcall _DudeAutoInput_A
ENDC
.input_wait_loop:
	call .blink_cursor
	call JoyTextDelay
	ldh a, [hJoyPressed]
	and PAD_A | PAD_B
	jr nz, .received_input
	call UpdateTimeAndPals
	ld a, 1
	ldh [hBGMapMode], a
	call DelayFrame
	jr .input_wait_loop
.received_input:
	pop af
	ldh [hOAMUpdate], a
	ret
.blink_cursor:
	ldh a, [hVBlankCounter]
	and 1 << 4
	jr z, .cursor_off
	ld a, '▼'
	jr .load_cursor_state
.cursor_off:
	ld a, '─'
.load_cursor_state:
	ldcoord_a 18, 17
	ret

BlinkCursor::
	push bc
	ld a, [hl]
	ld b, a
	ld a, '▼'
	cp b
	pop bc
	jr nz, .place_arrow
	ldh a, [hMapObjectIndex]
	dec a
	ldh [hMapObjectIndex], a
	ret nz
	ldh a, [hObjectStructIndex]
	dec a
	ldh [hObjectStructIndex], a
	ret nz
	ld a, '─'
	ld [hl], a
	ld a, -1
	ldh [hMapObjectIndex], a
	ld a, 6
	ldh [hObjectStructIndex], a
	ret
.place_arrow:
	ldh a, [hMapObjectIndex]
	and a
	ret z
	dec a
	ldh [hMapObjectIndex], a
	ret nz
	dec a
	ldh [hMapObjectIndex], a
	ldh a, [hObjectStructIndex]
	dec a
	ldh [hObjectStructIndex], a
	ret nz
	ld a, 6
	ldh [hObjectStructIndex], a
	ld a, '▼'
	ld [hl], a
	ret
