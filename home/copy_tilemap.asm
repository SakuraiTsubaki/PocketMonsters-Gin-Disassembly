LoadTilemapToTempTilemap::
; Load wTilemap into wTempTilemap.
IF DEF(_KOREAN)
	farcall _LoadTilemapToTempTilemap
	ret
ELSE
	hlcoord 0, 0
	decoord 0, 0, wTempTilemap
	ld bc, wTilemapEnd - wTilemap
	jp CopyBytes
ENDC

SafeLoadTempTilemapToTilemap::
	xor a
	ldh [hBGMapMode], a
	call LoadTempTilemapToTilemap
	ld a, 1
	ldh [hBGMapMode], a
	ret

LoadTempTilemapToTilemap::
; Load wTempTilemap into wTilemap.
IF DEF(_KOREAN)
	farcall _LoadTempTilemapToTilemap
	ret
ELSE
	hlcoord 0, 0, wTempTilemap
	decoord 0, 0
	ld bc, wTilemapEnd - wTilemap
	jp CopyBytes
ENDC
