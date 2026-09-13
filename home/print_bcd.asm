PrintBCDNumber::
	ld b, c
	res PRINTNUM_LEADINGZEROS_F, c
	res PRINTNUM_LEFTALIGN_F, c
IF !DEF(_JAPANESE)
	res PRINTNUM_MONEY_F, c
ENDC
IF !DEF(_JAPANESE) && !DEF(_KOREAN) && !DEF(_FRENCH) && !DEF(_SPANISH)
	bit PRINTNUM_MONEY_F, b
	jr z, .loop
	bit PRINTNUM_LEADINGZEROS_F, b
	jr nz, .loop
	ld [hl], $f0
	inc hl
ENDC
.loop
	ld a, [de]
	swap a
	call PrintBCDDigit
	ld a, [de]
	call PrintBCDDigit
	inc de
	dec c
	jr nz, .loop
	bit PRINTNUM_LEADINGZEROS_F, b
	jr z, .done
	bit PRINTNUM_LEFTALIGN_F, b
	jr nz, .skipLeftAlignmentAdjustment
	dec hl
.skipLeftAlignmentAdjustment
IF !DEF(_JAPANESE) && !DEF(_KOREAN) && !DEF(_FRENCH) && !DEF(_SPANISH)
	bit PRINTNUM_MONEY_F, b
	jr z, .skipCurrencySymbol
	ld [hl], $f0
	inc hl
.skipCurrencySymbol
ENDC
	ld [hl], $f6
	call PrintLetterDelay
	inc hl
.done
IF DEF(_KOREAN) || DEF(_FRENCH) || DEF(_SPANISH)
	ld a, $f0
	ld [hli], a
ENDC
	ret

PrintBCDDigit::
	and %00001111
	and a
	jr z, .zeroDigit
IF !DEF(_JAPANESE) && !DEF(_KOREAN) && !DEF(_FRENCH) && !DEF(_SPANISH)
	bit PRINTNUM_LEADINGZEROS_F, b
	jr z, .outputDigit
	bit PRINTNUM_MONEY_F, b
	jr z, .skipCurrencySymbol
	ld [hl], $f0
	inc hl
	res PRINTNUM_MONEY_F, b
.skipCurrencySymbol
ENDC
	res PRINTNUM_LEADINGZEROS_F, b
.outputDigit
	add $f6
	ld [hli], a
	jp PrintLetterDelay
.zeroDigit
	bit PRINTNUM_LEADINGZEROS_F, b
	jr z, .outputDigit
	bit PRINTNUM_LEFTALIGN_F, b
	ret nz
	ld a, $7f
	ld [hli], a
	ret
