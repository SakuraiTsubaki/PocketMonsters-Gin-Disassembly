SECTION "Sprite Clearing Reconstruction", ROM0

ClearSprites::
    ld hl, wShadowOAM
    ld b, wShadowOAMEnd - wShadowOAM
    xor a
.loop
    ld [hli], a
    dec b
    jr nz, .loop
    ret

HideSprites::
    ld hl, wShadowOAMSprite00YCoord
    ld de, OBJ_SIZE
    ld b, OAM_COUNT
    ld a, OAM_YCOORD_HIDDEN
.loop
    ld [hl], a
    add hl, de
    dec b
    jr nz, .loop
    ret
