; Multi-region Bank 00 text engine.
; Western baseline: pret/pokegold; Japanese: Narishma-gb/pokesilver;
; Korean: Narishma-gb/pokegold-kr. EU literal data is localized explicitly.

ClearBox::
IF DEF(_KOREAN)
	farcall_reg _ClearBox
	ret
ELSE
IF DEF(_JAPANESE)
	ld a, '　'
ELSE
	ld a, ' '
ENDC
	ld de, SCREEN_WIDTH
.row
	push hl
	push bc
.col
	ld [hli], a
	dec c
	jr nz, .col
	pop bc
	pop hl
	add hl, de
	dec b
	jr nz, .row
	ret
ENDC

ClearTilemap::
IF DEF(_KOREAN)
	call Function14a2
	call _ClearTilemap
	ret z
	jp WaitBGMap
ELSE
	hlcoord 0, 0
IF DEF(_JAPANESE)
	ld a, '　'
ELSE
	ld a, ' '
ENDC
	ld bc, wTilemapEnd - wTilemap
	call ByteFill
	ldh a, [rLCDC]
	bit B_LCDC_ENABLE, a
	ret z
	jp WaitBGMap
ENDC

IF DEF(_KOREAN)
_ClearTilemap::
	hlcoord 0, 0
	ld a, ' '
	ld bc, wTilemapEnd - wTilemap
	call ByteFill
	ldh a, [rLCDC]
	bit B_LCDC_ENABLE, a
	ret
ENDC

ClearScreen::
	ld a, PAL_BG_TEXT
IF DEF(_KOREAN)
ClearScreen2::
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
	call ByteFill
	call _ClearTilemap
	ret z
	jp WaitBGMap2
ELSE
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
	call ByteFill
	jr ClearTilemap
ENDC

Textbox::
IF DEF(_KOREAN)
	farcall_reg _Textbox
	ret
ELSE
	push bc
	push hl
	call TextboxBorder
	pop hl
	pop bc
	jr TextboxPalette
ENDC

IF !DEF(_KOREAN)
TextboxBorder::
	push hl
	ld a, '┌'
	ld [hli], a
	inc a
	call .PlaceChars
	inc a
	ld [hl], a
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
.row
	push hl
	ld a, '│'
	ld [hli], a
IF DEF(_JAPANESE)
	ld a, '　'
ELSE
	ld a, ' '
ENDC
	call .PlaceChars
	ld [hl], '│'
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
	dec b
	jr nz, .row
	ld a, '└'
	ld [hli], a
	ld a, '─'
	call .PlaceChars
	ld [hl], '┘'
	ret
.PlaceChars:
	ld d, c
.loop
	ld [hli], a
	dec d
	jr nz, .loop
	ret
ENDC

TextboxPalette::
IF DEF(_KOREAN)
	farcall_reg _TextboxPalette
	ret
ELSE
	ld de, wAttrmap - wTilemap
	add hl, de
	inc b
	inc b
	inc c
	inc c
	ld a, PAL_BG_TEXT
.col
	push bc
	push hl
.row
	ld [hli], a
	dec c
	jr nz, .row
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
	pop bc
	dec b
	jr nz, .col
	ret
ENDC

SpeechTextbox::
	hlcoord TEXTBOX_X, TEXTBOX_Y
	ld b, TEXTBOX_INNERH
	ld c, TEXTBOX_INNERW
	jp Textbox

GameFreakText::
	text "ゲームフりーク！"
	done

RadioTerminator::
	ld hl, .stop
	ret
.stop:
	text_end

PrintText::
	call SetUpTextbox
PrintTextboxText::
	bccoord TEXTBOX_INNERX, TEXTBOX_INNERY
	call PrintTextboxTextAt
	ret

SetUpTextbox::
	push hl
	call SpeechTextbox
	call UpdateSprites
	call ApplyTilemap
	pop hl
	ret

PlaceString::
	push hl
PlaceNextChar::
	ld a, [de]
	cp '@'
	jr nz, CheckDict
	ld b, h
	ld c, l
	pop hl
	ret

DummyChar::
	pop de
NextChar::
	inc de
	jp PlaceNextChar

MACRO dict
	if \1 == 0
		and a
	else
		cp \1
	endc
	if ISCONST(\2)
		jr nz, .not\@
		ld a, \2
	.not\@:
	elif STRFIND("\2", ".") == 0
		jr z, \2
	else
		jp z, \2
	endc
