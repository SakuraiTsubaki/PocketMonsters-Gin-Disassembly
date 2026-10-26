; Generation II byte-copy routine across all catalogued Silver releases.
; Japanese is the origin reference; Korean precedes English and European releases.

CopyBytes::
    inc b
    inc c
    jr .HandleLoop
.CopyByte:
    ld a, [hli]
    ld [de], a
    inc de
.HandleLoop:
    dec c
    jr nz, .CopyByte
    dec b
    jr nz, .CopyByte
    ret
