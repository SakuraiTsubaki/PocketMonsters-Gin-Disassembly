PrintLetterDelay::
; Wait before printing the next letter.
	ld a, [wOptions]
	bit NO_TEXT_SCROLL, a
	ret nz
	ld a, [wTextboxFlags]
	bit TEXT_DELAY_F, a
	ret z
	push hl
	push de
	push bc
	ld hl, hOAMUpdate
	ld a, [hl]
	push af
	ld [hl], a
	ld a, [wTextboxFlags]
	bit FAST_TEXT_DELAY_F, a
	jr z, .fast
	ld a, [wOptions]
	and %111
	jr .updatedelay
.fast
	ld a, TEXT_DELAY_FAST
.updatedelay
	ld [wTextDelayFrames], a
.checkjoypad
	call GetJoypad
	ld a, [wDisableTextAcceleration]
	and a
	jr nz, .wait
	ldh a, [hJoyDown]
	bit A_BUTTON_F, a
	jr z, .checkb
	jr .delay
.checkb
	bit B_BUTTON_F, a
	jr z, .wait
.delay
	call DelayFrame
	jr .end
.wait
	ld a, [wTextDelayFrames]
	and a
	jr nz, .checkjoypad
.end
	pop af
	ldh [hOAMUpdate], a
	pop bc
	pop de
	pop hl
	ret

CopyDataUntil::
	ld a, [hli]
	ld [de], a
	inc de
	ld a, h
	cp b
	jr nz, CopyDataUntil
	ld a, l
	cp c
	jr nz, CopyDataUntil
	ret

INCLUDE "home/print_num.asm"

FarPrintText::
	ld [wTempBank], a
	ldh a, [hROMBank]
	push af
	ld a, [wTempBank]
	rst Bankswitch
	call PrintText
	pop af
	rst Bankswitch
	ret

CallPointerAt::
	ldh a, [hROMBank]
	push af
	ld a, [hli]
	rst Bankswitch
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call _hl_
	pop hl
	ld a, h
	rst Bankswitch
	ret