ENDM

CheckDict::
IF DEF(_KOREAN)
	cp $c
	jp c, DoubleByteChar
ENDC
IF DEF(_JAPANESE)
	dict '<LINE>', LineChar
	dict '<NEXT>', NextLineChar
	dict '<NULL>', NullChar
	dict '<SCROLL>', _ContTextNoPause
	dict '<_CONT>', _ContText
	dict '<PARA>', Paragraph
	dict '<MOM>', PrintMomsName
	dict '<PLAYER>', PrintPlayerName
	dict '<RIVAL>', PrintRivalName
	dict '<ROUTE>', PlaceRoute
	dict '<WATASHI>', PlaceWatashi
	dict '<KOKO_WA>', PlaceKokoWa
	dict '<RED>', PrintRedsName
	dict '<GREEN>', PrintGreensName
	dict '#', PlacePokemon
	dict '<PC>', PlacePC
	dict '<ROCKET>', PlaceRocket
	dict '<TM>', PlaceTM
	dict '<TRAINER>', PlaceTrainer
	dict '<KOUGEKI>', PlaceKougeki
	dict '<TA!>', PlaceTa
	dict '<CONT>', ContText
	dict '<⋯>', PlaceSixDots
	dict '<DONE>', DoneText
	dict '<PROMPT>', PromptText
	dict '<GA>', PlaceGa
	dict '<WA>', PlaceWa
	dict '<NO>', PlaceNo
	dict '<WO>', PlaceWo
	dict '<TTE>', PlaceTte
	dict '<NI>', PlaceNi
	dict '<DEXEND>', PlaceDexEnd
	dict '<TARGET>', PlaceMoveTargetsName
	dict '<USER>', PlaceMoveUsersName
	dict '<ENEMY>', PlaceEnemysName
ELSE
	dict '<LINE>', LineChar
	dict '<NEXT>', NextLineChar
	dict '<NULL>', NullChar
	dict '<SCROLL>', _ContTextNoPause
	dict '<_CONT>', _ContText
	dict '<PARA>', Paragraph
	dict '<MOM>', PrintMomsName
	dict '<PLAYER>', PrintPlayerName
	dict '<RIVAL>', PrintRivalName
	dict '<ROUTE>', PlaceJPRoute
	dict '<WATASHI>', PlaceWatashi
	dict '<KOKO_WA>', PlaceKokoWa
	dict '<RED>', PrintRedsName
	dict '<GREEN>', PrintGreensName
	dict '#', PlacePOKe
	dict '<PC>', PCChar
	dict '<ROCKET>', RocketChar
	dict '<TM>', TMChar
	dict '<TRAINER>', TrainerChar
	dict '<KOUGEKI>', PlaceKougeki
	dict '<LF>', LineFeedChar
	dict '<CONT>', ContText
	dict '<……>', SixDotsChar
	dict '<DONE>', DoneText
	dict '<PROMPT>', PromptText
	dict '<PKMN>', PlacePKMN
	dict '<POKE>', PlacePOKE
	dict '<WBR>', NextChar
	dict '<BSP>', ' '
	dict '<DEXEND>', PlaceDexEnd
	dict '<TARGET>', PlaceMoveTargetsName
	dict '<USER>', PlaceMoveUsersName
	dict '<ENEMY>', PlaceEnemysName
ENDC
IF DEF(_JAPANESE) || DEF(_KOREAN)
	dict '゜', .diacritic
	cp '゛'
ELSE
	dict 'ﾟ', .diacritic
	cp 'ﾞ'
ENDC
	jr nz, .not_diacritic
.diacritic
	ld b, a
	call Diacritic
	jp NextChar
.not_diacritic
	cp FIRST_REGULAR_TEXT_CHAR
	jr nc, .place
	cp 'パ'
	jr nc, .handakuten
	cp FIRST_HIRAGANA_DAKUTEN_CHAR
	jr nc, .hiragana_dakuten
	add 'カ' - 'ガ'
	jr .place_dakuten
.hiragana_dakuten
	add 'か' - 'が'
.place_dakuten
IF DEF(_JAPANESE) || DEF(_KOREAN)
	ld b, '゛'
ELSE
	ld b, 'ﾞ'
ENDC
	call Diacritic
	jr .place
.handakuten
	cp 'ぱ'
	jr nc, .hiragana_handakuten
	add 'ハ' - 'パ'
	jr .place_handakuten
