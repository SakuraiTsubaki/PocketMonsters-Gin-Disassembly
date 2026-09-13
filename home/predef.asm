Predef::
; Call predefined function a. Preserves bc, de, hl and f.
	ld [wPredefID], a
	ldh a, [hROMBank]
	push af

	ld a, BANK(GetPredefPointer)
	rst Bankswitch
	call GetPredefPointer
	rst Bankswitch

	ld hl, .Return
	push hl

	ld a, [wPredefAddress]
	ld h, a
	ld a, [wPredefAddress + 1]
	ld l, a
	push hl

	ld a, [wPredefHL]
	ld h, a
	ld a, [wPredefHL + 1]
	ld l, a
	ret

.Return:
	ld a, h
	ld [wPredefHL], a
	ld a, l
	ld [wPredefHL + 1], a

	pop hl
	ld a, h
	rst Bankswitch

	ld a, [wPredefHL]
	ld h, a
	ld a, [wPredefHL + 1]
	ld l, a
	ret
