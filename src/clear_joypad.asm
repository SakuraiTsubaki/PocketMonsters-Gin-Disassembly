SECTION "Clear Joypad Reconstruction", ROM0

ClearJoypad::
    xor a
    ldh [hJoyPressed], a
    ldh [hJoyDown], a
    ret