.hiragana_handakuten
	add 'は' - 'ぱ'
.place_handakuten
IF DEF(_JAPANESE) || DEF(_KOREAN)
	ld b, '゜'
ELSE
	ld b, 'ﾟ'
ENDC
	call Diacritic
.place
	ld [hli], a
	call PrintLetterDelay
	jp NextChar

MACRO print_name
	push de
	ld de, \1
	jp PlaceCommandCharacter
ENDM

PrintMomsName: print_name wMomsName
PrintPlayerName: print_name wPlayerName
PrintRivalName: print_name wRivalName
PrintRedsName: print_name wRedsName
PrintGreensName: print_name wGreensName

IF DEF(_JAPANESE)
PlaceTrainer: print_name TrainerCharText
PlaceTM: print_name TMCharText
PlacePC: print_name PCCharText
PlaceRocket: print_name RocketCharText
PlacePokemon: print_name PokemonCharText
PlaceKougeki: print_name KougekiCharText
PlaceTa: print_name TaCharText
PlaceSixDots: print_name SixDotsCharText
PlaceGa: print_name GaCharText
PlaceWa: print_name WaCharText
PlaceNo: print_name NoCharText
PlaceWo: print_name WoCharText
PlaceNi: print_name NiCharText
PlaceTte: print_name TteCharText
PlaceRoute: print_name RouteCharText
PlaceWatashi: print_name WatashiCharText
PlaceKokoWa: print_name KokoWaCharText
ELSE
TrainerChar: print_name TrainerCharText
TMChar: print_name TMCharText
PCChar: print_name PCCharText
RocketChar: print_name RocketCharText
PlacePOKe: print_name PlacePOKeText
PlaceKougeki: print_name KougekiText
SixDotsChar: print_name SixDotsCharText
PlacePKMN: print_name PlacePKMNText
PlacePOKE: print_name PlacePOKEText
PlaceJPRoute: print_name PlaceJPRouteText
PlaceWatashi: print_name PlaceWatashiText
PlaceKokoWa: print_name PlaceKokoWaText
ENDC

PlaceMoveTargetsName::
	ldh a, [hBattleTurn]
	xor 1
	jr PlaceBattlersName
PlaceMoveUsersName::
	ldh a, [hBattleTurn]
PlaceBattlersName:
	push de
	and a
	jr nz, .enemy
	ld de, wBattleMonNickname
	jr PlaceCommandCharacter
.enemy
	ld de, EnemyText
	call PlaceString
	ld h, b
	ld l, c
	ld de, wEnemyMonNickname
	jr PlaceCommandCharacter

PlaceEnemysName::
	push de
	ld a, [wLinkMode]
	and a
	jr nz, .linkbattle
	ld a, [wTrainerClass]
	cp RIVAL1
	jr z, .rival
	cp RIVAL2
	jr z, .rival
	ld de, wOTClassName
	call PlaceString
	ld h, b
	ld l, c
IF DEF(_JAPANESE)
	ld de, NoCharText
ELSE
	ld de, String_Space
ENDC
	call PlaceString
	push bc
	callfar Battle_GetTrainerName
	pop hl
	ld de, wStringBuffer1
	jr PlaceCommandCharacter
.rival
	ld de, wRivalName
	jr PlaceCommandCharacter
.linkbattle
	ld de, wOTClassName
	jr PlaceCommandCharacter

PlaceCommandCharacter::
	call PlaceString
	ld h, b
	ld l, c
	pop de
	jp NextChar

