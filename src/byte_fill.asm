SECTION "ByteFill Reconstruction", ROM0

ByteFill::
    inc b
    inc c
    jr .handle_loop
.put_byte
    ld [hli], a
.handle_loop
    dec c
    jr nz, .put_byte
    dec b
    jr nz, .put_byte
    ret
