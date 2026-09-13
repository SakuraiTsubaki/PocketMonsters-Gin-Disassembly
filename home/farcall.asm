FarCall_hl::
; Call a:hl while preserving the working bank and other registers.
	ld [wTempBank], a
	ldh a, [hROMBank]
	push af
	ld a, [wTempBank]
	rst Bankswitch
	call FarCall_JumpToHL

	ld a, b
	ld [wFarCallBC], a
	ld a, c
	ld [wFarCallBC + 1], a

	pop bc
	ld a, b
	rst Bankswitch

	ld a, [wFarCallBC]
	ld b, a
	ld a, [wFarCallBC + 1]
	ld c, a
	ret

FarCall_JumpToHL::
	jp hl