IF DEF(_JAPANESE)
TMCharText:: db "わざマシン@"
TrainerCharText:: db "トレーナー@"
PCCharText:: db "パソコン@"
RocketCharText:: db "ロケットだん@"
PokemonCharText:: db "ポケモン@"
KougekiCharText:: db "こうげき@"
TaCharText:: db "た！@"
SixDotsCharText:: db "⋯⋯@"
EnemyText:: db "てきの　@"
GaCharText:: db "が　@"
WaCharText:: db "は　@"
NoCharText:: db "の　@"
WoCharText:: db "を　@"
NiCharText:: db "に　@"
TteCharText:: db "って@"
RouteCharText:: db "ばん　どうろ@"
WatashiCharText:: db "わたし@"
KokoWaCharText:: db "ここは　@"
ELIF DEF(_KOREAN)
TMCharText:: db "기술머신@"
TrainerCharText:: db "트레이너@"
PCCharText:: db "컴퓨터@"
RocketCharText:: db "로켓단@"
PlacePOKeText:: db "포켓몬@"
KougekiText:: db "こうげき@"
SixDotsCharText:: db "<…><…>@"
EnemyText:: db "적의 @"
PlacePKMNText:: db "<PK><MN>@"
PlacePOKEText:: db "<PO><KE>@"
String_Space:: db " @"
PlaceJPRouteText::
PlaceWatashiText::
PlaceKokoWaText:: db "@"
ELSE
IF DEF(_FRENCH)
TMCharText:: db "CT@"
TrainerCharText:: db "DRESSEUR@"
EnemyText:: db " ennemi@"
ELIF DEF(_ITALIAN)
TMCharText:: db "MT@"
TrainerCharText:: db "ALLEN.@"
EnemyText:: db " nemico@"
ELIF DEF(_SPANISH)
TMCharText:: db "MT@"
TrainerCharText:: db "ENTREN.@"
EnemyText:: db "Enem. @"
ELIF DEF(_GERMAN)
TMCharText:: db "TM@"
TrainerCharText:: db "TRAINER@"
EnemyText:: db "Gegn. @"
ELSE
TMCharText:: db "TM@"
TrainerCharText:: db "TRAINER@"
EnemyText:: db "Enemy @"
ENDC
PCCharText:: db "PC@"
RocketCharText:: db "ROCKET@"
PlacePOKeText:: db "POKé@"
KougekiText:: db "こうげき@"
SixDotsCharText:: db "……@"
PlacePKMNText:: db "<PK><MN>@"
PlacePOKEText:: db "<PO><KE>@"
String_Space:: db " @"
PlaceJPRouteText::
PlaceWatashiText::
PlaceKokoWaText:: db "@"
ENDC

NextLineChar::
	pop hl
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	push hl
	jp NextChar
IF !DEF(_JAPANESE)
LineFeedChar::
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	push hl
	jp NextChar
ENDC
LineChar::
	pop hl
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY + 2
	push hl
	jp NextChar

Paragraph::
	push de
	ld a, [wLinkMode]
	cp LINK_COLOSSEUM
	jr z, .linkbattle
	call LoadBlinkingCursor
.linkbattle
	call Text_WaitBGMap
	call PromptButton
IF DEF(_JAPANESE) || DEF(_KOREAN)
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY - 1
	lb bc, TEXTBOX_INNERH, TEXTBOX_INNERW
ELSE
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY
	lb bc, TEXTBOX_INNERH - 1, TEXTBOX_INNERW
ENDC
	call ClearBox
	call UnloadBlinkingCursor
	ld c, 20
	call DelayFrames
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY
	pop de
	jp NextChar

_ContText::
	ld a, [wLinkMode]
IF DEF(_JAPANESE)
	cp LINK_COLOSSEUM
	jr z, .communication
ELSE
	or a
	jr nz, .communication
ENDC
	call LoadBlinkingCursor
.communication
	call Text_WaitBGMap
	push de
	call PromptButton
	pop de
IF DEF(_JAPANESE)
	call UnloadBlinkingCursor
ELSE
	ld a, [wLinkMode]
	or a
	call z, UnloadBlinkingCursor
ENDC
_ContTextNoPause::
	push de
	call TextScroll
	call TextScroll
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY + 2
	pop de
	jp NextChar

ContText::
	push de
	ld de, .cont
	ld b, h
	ld c, l
	call PlaceString
	ld h, b
	ld l, c
	pop de
	jp NextChar
.cont: db "<_CONT>@"

PlaceDexEnd::
IF DEF(_JAPANESE)
	ld [hl], '。'
ELSE
	ld [hl], '.'
ENDC
	pop hl
	ret

PromptText::
	ld a, [wLinkMode]
	cp LINK_COLOSSEUM
	jr z, .ok
	call LoadBlinkingCursor
.ok
	call Text_WaitBGMap
	call PromptButton
	ld a, [wLinkMode]
	cp LINK_COLOSSEUM
	jr z, DoneText
	call UnloadBlinkingCursor
DoneText::
	pop hl
	ld de, .stop
	dec de
	ret
.stop:
	text_end

NullChar::
	ld b, h
	ld c, l
	pop hl
	ld de, .ErrorText
	dec de
	ret
.ErrorText
	text_decimal hObjectStructIndex, 1, 2
	text "エラー"
	done

