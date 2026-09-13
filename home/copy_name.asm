CopyName1::
; Copy the name from de to wStringBuffer2.
	ld hl, wStringBuffer2

CopyName2::
; Copy the name from de to hl.
.loop:
	ld a, [de]
	inc de
	ld [hli], a
	cp '@'
	jr nz, .loop
	ret
