DrawBattleHPBar::
	push hl
	push de
	push bc
	ld a, $60
	ld [hli], a
	ld a, $61
	ld [hli], a
	push hl
	ld a, $62
.template
	ld [hli], a
	dec d
	jr nz, .template
	ld a, $6b
	add b
	ld [hl], a
	pop hl
	ld a, e
	and a
	jr nz, .fill
	ld a, c
	and a
	jr z, .done
	ld e, 1
.fill
	ld a, e
	sub TILE_WIDTH
	jr c, .lastbar
	ld e, a
	ld a, $6a
	ld [hli], a
	ld a, e
	and a
	jr z, .done
	jr .fill
.lastbar
	ld a, $62
	add e
	ld [hl], a
.done
	pop bc
	pop de
	pop hl
	ret

PrepMonFrontpic::
	ld a, $1
	ld [wBoxAlignment], a

_PrepMonFrontpic::
	ld a, [wCurPartySpecies]
	and a
	jr z, .not_pokemon
	cp EGG
	jr z, .egg
	cp NUM_POKEMON + 1
	jr nc, .not_pokemon
.egg
	push hl
	ld de, vTiles2
	predef GetMonFrontpic
	pop hl
	xor a
	ldh [hGraphicStartTile], a
	lb bc, 7, 7
	predef PlaceGraphic
	xor a
	ld [wBoxAlignment], a
	ret
.not_pokemon
	xor a
	ld [wBoxAlignment], a
	inc a
	ld [wCurPartySpecies], a
	ret

PlayStereoCry::
	push af
	ld a, 1
	ld [wStereoPanningMask], a
	pop af
	jr _PlayMonCry

PlayMonCry::
	push af
	xor a
	ld [wStereoPanningMask], a
	ld [wCryTracks], a
	pop af

_PlayMonCry::
	push hl
	push de
	push bc
	call GetCryIndex
	jr c, .done
	ld e, c
	ld d, b
	call PlayCry
	call WaitSFX
.done
	pop bc
	pop de
	pop hl
	ret

LoadCry::
	call GetCryIndex
	ret c
	ldh a, [hROMBank]
	push af
	ld a, BANK(PokemonCries)
	rst Bankswitch
	ld hl, PokemonCries
rept MON_CRY_LENGTH
	add hl, bc
endr
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [hli]
	ld [wCryPitch], a
	ld a, [hli]
	ld [wCryPitch + 1], a
	ld a, [hli]
	ld [wCryLength], a
	ld a, [hl]
	ld [wCryLength + 1], a
	pop af
	rst Bankswitch
	and a
	ret

GetCryIndex::
	and a
	jr z, .no
	cp NUM_POKEMON + 1
	jr nc, .no
	dec a
	ld c, a
	ld b, 0
	and a
	ret
.no
	scf
	ret

PrintLevel::
	ld a, [wTempMonLevel]
	ld [hl], '<LV>'
	inc hl
	ld c, 2
	cp 100
	jr c, Print8BitNumLeftAlign
	dec hl
	inc c
	jr Print8BitNumLeftAlign

PrintLevel_Force3Digits::
	ld [hl], '<LV>'
	inc hl
	ld c, 3

Print8BitNumLeftAlign::
	ld [wTextDecimalByte], a
	ld de, wTextDecimalByte
	ld b, PRINTNUM_LEFTALIGN | 1
	jp PrintNum

GetNthMove::
	ld hl, wListMoves_MoveIndicesBuffer
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	ret

GetBaseData::
	push bc
	push de
	push hl
	ldh a, [hROMBank]
	push af
	ld a, BANK(BaseData)
	rst Bankswitch
	ld a, [wCurSpecies]
	cp EGG
	jr z, .egg
	dec a
	ld bc, BASE_DATA_SIZE
	ld hl, BaseData
	call AddNTimes
	ld de, wCurBaseData
	ld bc, BASE_DATA_SIZE
	call CopyBytes
	jr .end
.egg
	ld de, EggPic
	ld b, $55
	ld hl, wBasePicSize
	ld [hl], b
	ld hl, wBaseUnusedFrontpic
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	ld [hl], e
	inc hl
	ld [hl], d
	jr .end
.end
	ld a, [wCurSpecies]
	ld [wBaseDexNo], a
	pop af
	rst Bankswitch
	pop hl
	pop de
	pop bc
	ret

GetCurNickname::
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames

GetNickname::
	push hl
	push bc
	call SkipNames
	ld de, wStringBuffer1
	push de
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	pop de
	callfar CorrectNickErrors
	pop bc
	pop hl
	ret
