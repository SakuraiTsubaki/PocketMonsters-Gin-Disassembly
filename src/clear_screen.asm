SECTION "Clear Screen Reconstruction", ROM0

ClearTilemap::
    ld hl, wTilemap
    ld a, " "
    ld bc, SCREEN_AREA
    call ByteFill
    ldh a, [rLCDC]
    bit B_LCDC_ENABLE, a
IF DEF(_KOREAN)
    ret

ClearScreen::
    ld a, PAL_BG_TEXT
    ld hl, wAttrmap
    ld bc, SCREEN_AREA
    call ByteFill
    call ClearTilemap
    ret z
    jp WaitBGMap
ELSE
    ret z
    jp WaitBGMap

ClearScreen::
    ld a, PAL_BG_TEXT
    ld hl, wAttrmap
    ld bc, SCREEN_AREA
    call ByteFill
    jr ClearTilemap
ENDC
