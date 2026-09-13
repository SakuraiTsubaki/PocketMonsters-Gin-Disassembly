PrintNum::
; Print c digits of the b-byte value from de to hl.
; JP omits decimal-position/money handling. KR/FR/ES append the currency
; glyph; US/DE/IT use the original leading/floating currency behavior.
	push bc

IF !DEF(_JAPANESE) && !DEF(_KOREAN) && !DEF(_FRENCH) && !DEF(_SPANISH)
	bit PRINTNUM_MONEY_F, b
	jr z, .main
	bit PRINTNUM_LEADINGZEROS_F, b
	jr nz, .moneyflag
	bit PRINTNUM_LEFTALIGN_F, b
	jr z, .main
.moneyflag
	ld a, $f0
	ld [hli], a
	res PRINTNUM_MONEY_F, b
.main
ENDC

	xor a
	ldh [hPrintNumBuffer + 0], a
	ldh [hPrintNumBuffer + 1], a
	ldh [hPrintNumBuffer + 2], a
	ld a, b
	and $f
	cp 1
	jr z, .byte
	cp 2
	jr z, .word
	ld a, [de]
	ldh [hPrintNumBuffer + 1], a
	inc de
	ld a, [de]
	ldh [hPrintNumBuffer + 2], a
	inc de
	ld a, [de]
	ldh [hPrintNumBuffer + 3], a
	jr .start
.word
	ld a, [de]
	ldh [hPrintNumBuffer + 2], a
	inc de
	ld a, [de]
	ldh [hPrintNumBuffer + 3], a
	jr .start
.byte
	ld a, [de]
	ldh [hPrintNumBuffer + 3], a

.start
	push de
	ld d, b
IF DEF(_JAPANESE)
	ld a, c
	ld b, a
	xor a
	ld c, a
ELSE
	ld a, c
	swap a
	and $f
	ld e, a
	ld a, c
	and $f
	ld b, a
	ld c, 0
ENDC
	cp 2
	jr z, .two
	cp 3
	jr z, .three
	cp 4
	jr z, .four
	cp 5
	jr z, .five
	cp 6
	jr z, .six

	ld a, HIGH(1000000 >> 8)
	ldh [hPrintNumBuffer + 4], a
	ld a, HIGH(1000000)
	ldh [hPrintNumBuffer + 5], a
	ld a, LOW(1000000)
	ldh [hPrintNumBuffer + 6], a
	call .PrintDigit
	call .AdvancePointer
.six
	ld a, HIGH(100000 >> 8)
	ldh [hPrintNumBuffer + 4], a
	ld a, HIGH(100000)
	ldh [hPrintNumBuffer + 5], a
	ld a, LOW(100000)
	ldh [hPrintNumBuffer + 6], a
	call .PrintDigit
	call .AdvancePointer
.five
	xor a
	ldh [hPrintNumBuffer + 4], a
	ld a, HIGH(10000)
	ldh [hPrintNumBuffer + 5], a
	ld a, LOW(10000)
	ldh [hPrintNumBuffer + 6], a
	call .PrintDigit
	call .AdvancePointer
.four
	xor a
	ldh [hPrintNumBuffer + 4], a
	ld a, HIGH(1000)
	ldh [hPrintNumBuffer + 5], a
	ld a, LOW(1000)
	ldh [hPrintNumBuffer + 6], a
	call .PrintDigit
	call .AdvancePointer
.three
	xor a
	ldh [hPrintNumBuffer + 4], a
	xor a
	ldh [hPrintNumBuffer + 5], a
	ld a, LOW(100)
	ldh [hPrintNumBuffer + 6], a
	call .PrintDigit
	call .AdvancePointer
.two
IF !DEF(_JAPANESE)
	dec e
	jr nz, .two_skip
	ld a, $f6
	ldh [hPrintNumBuffer + 0], a
.two_skip
ENDC
	ld c, 0
	ldh a, [hPrintNumBuffer + 3]
.mod_10
	cp 10
	jr c, .modded_10
	sub 10
	inc c
	jr .mod_10
.modded_10
	ld b, a
	ldh a, [hPrintNumBuffer + 0]
	or c
IF DEF(_JAPANESE)
	ldh [hPrintNumBuffer + 0], a
	jr nz, .print_tens
	call .PrintLeadingZero
	jr .print_ones
.print_tens
	ld a, $f6
	add c
	ld [hl], a
.print_ones
	call .AdvancePointer
	ld a, $f6
	add b
	ld [hli], a
ELSE
	ldh [hPrintNumBuffer + 0], a
	jr nz, .money
	call .PrintLeadingZero
	jr .money_leading_zero
.money
IF !DEF(_KOREAN) && !DEF(_FRENCH) && !DEF(_SPANISH)
	call .PrintCurrency
ENDC
	ld a, $f6
	add c
	ld [hl], a
	inc e
	dec e
	jr nz, .money_leading_zero
	inc hl
	ld [hl], '.'
.money_leading_zero
	call .AdvancePointer
IF !DEF(_KOREAN) && !DEF(_FRENCH) && !DEF(_SPANISH)
	call .PrintCurrency