IF DEF(_KOREAN)
DoubleByteChar::
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	farcall_reg PlaceDoubleByteChar
	call PrintLetterDelay
	jp NextChar
TextScroll::
	farcall_reg _TextScroll
	ret
ELSE
TextScroll::
	hlcoord TEXTBOX_X, TEXTBOX_INNERY
	decoord TEXTBOX_X, TEXTBOX_INNERY - 1
	ld bc, 3 * SCREEN_WIDTH
	call CopyBytes
	hlcoord TEXTBOX_INNERX, TEXTBOX_INNERY + 2
IF DEF(_JAPANESE)
	ld a, '　'
ELSE
	ld a, ' '
ENDC
	ld bc, TEXTBOX_INNERW
	call ByteFill
	ld c, 5
	call DelayFrames
	ret
ENDC

Text_WaitBGMap::
	push bc
	ldh a, [hOAMUpdate]
	push af
	ld a, 1
	ldh [hOAMUpdate], a
	call WaitBGMap
	pop af
	ldh [hOAMUpdate], a
	pop bc
	ret

Diacritic::
	push af
	push hl
	ld a, b
	ld bc, -SCREEN_WIDTH
	add hl, bc
	ld [hl], a
	pop hl
	pop af
	ret

LoadBlinkingCursor::
	ld a, '▼'
	ldcoord_a 18, 17
	ret
UnloadBlinkingCursor::
	ld a, '─'
	ldcoord_a 18, 17
	ret

IF !DEF(_JAPANESE)
PlaceFarString::
	ld b, a
	ldh a, [hROMBank]
	push af
	ld a, b
	rst Bankswitch
	call PlaceString
	pop af
	rst Bankswitch
	ret
ENDC

PokeFluteTerminator::
	ld hl, .stop
	ret
.stop:
	text_end

PrintTextboxTextAt::
	ld a, [wTextboxFlags]
	push af
	set TEXT_DELAY_F, a
	ld [wTextboxFlags], a
	call DoTextUntilTerminator
	pop af
	ld [wTextboxFlags], a
	ret

DoTextUntilTerminator::
	ld a, [hli]
	cp TX_END
	ret z
	call .TextCommand
	jr DoTextUntilTerminator
.TextCommand:
	push hl
	push bc
	ld c, a
	ld b, 0
	ld hl, TextCommands
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop bc
	pop hl
	push de
	ret

TextCommands::
	table_width 2
	dw TextCommand_START
	dw TextCommand_RAM
	dw TextCommand_BCD
	dw TextCommand_MOVE
	dw TextCommand_BOX
	dw TextCommand_LOW
	dw TextCommand_PROMPT_BUTTON
	dw TextCommand_SCROLL
	dw TextCommand_START_ASM
	dw TextCommand_DECIMAL
	dw TextCommand_PAUSE
	dw TextCommand_SOUND
	dw TextCommand_DOTS
	dw TextCommand_WAIT_BUTTON
	dw TextCommand_SOUND
	dw TextCommand_SOUND
	dw TextCommand_SOUND
	dw TextCommand_SOUND
	dw TextCommand_SOUND
	dw TextCommand_SOUND
	dw TextCommand_STRINGBUFFER
	dw TextCommand_DAY
IF !DEF(_JAPANESE)
	dw TextCommand_FAR
ENDC

TextCommand_START::
	ld d, h
	ld e, l
	ld h, b
	ld l, c
	call PlaceString
	ld h, d
	ld l, e
	inc hl
	ret
TextCommand_RAM::
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	push hl
	ld h, b
	ld l, c
	call PlaceString
	pop hl
	ret
IF !DEF(_JAPANESE)
TextCommand_FAR::
	ldh a, [hROMBank]
	push af
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ldh [hROMBank], a
	ld [rROMB], a
	push hl
	ld h, d
	ld l, e
	call DoTextUntilTerminator
	pop hl
	pop af
	ldh [hROMBank], a
	ld [rROMB], a
	ret
ENDC
TextCommand_BCD::
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	push hl
	ld h, b
	ld l, c
	ld c, a
	call PrintBCDNumber
	ld b, h
	ld c, l
	pop hl
	ret
TextCommand_MOVE::
	ld a, [hli]
	ld [wMenuScrollPosition + 2], a
	ld c, a
	ld a, [hli]
	ld [wMenuScrollPosition + 3], a
	ld b, a
	ret
