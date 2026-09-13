; System initialization and hardware setup.
; Shared from pret/pokegold with verified Japanese/Korean region branches.

_Start::
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	cp BOOTUP_A_CGB
	jr z, .cgb
	cp BOOTUP_A_DMG
	jr z, .dmg
	cp BOOTUP_A_MGB
	jr z, .mgb
IF DEF(_KOREAN)
	cp BOOTUP_A_AGB
	jr z, .agb
ENDC

.dmg
	ld a, FALSE
	jr .init

.cgb
	ld a, TRUE
	jr .init

.mgb
	ld a, 2
	jr .init
IF DEF(_KOREAN)

.agb
	ld a, 3
ENDC

.init
	ldh [hCGB], a

; Clear WRAM0.
	xor a
	ld hl, STARTOF(WRAM0)
	ld bc, SIZEOF(WRAM0)
	call ByteFill

; Clear HRAM.
IF DEF(_KOREAN)
	ld hl, STARTOF(HRAM)
	ld bc, SIZEOF(HRAM)
	call ByteFill
ELSE
	ld [hMapAnims], a
	ld [hSCX], a
	ld [hSCY], a
	ld [hWY], a
	ld [hWX], a
	ld [hJoyDown], a
	ld [hJoyPressed], a
	ld [hJoyLast], a
	ld [hInMenu], a
	ld [hVBlank], a
	ld [hROMBank], a
	ld [hBGMapMode], a
	ld [hBGMapThird], a
	ld [hBGMapAddress], a
	ld [hOAMUpdate], a
	ld [hSPBuffer], a
	ld [hSPBuffer + 1], a
	ld [hBGMapUpdate], a
	ld [hBGMapTileCount], a
	ld [hMapObjectIndexBuffer], a
	ld [hObjectStructIndexBuffer], a
	ld [hConnectionStripLength], a
	ld [hConnectedMapWidth], a
	ld [hEnemyMonSpeed], a
	ld [hMultiplicand], a
	ld [hMultiplicand + 1], a
	ld [hMultiplicand + 2], a
	ld [hMultiplier], a
	ld [hProduct], a
	ld [hProduct + 1], a
	ld [hProduct + 2], a
	ld [hProduct + 3], a
	ld [hDividend], a
	ld [hDividend + 1], a
	ld [hDividend + 2], a
	ld [hDividend + 3], a
	ld [hDivisor], a
	ld [hQuotient], a
	ld [hQuotient + 1], a
	ld [hQuotient + 2], a
	ld [hQuotient + 3], a
	ld [hPrintNumBuffer], a
	ld [hPrintNumBuffer + 1], a
	ld [hPrintNumBuffer + 2], a
	ld [hPrintNumBuffer + 3], a
	ld [hPrintNumBuffer + 4], a
	ld [hPrintNumBuffer + 5], a
	ld [hPrintNumBuffer + 6], a
	ld [hPrintNumBuffer + 7], a
	ld [hPrintNumBuffer + 8], a
	ld [hPrintNumBuffer + 9], a
	ld [hPrintNumBuffer + 10], a
	ld [hPrintNumBuffer + 11], a
	ld [hMGStatusFlags], a
	ld [hUsedSpriteIndex], a
	ld [hUsedSpriteTile], a
	ld [hCurSpriteXCoord], a
	ld [hCurSpriteYCoord], a
	ld [hCurSpriteXPixel], a
	ld [hCurSpriteYPixel], a
	ld [hCurSpriteTile], a
	ld [hCurSpriteOAMFlags], a
	ld [hMoneyTemp], a
	ld [hMoneyTemp + 1], a
	ld [hMoneyTemp + 2], a
	ld [hCoinsTemp], a
	ld [hCoinsTemp + 1], a
	ld [hRGB], a
	ld [hRGB + 1], a
	ld [hRGB + 2], a
	ld [hRGB + 3], a
	ld [hObjectStructIndex], a
	ld [hTextBoxFlags], a
	ld [hRequestContents], a
	ld [hRequestContents + 1], a
	ld [hRequested2bppSource], a
	ld [hRequested2bppSource + 1], a
	ld [hRequested2bppSize], a
	ld [hRequested2bppDest], a
	ld [hRequested2bppDest + 1], a
	ld [hRequested1bppSource], a
	ld [hRequested1bppSource + 1], a
	ld [hRequested1bppSize], a
	ld [hRequested1bppDest], a
	ld [hRequested1bppDest + 1], a
	ld [hLCDCPointer], a
	ld [hLCDCPointer + 1], a
	ld [hLYOverrideStart], a
	ld [hLYOverrideEnd], a
ENDC

; Disable LCD.
	ldh [rLCDC], a

; Clear VRAM.
	call ClearVRAM

; Clear OAM.
	ld hl, STARTOF(OAM)
	ld bc, SIZEOF(OAM)
	xor a
	call ByteFill

; Initialize stack.
	ld hl, wStackTop
	ld sp, hl

; Set palettes.
	ld a, %11100100
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a

; Set LCDC.
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a

; Initialize interrupt flags.
	xor a
	ldh [rIF], a
	ld a, 1 << VBLANK
	ldh [rIE], a
	ei

	call DelayFrame
	predef InitSGBBorder
	call InitSound
	xor a
	ld [wMapMusic], a
	jp GameInit

ClearVRAM::
	ld hl, STARTOF(VRAM)
	ld bc, SIZEOF(VRAM)
	xor a
	call ByteFill
	ret

IF !DEF(_KOREAN)
BlankBGMap::
IF DEF(_JAPANESE)
	ld a, '　'
ELSE
	ld a, ' '
ENDC
	jr FillBGMap

FillBGMap_l:: ; unreferenced
	ld a, l

FillBGMap::
	ld de, vBGMap1 - vBGMap0
	ld l, e
.loop:
	ld [hli], a
	dec e
	jr nz, .loop
	dec d
	jr nz, .loop
	ret
ENDC
