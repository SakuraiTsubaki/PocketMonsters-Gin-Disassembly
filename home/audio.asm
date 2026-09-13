; Audio interfaces. Core code is 671 bytes in every mapped Silver release.

InitSound::
	push hl
	push de
	push bc
	push af
	ldh a, [hROMBank]
	push af
	ld a, BANK(_InitSound)
	ldh [hROMBank], a
	ld [rROMB], a
	call _InitSound
	pop af
	ldh [hROMBank], a
	ld [rROMB], a
	pop af
	pop bc
	pop de
	pop hl
	ret

UpdateSound::
	push hl
	push de
	push bc
	push af
	ldh a, [hROMBank]
	push af
	ld a, BANK(_UpdateSound)
	ldh [hROMBank], a
	ld [rROMB], a
	call _UpdateSound
	pop af
	ldh [hROMBank], a
	ld [rROMB], a
	pop af
	pop bc
	pop de
	pop hl
	ret

_LoadMusicByte::
	ldh [hROMBank], a
	ld [rROMB], a
	ld a, [de]
	ld [wCurMusicByte], a
	ld a, BANK(LoadMusicByte)
	ldh [hROMBank], a
	ld [rROMB], a
	ret

PlayMusic::
	push hl
	push de
	push bc
	push af
	ldh a, [hROMBank]
	push af
	ld a, BANK(_PlayMusic)
	ldh [hROMBank], a
	ld [rROMB], a
	ld a, e
	and a
	jr z, .nomusic
	call _PlayMusic
	jr .end
.nomusic
	call _InitSound
.end
	pop af
	ldh [hROMBank], a
	ld [rROMB], a
	pop af
	pop bc
	pop de
	pop hl
	ret

PlayMusic2::
	push hl
	push de
	push bc
	push af
	ldh a, [hROMBank]
	push af
	ld a, BANK(_PlayMusic)
	ldh [hROMBank], a
	ld [rROMB], a
	push de
	ld de, MUSIC_NONE
	call _PlayMusic
	call DelayFrame
	pop de
	call _PlayMusic
	pop af
	ldh [hROMBank], a
	ld [rROMB], a
	pop af
	pop bc
	pop de
	pop hl
	ret

PlayCry::
	push hl
	push de
	push bc
	push af
	ldh a, [hROMBank]
	push af
	ld a, BANK(PokemonCries)
	ldh [hROMBank], a
	ld [rROMB], a
	ld hl, PokemonCries
rept MON_CRY_LENGTH
	add hl, de
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
	ld a, BANK(_PlayCry)
	ldh [hROMBank], a
	ld [rROMB], a
	call _PlayCry
	pop af
	ldh [hROMBank], a
	ld [rROMB], a
	pop af
	pop bc
	pop de
	pop hl
	ret

PlaySFX::
	push hl
	push de
	push bc
	push af
	call CheckSFX
	jr nc, .play
	ld a, [wCurSFX]
	cp e
	jr c, .done
.play
	ldh a, [hROMBank]
	push af
	ld a, BANK(_PlaySFX)
	ldh [hROMBank], a
	ld [rROMB], a
	ld a, e
	ld [wCurSFX], a
	call _PlaySFX
	pop af
	ldh [hROMBank], a
	ld [rROMB], a
.done
	pop af
	pop bc
	pop de
	pop hl
	ret

WaitPlaySFX::
	call WaitSFX
	call PlaySFX
	ret

WaitSFX::
	push hl
.wait
	ld hl, wChannel5Flags1
	bit SOUND_CHANNEL_ON, [hl]
	jr nz, .wait
	ld hl, wChannel6Flags1
	bit SOUND_CHANNEL_ON, [hl]
	jr nz, .wait
	ld hl, wChannel7Flags1
	bit SOUND_CHANNEL_ON, [hl]
	jr nz, .wait
	ld hl, wChannel8Flags1
	bit SOUND_CHANNEL_ON, [hl]
	jr nz, .wait
	pop hl
	ret

MaxVolume::
	ld a, MAX_VOLUME
	ld [wVolume], a
	ret
LowVolume::
	ld a, $33
	ld [wVolume], a
	ret
MinVolume::
	xor a
	ld [wVolume], a
	ret
FadeOutToMusic::
	ld a, 4
	ld [wMusicFade], a
	ret
FadeInToMusic::
	ld a, 4 | (1 << MUSIC_FADE_IN_F)
	ld [wMusicFade], a
	ret

SkipMusic::
.loop
	and a
	ret z
	dec a
	call UpdateSound
	jr .loop

FadeToMapMusic::
	push hl
	push de
	push bc
	push af
	call GetMapMusic_MaybeSpecial
	ld a, [wMapMusic]
	cp e
	jr z, .done
	ld a, 8
	ld [wMusicFade], a
	ld a, e
	ld [wMusicFadeID], a
	ld a, d
	ld [wMusicFadeID + 1], a
	ld a, e
	ld [wMapMusic], a