TextCommand_BOX::
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	push hl
	ld h, d
	ld l, e
	call Textbox
	pop hl
	ret
TextCommand_LOW::
	bccoord TEXTBOX_INNERX, TEXTBOX_INNERY + 2
	ret
TextCommand_PROMPT_BUTTON::
	ld a, [wLinkMode]
	cp LINK_COLOSSEUM
	jp z, TextCommand_WAIT_BUTTON
	push hl
	call LoadBlinkingCursor
	push bc
	call PromptButton
	pop bc
	call UnloadBlinkingCursor
	pop hl
	ret
TextCommand_SCROLL::
	push hl
	call UnloadBlinkingCursor
	call TextScroll
	call TextScroll
	pop hl
	bccoord TEXTBOX_INNERX, TEXTBOX_INNERY + 2
	ret
TextCommand_START_ASM::
	jp hl
TextCommand_DECIMAL::
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	push hl
	ld h, b
	ld l, c
	ld b, a
	and $f
	ld c, a
	ld a, b
	and $f0
	swap a
	set PRINTNUM_LEFTALIGN_F, a
	ld b, a
	call PrintNum
	ld b, h
	ld c, l
	pop hl
	ret
TextCommand_PAUSE::
	push hl
	push bc
	call GetJoypad
	ldh a, [hJoyDown]
	and PAD_A | PAD_B
	jr nz, .done
	ld c, 30
	call DelayFrames
.done
	pop bc
	pop hl
	ret
TextCommand_SOUND::
	push bc
	dec hl
	ld a, [hli]
	ld b, a
	push hl
	ld hl, TextSFX
.loop
	ld a, [hli]
	cp -1
	jr z, .done
	cp b
	jr z, .play
	inc hl
	inc hl
	jr .loop
.play
	push de
	ld e, [hl]
	inc hl
	ld d, [hl]
	call PlaySFX
	call WaitSFX
	pop de
.done
	pop hl
	pop bc
	ret
TextCommand_CRY::
	push de
	ld e, [hl]
	inc hl
	ld d, [hl]
	call PlayMonCry
	pop de
	pop hl
	pop bc
	ret

TextSFX::
	dbw TX_SOUND_DEX_FANFARE_50_79, SFX_DEX_FANFARE_50_79
	dbw TX_SOUND_FANFARE, SFX_FANFARE
	dbw TX_SOUND_DEX_FANFARE_20_49, SFX_DEX_FANFARE_20_49
	dbw TX_SOUND_ITEM, SFX_ITEM
	dbw TX_SOUND_CAUGHT_MON, SFX_CAUGHT_MON
	dbw TX_SOUND_DEX_FANFARE_80_109, SFX_DEX_FANFARE_80_109
	dbw TX_SOUND_SLOT_MACHINE_START, SFX_SLOT_MACHINE_START
	db -1

TextCommand_DOTS::
	ld a, [hli]
	ld d, a
	push hl
	ld h, b
	ld l, c
.loop
	push de
IF DEF(_JAPANESE)
	ld a, '⋯'
ELIF DEF(_KOREAN)
	ld a, '<…>'
ELSE
	ld a, '…'
ENDC
	ld [hli], a
	call GetJoypad
	ldh a, [hJoyDown]
	and PAD_A | PAD_B
	jr nz, .next
	ld c, 10
	call DelayFrames
.next
	pop de
	dec d
	jr nz, .loop
	ld b, h
	ld c, l
	pop hl
	ret
TextCommand_WAIT_BUTTON::
	push hl
	push bc
	call PromptButton
	pop bc
	pop hl
	ret
TextCommand_STRINGBUFFER::
	ld a, [hli]
	push hl
	ld e, a
	ld d, 0
	ld hl, StringBufferPointers
	add hl, de
	add hl, de
	ld a, BANK(StringBufferPointers)
	call GetFarWord
	ld d, h
	ld e, l
	ld h, b
	ld l, c
	call PlaceString
	pop hl
	ret

TextCommand_DAY::
	call GetWeekday
	push hl
	push bc
	ld c, a
	ld b, 0
	ld hl, .Days
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld d, h
	ld e, l
	pop hl
	call PlaceString
	ld h, b
	ld l, c
	ld de, .Day
	call PlaceString
	pop hl
	ret
.Days:
	dw .Sun
	dw .Mon
	dw .Tues
	dw .Wednes
	dw .Thurs
	dw .Fri
	dw .Satur
