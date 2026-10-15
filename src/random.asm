; Generation II hardware-divider RNG, reconstructed across all catalogued Silver releases.
; Japanese rev0/rev1: $305e; Korean: $313b; English: $30a2;
; German: $30cf; Spanish: $30c6; French: $30b4; Italian: $30c7.

Random::
    push bc
    ldh a, [rDIV]
    ld b, a
    ldh a, [hRandomAdd]
    adc b
    ldh [hRandomAdd], a
    ldh a, [rDIV]
    ld b, a
    ldh a, [hRandomSub]
    sbc b
    ldh [hRandomSub], a
    pop bc
    ret