.done
	pop af
	pop bc
	pop de
	pop hl
	ret

PlayMapMusic::
	push hl
	push de
	push bc
	push af
	call GetMapMusic_MaybeSpecial
	ld a, [wMapMusic]
	cp e
	jr z, .done
	push de
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	pop de
	ld a, e
	ld [wMapMusic], a
	call PlayMusic
.done
	pop af
	pop bc
	pop de
	pop hl
	ret

PlayMapMusicBike::
	push hl
	push de
	push bc
	push af
	xor a
	ld [wDontPlayMapMusicOnReload], a
	ld de, MUSIC_BICYCLE
	ld a, [wPlayerState]
	cp PLAYER_BIKE
	jr z, .play
	call GetMapMusic_MaybeSpecial
.play
	push de
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	pop de
	ld a, e
	ld [wMapMusic], a
	call PlayMusic
	pop af
	pop bc
	pop de
	pop hl
	ret

TryRestartMapMusic::
	ld a, [wDontPlayMapMusicOnReload]
	and a
	jr z, RestartMapMusic
	xor a
	ld [wMapMusic], a
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	xor a
	ld [wDontPlayMapMusicOnReload], a
	ret

RestartMapMusic::
	push hl
	push de
	push bc
	push af
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	ld a, [wMapMusic]
	ld e, a
	ld d, 0
	call PlayMusic
	pop af
	pop bc
	pop de
	pop hl
	ret

SpecialMapMusic::
	ld a, [wPlayerState]
	cp PLAYER_SURF
	jr z, .surf
	cp PLAYER_SURF_PIKA
	jr z, .surf
	ld a, [wStatusFlags2]
	bit STATUSFLAGS2_BUG_CONTEST_TIMER_F, a
	jr nz, .contest
.no
	and a
	ret
.bike
	ld de, MUSIC_BICYCLE
	scf
	ret
.surf
	ld de, MUSIC_SURF
	scf
	ret
.contest
	ld a, [wMapGroup]
	cp GROUP_ROUTE_35_NATIONAL_PARK_GATE
	jr nz, .no
	ld a, [wMapNumber]
	cp MAP_ROUTE_35_NATIONAL_PARK_GATE
	jr z, .ranking
	cp MAP_ROUTE_36_NATIONAL_PARK_GATE
	jr nz, .no
.ranking
	ld de, MUSIC_BUG_CATCHING_CONTEST_RANKING
	scf
	ret

GetMapMusic_MaybeSpecial::
	call SpecialMapMusic
	ret c
	call GetMapMusic
	ret

PlaceBCDNumberSprite::
	ld a, 4 * TILE_WIDTH
	ld [wShadowOAMSprite38YCoord], a
	ld [wShadowOAMSprite39YCoord], a
	ld a, 10 * TILE_WIDTH
	ld [wShadowOAMSprite38XCoord], a
	ld a, 11 * TILE_WIDTH
	ld [wShadowOAMSprite39XCoord], a
	xor a
	ld [wShadowOAMSprite38Attributes], a
	ld [wShadowOAMSprite39Attributes], a
	ld a, [wUnusedBCDNumber]
	cp 100
	jr nc, .max
	add 1
	daa
	ld b, a
	swap a
	and $f
	add $f6
	ld [wShadowOAMSprite38TileID], a
	ld a, b
	and $f
	add $f6
	ld [wShadowOAMSprite39TileID], a
	ret
.max
IF DEF(_JAPANESE)
	ld a, $ff
ELSE
	ld a, $ff
ENDC
	ld [wShadowOAMSprite38TileID], a
	ld [wShadowOAMSprite39TileID], a
	ret

CheckSFX::
	ld a, [wChannel5Flags1]
	bit SOUND_CHANNEL_ON, a
	jr nz, .playing
	ld a, [wChannel6Flags1]
	bit SOUND_CHANNEL_ON, a
	jr nz, .playing
	ld a, [wChannel7Flags1]
	bit SOUND_CHANNEL_ON, a
	jr nz, .playing
	ld a, [wChannel8Flags1]
	bit SOUND_CHANNEL_ON, a
	jr nz, .playing
	and a
	ret
.playing
	scf
	ret

TerminateExpBarSound::
	xor a
	ld [wChannel5Flags1], a
	ld [wPitchSweep], a
	ldh [rAUD1SWEEP], a
	ldh [rAUD1LEN], a
	ldh [rAUD1ENV], a
	ldh [rAUD1LOW], a
	ldh [rAUD1HIGH], a
	ret

IF DEF(_JAPANESE) && DEF(_REV0)
INCLUDE "garbage/rev_0/bank00.asm"
ENDC