ENDC
	ld a, $f6
	add b
	ld [hli], a
IF DEF(_KOREAN) || DEF(_FRENCH) || DEF(_SPANISH)
	bit PRINTNUM_MONEY_F, d
	jr z, .stop
	ld a, $f0
	ld [hli], a
.stop
ENDC
ENDC
	pop de
	pop bc
	ret

IF !DEF(_JAPANESE) && !DEF(_KOREAN) && !DEF(_FRENCH) && !DEF(_SPANISH)
.PrintCurrency
	push af
	ldh a, [hPrintNumBuffer + 0]
	and a
	jr nz, .currency_done
	bit PRINTNUM_MONEY_F, d
	jr z, .currency_done
	ld a, $f0
	ld [hli], a
	res PRINTNUM_MONEY_F, d
.currency_done
	pop af
	ret
ENDC

.PrintDigit
IF !DEF(_JAPANESE)
	dec e
	jr nz, .digit_ok
	ld a, $f6
	ldh [hPrintNumBuffer + 0], a
.digit_ok
ENDC
	ld c, 0
.loop
	ldh a, [hPrintNumBuffer + 4]
	ld b, a
	ldh a, [hPrintNumBuffer + 1]
	ldh [hPrintNumBuffer + 7], a
	cp b
	jr c, .skip1
	sub b
	ldh [hPrintNumBuffer + 1], a
	ldh a, [hPrintNumBuffer + 5]
	ld b, a
	ldh a, [hPrintNumBuffer + 2]
	ldh [hPrintNumBuffer + 8], a
	cp b
	jr nc, .skip2
	ldh a, [hPrintNumBuffer + 1]
	or 0
	jr z, .skip3
	dec a
	ldh [hPrintNumBuffer + 1], a
	ldh a, [hPrintNumBuffer + 2]
.skip2
	sub b
	ldh [hPrintNumBuffer + 2], a
	ldh a, [hPrintNumBuffer + 6]
	ld b, a
	ldh a, [hPrintNumBuffer + 3]
	ldh [hPrintNumBuffer + 9], a
	cp b
	jr nc, .skip4
	ldh a, [hPrintNumBuffer + 2]
	and a
	jr nz, .skip5
	ldh a, [hPrintNumBuffer + 1]
	and a
	jr z, .skip6
	dec a
	ldh [hPrintNumBuffer + 1], a
	xor a
.skip5
	dec a
	ldh [hPrintNumBuffer + 2], a
	ldh a, [hPrintNumBuffer + 3]
.skip4
	sub b
	ldh [hPrintNumBuffer + 3], a
	inc c
	jr .loop
.skip6
	ldh a, [hPrintNumBuffer + 8]
	ldh [hPrintNumBuffer + 2], a
.skip3
	ldh a, [hPrintNumBuffer + 7]
	ldh [hPrintNumBuffer + 1], a
.skip1
	ldh a, [hPrintNumBuffer + 0]
	or c
	jr z, .PrintLeadingZero
IF !DEF(_JAPANESE) && !DEF(_KOREAN) && !DEF(_FRENCH) && !DEF(_SPANISH)
	ldh a, [hPrintNumBuffer + 0]
	and a
	jr nz, .digit_done
	bit PRINTNUM_MONEY_F, d
	jr z, .digit_done
	ld a, $f0
	ld [hli], a
	res PRINTNUM_MONEY_F, d
.digit_done
ENDC
	ld a, $f6
	add c
	ld [hl], a
	ldh [hPrintNumBuffer + 0], a
IF !DEF(_JAPANESE)
	inc e
	dec e
	ret nz
	inc hl
	ld [hl], '.'
ENDC
	ret

.PrintLeadingZero
	bit PRINTNUM_LEADINGZEROS_F, d
	ret z
	ld [hl], $f6
	ret

.AdvancePointer
	bit PRINTNUM_LEADINGZEROS_F, d
	jr nz, .inc
	bit PRINTNUM_LEFTALIGN_F, d
	jr z, .inc
	ldh a, [hPrintNumBuffer + 0]
	and a
	ret z
.inc
	inc hl
	ret

IF !DEF(_GERMAN) && !DEF(_FRENCH) && !DEF(_ITALIAN) && !DEF(_SPANISH)
PrintHexNumber::
.loop
	push bc
	call .HandleByte
	pop bc
	dec c
	jr nz, .loop
	ret
.HandleByte
	ld a, [de]
	swap a
	and $f
	call .PrintDigit
	ld [hli], a
	ld a, [de]
	and $f
	call .PrintDigit
	ld [hli], a
	inc de
	ret
.PrintDigit
	ld bc, .HexDigits
	add c
	ld c, a
	ld a, 0
	adc b
	ld b, a
	ld a, [bc]
	ret
.HexDigits
IF DEF(_JAPANESE)
	db $f6,$f7,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff,$60,$61,$62,$63,$64,$65
ELSE
	db $f6,$f7,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff,$80,$81,$82,$83,$84,$85
ENDC
ENDC
