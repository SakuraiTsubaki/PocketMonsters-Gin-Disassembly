; Korean Gold/Silver double-byte Hangul renderer.
; Independently range-verified against the retail Korean ROM.
; Reference labels: Narishma-gb/pokegold-kr symbols build 77b4875b.

SECTION "Korean Hangul placement", ROMX[$4119], BANK[$7f]

PlaceDoubleByteChar::
    push de
    push hl
    push bc
    call IsHangulCharDrawn
    jr nc, .got_slot
    call FindNextEmptyHangulSlot
    jr nc, .got_slot
    call TrimUnusedHangulChars
    call FindNextEmptyHangulSlot

.got_slot
    pop bc
    push af
    call DrawHangulChar
    pop af
    pop hl
    pop de

    di
    ld bc, wAttrmap - wTilemap
    add hl, bc
    set B_BG_BANK1, [hl]
    ld bc, -SCREEN_WIDTH
    add hl, bc
    set B_BG_BANK1, [hl]

    ld bc, wTilemap - wAttrmap
    add hl, bc
    ld [hl], a
    inc a
    ld bc, SCREEN_WIDTH
    add hl, bc
    ld [hli], a
    ei
    ret


SECTION "Korean Hangul cache and renderer", ROMX[$4180], BANK[$7f]

_TrimUnusedHangulChars::
; Mark cache entries empty except characters currently visible on screen.
    ldh a, [rLCDC]
    bit B_LCDC_ENABLE, a
    jr z, .start_check

.wait_loop
    ldh a, [rLY]
    cp $7d
    jr nc, .wait_loop

.start_check
    di
    ld a, $02
    ldh [rWBK], a
    ld hl, wHangulTilesIndexTable

.clear_flags
    res 7, [hl]
    inc l
    inc l
    jr nz, .clear_flags

    ld a, $01
    ldh [rWBK], a
    ei

    ld de, wTilemap
    ld hl, wAttrmap
    lb bc, HIGH(wAttrmapEnd - wAttrmap) + 1, LOW(wAttrmapEnd - wAttrmap) + 1
    jr .start_loop

.set_flag_loop
    ld a, [hli]
    bit B_BG_BANK1, a
    jr z, .next

    push hl
    di
    ld a, $02
    ldh [rWBK], a
    ld a, [de]
    and %11111110
    ld l, a
    ld h, HIGH(wHangulTilesIndexTable)
    set 7, [hl]
    ld a, $01
    ldh [rWBK], a
    ei
    pop hl

.next
    inc de
.start_loop
    dec c
    jr nz, .set_flag_loop
    dec b
    jr nz, .set_flag_loop
    ret

_FindNextEmptyHangulSlot::
; Return the first available two-tile cache slot, or carry when full.
    ldh a, [rLCDC]
    bit B_LCDC_ENABLE, a
    jr z, .start_check

.wait_loop
    ldh a, [rLY]
    cp $7d
    jr nc, .wait_loop

.start_check
    di
    ld a, $02
    ldh [rWBK], a
    ld hl, wHangulTilesIndexTable

.loop
    bit 7, [hl]
    jr z, .found
    inc l
    inc l
    jr nz, .loop
    scf
    jr .done

.found
    sub a
.done
    ld a, $01
    ldh [rWBK], a
    ei
    ld a, l
    ret

_IsHangulCharDrawn::
; Input b:c is table:entry. Return an existing cache index or carry.
    ldh a, [rLCDC]
    bit B_LCDC_ENABLE, a
    jr z, .start_check

.wait_loop
    ldh a, [rLY]
    cp $7d
    jr nc, .wait_loop

.start_check
    di
    ld a, $02
    ldh [rWBK], a
    ld hl, wHangulTilesIndexTable

.loop
    bit 7, [hl]
    jr nz, .compare
.skip1
    inc l
.skip2
    inc l
    jr nz, .loop
    scf
    jr .done

.compare
    ld a, [hl]
    res 7, a
    cp b
    jr nz, .skip1
    inc l
    ld a, [hl]
    cp c
    jr nz, .skip2
    dec l
    sub a

.done
    ld a, $01
    ldh [rWBK], a
    ei
    ld a, l
    ret

_DrawHangulChar::
    and %11111110
    ld l, a
    ld h, HIGH(wHangulTilesIndexTable)
    di
    ld a, $02
    ldh [rWBK], a
    ld [hl], b
    set 7, [hl]
    inc l
    ld [hl], c
    ld a, $01
    ldh [rWBK], a
    ei
    dec l

; Convert b:c = table:entry into a bank offset and source address.
    ld a, $02
    srl b
    rr c
    rr a
    srl b
    rr c
    rr a
    rr c
    rr a
    rr c
    rr a
    push bc
    ld e, a
    ld d, c

; Convert the even cache index into a two-tile VRAM destination.
    ld a, $80
    add l
    ld b, 0
    sla a
    rl b
    sla a
    rl b
    sla a
    rl b
    sla a
    rl b
    ld c, a
    ld hl, vTiles4
    add hl, bc

    ld a, h
    ldh [rVDMA_DEST_HIGH], a
    ld a, l
    ldh [rVDMA_DEST_LOW], a
    ld hl, wHangulCharBuffer
    ld a, h
    ldh [rVDMA_SRC_HIGH], a
    ld a, l
    ldh [rVDMA_SRC_LOW], a

    pop af
    add BANK("Hangul Tables 1")
    ld b, a
    call PrepareVDMAData
    ldh a, [rLCDC]
    bit B_LCDC_ENABLE, a
    jr z, .general_purpose_DMA

    ldh a, [rLCDC]
    bit B_LCDC_ENABLE, a
    jr z, .start_HBlank_DMA

.wait_next_frame
    ldh a, [rLY]
    cp LY_VBLANK - 4
    jr nc, .wait_next_frame

.start_HBlank_DMA
    di
    ld a, BANK(vBGMap2)
    ldh [rVBK], a
    ld a, $02
    ldh [rWBK], a
    rst WaitHBlank
    ld a, VDMA_LEN_MODE_HBLANK | 1
    ldh [rVDMA_LEN], a
    ldh a, [rVDMA_LEN]
    and VDMA_LEN_SIZE
    inc a
.loop
    push af
    call WaitOneLine
    pop af
    dec a
    jr nz, .loop

    ld a, $01
    ldh [rWBK], a
    ld a, BANK(vBGMap0)
    ldh [rVBK], a
    ei
    ret

.general_purpose_DMA
    di
    ld a, BANK(vBGMap2)
    ldh [rVBK], a
    ld a, $02
    ldh [rWBK], a
    ld a, VDMA_LEN_MODE_GENERAL | 1
    ldh [rVDMA_LEN], a
    ld a, $01
    ldh [rWBK], a
    ld a, BANK(vBGMap0)
    ldh [rVBK], a
    ei
    ret

