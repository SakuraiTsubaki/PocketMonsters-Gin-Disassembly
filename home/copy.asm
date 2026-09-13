CopyBytes::
; Copy bc bytes from hl to de.
	inc b
	inc c
	jr .HandleLoop
.CopyByte:
	ld a, [hli]
	ld [de], a
	inc de
.HandleLoop:
	dec c
	jr nz, .CopyByte
	dec b
	jr nz, .CopyByte
	ret

GetFarByte::
; Retrieve one byte from a:hl and return it in a.
	ld [wTempBank], a
	ldh a, [hROMBank]
	push af
	ld a, [wTempBank]
	rst Bankswitch

	ld a, [hl]
	ld [wFarByte], a

	pop af
	rst Bankswitch
	ld a, [wFarByte]
	ret

GetFarWord::
; Retrieve a little-endian word from a:hl and return it in hl.
	ld [wTempBank], a
	ldh a, [hROMBank]
	push af
	ld a, [wTempBank]
	rst Bankswitch

	ld a, [hli]
	ld h, [hl]
	ld l, a

	pop af
	rst Bankswitch
	ret

ByteFill::
; Fill bc bytes with a, starting at hl.
	inc b
	inc c
	jr .HandleLoop
.PutByte:
	ld [hli], a
.HandleLoop:
	dec c
	jr nz, .PutByte
	dec b
	jr nz, .PutByte
	ret
