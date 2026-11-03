SECTION "Far Access Reconstruction", ROM0

GetFarByte::
    ld [wTempBank], a
    ldh a, [hROMBank]
    push af
    ld a, [wTempBank]
    rst Bankswitch
    ld a, [hl]
    ld [wFarByte], a
    pop af
    rst Bankswitch
    ld a, [wFarByte]
    ret

GetFarWord::
    ld [wTempBank], a
    ldh a, [hROMBank]
    push af
    ld a, [wTempBank]
    rst Bankswitch
    ld a, [hli]
    ld h, [hl]
    ld l, a
    pop af
    rst Bankswitch
    ret
