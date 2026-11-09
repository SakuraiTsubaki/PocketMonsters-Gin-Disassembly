SECTION "Delay Reconstruction", ROM0

DelayFrame::
    ld a, 1
    ld [wVBlankOccurred], a
.halt
    halt
    nop
    ld a, [wVBlankOccurred]
    and a
    jr nz, .halt
    ret

DelayFrames::
    call DelayFrame
    dec c
    jr nz, DelayFrames
    ret
