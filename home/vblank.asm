; VBlank is the interrupt responsible for updating VRAM.
; JP Silver differs in the cutscene interrupt path; see the _JAPANESE blocks.

VBlank::
	push af
	push bc
	push de
	push hl

	ldh a, [hVBlank]
	maskbits NUM_VBLANK_HANDLERS

	ld e, a
	ld d, 0
	ld hl, VBlankHandlers
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld de, .return
	push de
	jp hl

.return:
	call GameTimer
	pop hl
	pop de
	pop bc
	pop af
	reti

VBlankHandlers:
	table_width 2
	dw VBlank_Normal
	dw VBlank_Cutscene
	dw VBlank_SoundOnly
	dw VBlank_Unused
	dw VBlank_Serial
	dw VBlank_Credits
	dw VBlank_Normal
	dw VBlank_Normal
	assert_table_length NUM_VBLANK_HANDLERS

VBlank_Normal::
	ld hl, hVBlankCounter
	inc [hl]

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

	ldh a, [hROMBank]
	ld [wROMBankBackup], a

	ldh a, [hSCX]
	ldh [rSCX], a
	ldh a, [hSCY]
	ldh [rSCY], a
	ldh a, [hWY]
	ldh [rWY], a
	ldh a, [hWX]
	ldh [rWX], a

	call UpdateBGMapBuffer
	jr c, .done
	call UpdatePalsIfCGB
	jr c, .done
	call UpdateBGMap

	call Serve2bppRequest
	call Serve1bppRequest
	call AnimateTileset
	call FillBGMap0WithBlack

.done:
	ldh a, [hOAMUpdate]
	and a
	jr nz, .done_oam
	call hTransferShadowOAM
.done_oam:
	xor a
	ld [wVBlankOccurred], a

	ld a, [wOverworldDelay]
	and a
	jr z, .ok
	dec a
	ld [wOverworldDelay], a
.ok:
	ld a, [wTextDelayFrames]
	and a
	jr z, .ok2
	dec a
	ld [wTextDelayFrames], a
.ok2:
	call UpdateJoypad

	ld a, BANK(_UpdateSound)
	rst Bankswitch
	call _UpdateSound
	ld a, [wROMBankBackup]
	rst Bankswitch

	ldh a, [hSeconds]
	ldh [hUnusedBackup], a
	ret

VBlank_Cutscene::
	ldh a, [hROMBank]
	ld [wROMBankBackup], a
	ldh a, [hSCX]
	ldh [rSCX], a
	ldh a, [hSCY]
	ldh [rSCY], a
	call UpdatePals
	jr c, .done

	call UpdateBGMap
	call Serve2bppRequest
	call hTransferShadowOAM

.done:
IF !DEF(_JAPANESE)
	; JP Rev 0 / Rev A omit this cutscene LCD override write.
	ldh a, [hLCDCPointer]
	or a
	jr z, .skip_lcd
	ld c, a
	ld a, [wLYOverrides]
	ldh [c], a
.skip_lcd:
ENDC
	xor a
	ld [wVBlankOccurred], a

	ldh a, [rIF]
	ld b, a
	xor a
	ldh [rIF], a
	ld a, IE_STAT
	ldh [rIE], a
	ld a, b
	and IF_SERIAL
	or IF_STAT
	ldh [rIF], a

	ei
	ld a, BANK(_UpdateSound)
	rst Bankswitch
	call _UpdateSound
	ld a, [wROMBankBackup]
	rst Bankswitch

IF DEF(_JAPANESE)
	; JP preserves pending interrupt requests while restoring IE after sound.
	di
	ldh a, [rIF]
	ld b, a
	xor a
	ldh [rIF], a
	ld a, IE_DEFAULT
	ldh [rIE], a
	ld a, b
	ldh [rIF], a
ELSE
	ld a, IE_DEFAULT
	ldh [rIE], a
ENDC
	ret

UpdatePals::
	ldh a, [hCGB]
	and a
	jp nz, UpdateCGBPals

	ld a, [wBGP]
	ldh [rBGP], a
	ld a, [wOBP0]
	ldh [rOBP0], a
	ld a, [wOBP1]
	ldh [rOBP1], a

	and a
	ret

VBlank_Serial::
	ldh a, [hROMBank]
	ld [wROMBankBackup], a

	call UpdateBGMap
	call Serve2bppRequest
	call hTransferShadowOAM
	call UpdateJoypad

	xor a
	ld [wVBlankOccurred], a
	call AskSerial

	ld a, BANK(_UpdateSound)
	rst Bankswitch
	call _UpdateSound
	ld a, [wROMBankBackup]
	rst Bankswitch
	ret

VBlank_Credits::
	ldh a, [hROMBank]
	ld [wROMBankBackup], a
	ldh a, [hSCX]
	ldh [rSCX], a

	call UpdatePalsIfCGB
	jr c, .done
	call UpdateBGMap
	call Serve2bppRequest
.done:
	xor a
	ld [wVBlankOccurred], a
	call UpdateJoypad

	xor a
	ldh [rIF], a
	ld a, IE_STAT
	ldh [rIE], a
	ldh [rIF], a

	ei
	ld a, BANK(_UpdateSound)
	rst Bankswitch
	call _UpdateSound
	ld a, [wROMBankBackup]
	rst Bankswitch
	di

	xor a
	ldh [rIF], a
	ld a, IE_DEFAULT
	ldh [rIE], a
	ret

VBlank_SoundOnly::
	ldh a, [hROMBank]
	ld [wROMBankBackup], a
	ld a, BANK(_UpdateSound)
	rst Bankswitch
	call _UpdateSound
	ld a, [wROMBankBackup]
	rst Bankswitch
	xor a
	ld [wVBlankOccurred], a
	ret

VBlank_Unused::
	ldh a, [hVBlankCounter]
	inc a
	ldh [hVBlankCounter], a

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

	call UpdateJoypad

	ldh a, [hROMBank]
	ld [wROMBankBackup], a
	ldh a, [hSCX]
	ldh [rSCX], a
	ldh a, [hSCY]
	ldh [rSCY], a
	ldh a, [hWY]
	ldh [rWY], a
	ldh a, [hWX]
	ldh [rWX], a

	call UpdateBGMap
	call UpdateBGMapBuffer
	call Serve2bppRequest
	call Serve1bppRequest
	call AnimateTileset
	call hTransferShadowOAM

	xor a
	ld [wVBlankOccurred], a

	ld a, [wTextDelayFrames]
	and a
	jr z, .okay
	dec a
	ld [wTextDelayFrames], a
.okay:
	xor a
	ldh [rIF], a
	ld a, IE_STAT
	ldh [rIE], a
	assert IE_STAT == IF_STAT
	ldh [rIF], a

	ei
	ld a, BANK(_UpdateSound)
	rst Bankswitch
	call _UpdateSound
	ld a, [wROMBankBackup]
	rst Bankswitch
	di

	xor a
	ldh [rIF], a
	ld a, IE_DEFAULT
	ldh [rIE], a
	ret
