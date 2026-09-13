SimpleMultiply::
; Return a * c.
	and a
	ret z
	push bc
	ld b, a
	xor a
.loop:
	add c
	dec b
	jr nz, .loop
	pop bc
	ret

SimpleDivide::
; Divide a by c. Return quotient b and remainder a.
	ld b, 0
.loop:
	inc b
	sub c
	jr nc, .loop
	dec b
	add c
	ret

Multiply::
; Multiply hMultiplicand by hMultiplier; result in hProduct.
	push hl
	push bc
	callfar _Multiply
	pop bc
	pop hl
	ret

Divide::
; Divide hDividend length b by hDivisor; result in hQuotient.
	push hl
	push de
	push bc
	homecall _Divide
	pop bc
	pop de
	pop hl
	ret

SubtractAbsolute:: ; unreferenced
; Return |a - b|, sign in carry.
	sub b
	ret nc
	cpl
	add 1
	scf
	ret
