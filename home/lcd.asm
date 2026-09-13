; LCD handling.

LCD::
	push af
	ldh a, [hLCDCPointer]
	and a
	jr z, .done

IF DEF(_KOREAN)
; Korean Silver guards the scanline override from running in VBlank.
	ldh a, [rLY]
	cp LY_VBLANK
	jr nc, .done
ENDC

	push hl
IF !DEF(_KOREAN)
	ldh a, [rLY]
ENDC
	ld l, a
	ld h, HIGH(wLYOverrides)
	ld h, [hl]
	ldh a, [hLCDCPointer]
	ld l, a
	ld a, h
	ld h, HIGH(rSCY)
	ld [hl], a
	pop hl

.done
	pop af
	reti

DisableLCD::
; Turn the LCD off.
	ldh a, [rLCDC]
	bit B_LCDC_ENABLE, a
	ret z

	xor a
	ldh [rIF], a
	ldh a, [rIE]
	ld b, a

; Disable VBlank while waiting for a safe LCD-off point.
	res B_IE_VBLANK, a
	ldh [rIE], a

.wait
	ldh a, [rLY]
	cp LY_VBLANK + 1
	jr nz, .wait

	ldh a, [rLCDC]
	and ~LCDC_ON
	ldh [rLCDC], a

	xor a
	ldh [rIF], a
	ld a, b
	ldh [rIE], a
	ret

EnableLCD::
	ldh a, [rLCDC]
	set B_LCDC_ENABLE, a
	ldh [rLCDC], a
	ret
