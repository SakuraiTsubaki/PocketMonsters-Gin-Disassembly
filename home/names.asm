NamesPointers::
	table_width 3
	dba PokemonNames
	dba MoveNames
	dba NULL
	dba ItemNames
	dbw 0, wPartyMonOTs
	dbw 0, wOTPartyMonOTs
	dba TrainerClassNames
	dbw 4, MoveDescriptions
	assert_table_length NUM_NAME_TYPES

GetName::
	ldh a, [hROMBank]
	push af
	push hl
	push bc
	push de
	ld a, [wNamedObjectType]
	cp MON_NAME
	jr nz, .NotPokeName
	ld a, [wCurSpecies]
	ld [wNamedObjectIndex], a
	call GetPokemonName
IF DEF(_JAPANESE)
	ld hl, NAME_LENGTH
ELSE
	ld hl, MON_NAME_LENGTH
ENDC
	add hl, de
	ld e, l
	ld d, h
	jr .done
.NotPokeName
	ld a, [wNamedObjectType]
	dec a
	ld e, a
	ld d, 0
	ld hl, NamesPointers
	add hl, de
	add hl, de
	add hl, de
	ld a, [hli]
	rst Bankswitch
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wCurSpecies]
	dec a
	call GetNthString
	ld de, wStringBuffer1
IF DEF(_JAPANESE) || DEF(_KOREAN)
	ld bc, STRING_BUFFER_LENGTH
ELSE
	ld bc, ITEM_NAME_LENGTH
ENDC
	call CopyBytes
.done
	ld a, e
	ld [wUnusedNamesPointer], a
	ld a, d
	ld [wUnusedNamesPointer + 1], a
	pop de
	pop bc
	pop hl
	pop af
	rst Bankswitch
	ret

GetNthString::
	and a
	ret z
	push bc
	ld b, a
	ld c, '@'
.readChar
	ld a, [hli]
	cp c
	jr nz, .readChar
	dec b
	jr nz, .readChar
	pop bc
	ret

GetBasePokemonName::
	push hl
	call GetPokemonName
	ld hl, wStringBuffer1
.loop
	ld a, [hl]
IF DEF(_KOREAN)
	cp $c
	jr nc, .single_byte
	inc hl
	inc hl
	jr .loop
.single_byte
ENDC
	cp '@'
	jr z, .quit
	cp '♂'
	jr z, .end
	cp '♀'
	jr z, .end
	inc hl
	jr .loop
.end
	ld [hl], '@'
.quit
	pop hl
	ret

GetPokemonName::
	ldh a, [hROMBank]
	push af
	push hl
	ld a, BANK(PokemonNames)
	rst Bankswitch
	ld a, [wNamedObjectIndex]
	dec a
	ld hl, PokemonNames
	ld e, a
	ld d, 0
IF DEF(_JAPANESE)
rept NAME_LENGTH - 1
	add hl, de
endr
	ld de, wStringBuffer1
	push de
	ld bc, NAME_LENGTH - 1
	call CopyBytes
	ld hl, wStringBuffer1 + NAME_LENGTH - 1
ELSE
rept MON_NAME_LENGTH - 1
	add hl, de
endr
	ld de, wStringBuffer1
	push de
	ld bc, MON_NAME_LENGTH - 1
	call CopyBytes
	ld hl, wStringBuffer1 + MON_NAME_LENGTH - 1
ENDC
	ld [hl], '@'
	pop de
	pop hl
	pop af
	rst Bankswitch
	ret

GetItemName::
	push hl
	push bc
	ld a, [wNamedObjectIndex]
	cp TM01
	jr nc, .TM
	ld [wCurSpecies], a
	ld a, ITEM_NAME
	ld [wNamedObjectType], a
	call GetName
	jr .Copied
.TM
	call GetTMHMName
.Copied
	ld de, wStringBuffer1
	pop bc
	pop hl
	ret

GetTMHMName::
	push hl
	push de
	push bc
	ld a, [wNamedObjectIndex]
	push af
	cp HM01
	push af
	jr c, .TM
	ld hl, .HMText
	ld bc, .HMTextEnd - .HMText
	jr .copy
.TM
	ld hl, .TMText
	ld bc, .TMTextEnd - .TMText
.copy
	ld de, wStringBuffer1
	call CopyBytes
	push de
	ld a, [wNamedObjectIndex]
	ld c, a
	callfar GetTMHMNumber
	pop de
	pop af
	ld a, c
	jr c, .not_hm
	sub NUM_TMS
.not_hm
	ld b, $f6
.mod10
	sub 10
	jr c, .done_mod
	inc b
	jr .mod10
.done_mod
	add 10
	push af
	ld a, b
	ld [de], a
	inc de
	pop af
	ld b, $f6
	add b
	ld [de], a
	inc de
	ld a, '@'
	ld [de], a
	pop af
	ld [wNamedObjectIndex], a
	pop bc
	pop de
	pop hl
	ret

.TMText
IF DEF(_JAPANESE)
	db $dc, $2b, $9d, $8b, $ab
ELIF DEF(_KOREAN)
	db $01, $b2, $06, $2a, $04, $73, $06, $65
ELIF DEF(_FRENCH)
	db $82, $93
ELIF DEF(_ITALIAN) || DEF(_SPANISH)
	db $8c, $93
ELSE
	db $93, $8c
ENDC
.TMTextEnd
	db '@'

.HMText
IF DEF(_JAPANESE)
	db $cb, $33, $de, $9d, $8b, $ab
ELIF DEF(_KOREAN)
	db $01, $b2, $05, $61, $07, $cc, $04, $73, $06, $65
ELIF DEF(_GERMAN)
	db $95, $8c
ELIF DEF(_FRENCH)
	db $82, $92
ELIF DEF(_ITALIAN)
	db $8c, $8d
ELIF DEF(_SPANISH)
	db $8c, $8e
ELSE
	db $87, $8c
ENDC
.HMTextEnd
	db '@'

INCLUDE "home/hm_moves.asm"

GetMoveName::
	push hl
	ld a, MOVE_NAME
	ld [wNamedObjectType], a
	ld a, [wNamedObjectIndex]
	ld [wCurSpecies], a
	call GetName
	ld de, wStringBuffer1
	pop hl
	ret
