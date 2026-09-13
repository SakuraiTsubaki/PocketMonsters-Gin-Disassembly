; Functions dealing with palettes.

UpdatePalsIfCGB::
	ldh a, [hCGB]
	and a
	ret z

UpdateCGBPals::
	ldh a, [hCGBPalUpdate]
	and a
	ret z
	ld hl, wBGPals2
	ld a, BGPI_AUTOINC
	ldh [rBGPI], a
	ld c, 8 / 2
.bgp
rept (1 palettes) * 2
	ld a, [hli]
	ldh [rBGPD], a
endr
	dec c
	jr nz, .bgp
	ld a, OBPI_AUTOINC
	ldh [rOBPI], a
	ld c, 8 / 2
.obp
rept (1 palettes) * 2
	ld a, [hli]
	ldh [rOBPD], a
endr
	dec c
	jr nz, .obp
	xor a
	ldh [hCGBPalUpdate], a
	scf
	ret

DmgToCgbBGPals::
	ldh [rBGP], a
	push af
	ldh a, [hCGB]
	and a
	jr z, .end
	push hl
	push de
	push bc
	ld hl, wBGPals2
	ld de, wBGPals1
	ldh a, [rBGP]
	ld b, a
	ld c, 8
	call CopyPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	pop bc
	pop de
	pop hl
.end
	pop af
	ret

DmgToCgbObjPals::
	ld a, e
	ldh [rOBP0], a
	ld a, d
	ldh [rOBP1], a
	ldh a, [hCGB]
	and a
	ret z
	push hl
	push de
	push bc
	ld hl, wOBPals2
	ld de, wOBPals1
	ldh a, [rOBP0]
	ld b, a
	ld c, 8
	call CopyPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	pop bc
	pop de
	pop hl
	ret

DmgToCgbObjPal0::
	ldh [rOBP0], a
	push af
	ldh a, [hCGB]
	and a
	jr z, .dmg
	push hl
	push de
	push bc
	ld hl, wOBPals2 palette 0
	ld de, wOBPals1 palette 0
	ldh a, [rOBP0]
	ld b, a
	ld c, 1
	call CopyPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	pop bc
	pop de
	pop hl
.dmg
	pop af
	ret

DmgToCgbObjPal1::
	ldh [rOBP1], a
	push af
	ldh a, [hCGB]
	and a
	jr z, .dmg
	push hl
	push de
	push bc
	ld hl, wOBPals2 palette 1
	ld de, wOBPals1 palette 1
	ldh a, [rOBP1]
	ld b, a
	ld c, 1
	call CopyPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	pop bc
	pop de
	pop hl
.dmg
	pop af
	ret

CopyPals::
	push bc
	ld c, PAL_COLORS
.loop
	push de
	push hl
	ld a, b
	maskbits 1 << COLOR_SIZE
	add a
	ld l, a
	ld h, 0
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
rept COLOR_SIZE
	srl b
endr
	pop de
	dec c
	jr nz, .loop
	ld a, PAL_SIZE
	add e
	jr nc, .ok
	inc d
.ok
	ld e, a
	pop bc
	dec c
	jr nz, CopyPals
	ret

ClearVBank1::
	ldh a, [hCGB]
	and a
	ret z
	ld a, 1
	ldh [rVBK], a
	ld hl, STARTOF(VRAM)
	ld bc, SIZEOF(VRAM)
	xor a
	call ByteFill
	ld a, 0
	ldh [rVBK], a
	ret

ReloadPalettes::
	hlcoord 0, 0
	decoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
.loop
IF DEF(_KOREAN)
	ld a, [de]
	bit B_BG_BANK1, a
	jr z, .bg_bank0
	ld a, BG_BANK1 | PAL_BG_TEXT
	ld [de], a
	inc hl
	jr .skip
.bg_bank0
ENDC
	ld a, [hli]
	cp '■'
	jr c, .skip
	ld a, PAL_BG_TEXT
	ld [de], a
.skip
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

ReloadSpritesNoPalettes::
	ldh a, [hCGB]
	and a
	ret z
	ld hl, wBGPals2
	ld bc, (8 palettes) + (2 palettes)
	xor a
	call ByteFill
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	call DelayFrame
	ret

LoadOverworldAttrmapPals::
	homecall _LoadOverworldAttrmapPals
	ret

ScrollBGMapPalettes::
	homecall _ScrollBGMapPalettes
	ret
