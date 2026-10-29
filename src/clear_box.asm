SECTION "ClearBox Reconstruction", ROM0

IF DEF(_KOREAN)
ClearBox::
    farcall_reg KoreanClearBox
    ret

SECTION "Korean ClearBox Reconstruction", ROMX[$408D], BANK[$7F]

KoreanClearBox::
    push hl
    push bc
    ld de, $0940
    add hl, de
    ld de, SCREEN_WIDTH
.attributeRow
    push hl
    push bc
.attributeTile
    res 3, [hl]
    inc hl
    dec c
    jr nz, .attributeTile
    pop bc
    pop hl
    add hl, de
    dec b
    jr nz, .attributeRow
    pop bc
    pop hl
    ld a, " "
    ld de, SCREEN_WIDTH
.tileRow
    push hl
    push bc
.tile
    ld [hli], a
    dec c
    jr nz, .tile
    pop bc
    pop hl
    add hl, de
    dec b
    jr nz, .tileRow
    ret
ELSE
ClearBox::
    ld a, " "
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
