SECTION "Textbox Reconstruction", ROM0

IF DEF(_KOREAN)
Textbox::
    farcall_reg KoreanTextbox
    ret

SECTION "Korean Textbox Reconstruction", ROMX[$40B8], BANK[$7F]

KoreanTextbox::
    ldh a, [$d6]
    push af
    xor a
    ldh [$d6], a
    push bc
    push hl
    call TextboxBorder
    pop hl
    pop bc
    call TextboxPalette
    pop af
    ldh [$d6], a
    ret
ELSE
Textbox::
    push bc
    push hl
    call TextboxBorder
    pop hl
    pop bc
    jr TextboxPalette
ENDC

TextboxBorder::
    push hl
    ld a, $79
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
    ld a, $7c
    ld [hli], a
    ld a, " "
    call .PlaceChars
    ld [hl], $7c
    pop hl
    ld de, SCREEN_WIDTH
    add hl, de
    dec b
    jr nz, .row
    ld a, $7d
    ld [hli], a
    ld a, $7a
    call .PlaceChars
    ld [hl], $7e
    ret
.PlaceChars
    ld d, c
.loop
    ld [hli], a
    dec d
    jr nz, .loop
    ret

TextboxPalette::
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