IF DEF(_JAPANESE)
.Sun: db "にち@"
.Mon: db "げつ@"
.Tues: db "か@"
.Wednes: db "すい@"
.Thurs: db "もく@"
.Fri: db "きん@"
.Satur: db "ど@"
.Day: db "ようび@"
ELIF DEF(_KOREAN)
.Sun: db "일@"
.Mon: db "월@"
.Tues: db "화@"
.Wednes: db "수@"
.Thurs: db "목@"
.Fri: db "금@"
.Satur: db "토@"
.Day: db "요일@"
ELIF DEF(_GERMAN)
.Sun: db "SONNTAG@"
.Mon: db "MONTAG@"
.Tues: db "DIENSTAG@"
.Wednes: db "MITTWOCH@"
.Thurs: db "DONNERSTAG@"
.Fri: db "FREITAG@"
.Satur: db "SAMSTAG@"
.Day: db "@"
ELIF DEF(_FRENCH)
.Sun: db "DIMANCHE@"
.Mon: db "LUNDI@"
.Tues: db "MARDI@"
.Wednes: db "MERCREDI@"
.Thurs: db "JEUDI@"
.Fri: db "VENDREDI@"
.Satur: db "SAMEDI@"
.Day: db "@"
ELIF DEF(_ITALIAN)
.Sun: db "DOMENICA@"
.Mon: db "LUNEDÌ@"
.Tues: db "MARTEDÌ@"
.Wednes: db "MERCOLEDÌ@"
.Thurs: db "GIOVEDÌ@"
.Fri: db "VENERDÌ@"
.Satur: db "SABATO@"
.Day: db "@"
ELIF DEF(_SPANISH)
.Sun: db "DOMINGO@"
.Mon: db "LUNES@"
.Tues: db "MARTES@"
.Wednes: db "MIÉRCOLES@"
.Thurs: db "JUEVES@"
.Fri: db "VIERNES@"
.Satur: db "SÁBADO@"
.Day: db "@"
ELSE
.Sun: db "SUN@"
.Mon: db "MON@"
.Tues: db "TUES@"
.Wednes: db "WEDNES@"
.Thurs: db "THURS@"
.Fri: db "FRI@"
.Satur: db "SATUR@"
.Day: db "DAY@"
ENDC

IF DEF(_KOREAN)
SetStandardHangulFont::
	di
	ld a, BANK("WRAM 2")
	ldh [rWBK], a
	xor a
	ld [wInvertedHangulToggle], a
	ld a, $01
	ldh [rWBK], a
	ei
	ret
SetInvertedHangulFont::
	di
	ld a, BANK("WRAM 2")
	ldh [rWBK], a
	ld a, $ff
	ld [wInvertedHangulToggle], a
	ld a, $01
	ldh [rWBK], a
	ei
	ret
Function1490::
	di
	ld a, BANK("WRAM 2")
	ldh [rWBK], a
	ld a, [wInvertedHangulToggle]
	cpl
	ld [wInvertedHangulToggle], a
	ld a, $01
	ldh [rWBK], a
	ei
	ret
Function14a2::
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
Function14a8::
	inc b
	inc c
	jr .start_loop
.loop
	res B_BG_BANK1, [hl]
	inc hl
.start_loop
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret
Function14b6::
	push bc
	push hl
	ld bc, wAttrmap - wTilemap
	add hl, bc
	res B_BG_BANK1, [hl]
	pop hl
	pop bc
	ret
TrimUnusedHangulChars::
	farcall_reg _TrimUnusedHangulChars
	ret
FindNextEmptyHangulSlot::
	farcall_reg _FindNextEmptyHangulSlot
	ret
IsHangulCharDrawn::
	farcall_reg _IsHangulCharDrawn
	ret
DrawHangulChar::
	push de
	farcall_reg _DrawHangulChar
	pop de
	ret
PrepareVDMAData::
	ldh a, [hROMBank]
	push af
	ld a, b
	rst Bankswitch
	di
	ld a, BANK("WRAM 2")
	ldh [rWBK], a
	ld a, [wInvertedHangulToggle]
	ld b, a
	ld c, 2 * TILE_1BPP_SIZE
.loop
	ld a, [de]
	inc de
	xor b
	ldi [hl], a
	ldi [hl], a
	dec c
	jr nz, .loop
	ld a, $01
	ldh [rWBK], a
	ei
	pop af
	rst Bankswitch
	ret
ENDC
