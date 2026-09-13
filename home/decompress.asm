FarDecompress::
; Decompress graphics data from a:hl to de.
	ld [wLZBank], a
	ldh a, [hROMBank]
	push af
	ld a, [wLZBank]
	rst Bankswitch

	call Decompress

	pop af
	rst Bankswitch
	ret

Decompress::
; Pokémon G/S uses an LZ3 variant. This routine is opcode-identical
; across all eight mapped Silver releases; only linked operands relocate.

DEF LZ_END EQU $ff
DEF LZ_CMD EQU %11100000
DEF LZ_LEN EQU %00011111
DEF LZ_LITERAL   EQU 0 << 5
DEF LZ_ITERATE   EQU 1 << 5
DEF LZ_ALTERNATE EQU 2 << 5
DEF LZ_ZERO      EQU 3 << 5
DEF LZ_RW        EQU 2 + 5
DEF LZ_REPEAT    EQU 4 << 5
DEF LZ_FLIP      EQU 5 << 5
DEF LZ_REVERSE   EQU 6 << 5
DEF LZ_LONG      EQU 7 << 5
DEF LZ_LONG_HI   EQU %00000011

	ld a, e
	ld [wLZAddress], a
	ld a, d
	ld [wLZAddress + 1], a

.Main:
	ld a, [hl]
	cp LZ_END
	ret z

	and LZ_CMD
	cp LZ_LONG
	jr nz, .short

	ld a, [hl]
	add a
	add a
	add a
	and LZ_CMD
	push af

	ld a, [hli]
	and LZ_LONG_HI
	ld b, a
	ld a, [hli]
	ld c, a
	inc bc
	jr .command

.short
	push af
	ld a, [hli]
	and LZ_LEN
	ld c, a
	ld b, 0
	inc c

.command
	inc b
	inc c
	pop af

	bit LZ_RW, a
	jr nz, .rewrite
	cp LZ_ITERATE
	jr z, .Iter
	cp LZ_ALTERNATE
	jr z, .Alt
	cp LZ_ZERO
	jr z, .Zero

.lloop
	dec c
	jr nz, .lnext
	dec b
	jp z, .Main
.lnext
	ld a, [hli]
	ld [de], a
	inc de
	jr .lloop

.Iter
	ld a, [hli]
.iloop
	dec c
	jr nz, .inext
	dec b
	jp z, .Main
.inext
	ld [de], a
	inc de
	jr .iloop

.Alt
	dec c
	jr nz, .anext1
	dec b
	jp z, .adone1
.anext1
	ld a, [hli]
	ld [de], a
	inc de

	dec c
	jr nz, .anext2
	dec b
	jp z, .adone2
.anext2
	ld a, [hld]
	ld [de], a
	inc de
	jr .Alt
.adone1
	inc hl
.adone2
	inc hl
	jr .Main

.Zero
	xor a
.zloop
	dec c
	jr nz, .znext
	dec b
	jp z, .Main
.znext
	ld [de], a
	inc de
	jr .zloop

.rewrite
	push hl
	push af
	ld a, [hli]
	bit 7, a
	jr z, .positive

	and %01111111
	cpl
	add e
	ld l, a
	ld a, -1
	adc d
	ld h, a
	jr .ok

.positive
	ld l, [hl]
	ld h, a
	ld a, [wLZAddress]
	add l
	ld l, a
	ld a, [wLZAddress + 1]
	adc h
	ld h, a

.ok
	pop af
	cp LZ_REPEAT
	jr z, .Repeat
	cp LZ_FLIP
	jr z, .Flip
	cp LZ_REVERSE
	jr z, .Reverse

.Repeat
	dec c
	jr nz, .rnext
	dec b
	jr z, .donerw
.rnext
	ld a, [hli]
	ld [de], a
	inc de
	jr .Repeat

.Flip
	dec c
	jr nz, .fnext
	dec b
	jp z, .donerw
.fnext
	ld a, [hli]
	push bc
	lb bc, 0, 8
.floop
	rra
	rl b
	dec c
	jr nz, .floop
	ld a, b
	pop bc
	ld [de], a
	inc de
	jr .Flip

.Reverse
	dec c
	jr nz, .rvnext
	dec b
	jp z, .donerw
.rvnext
	ld a, [hld]
	ld [de], a
	inc de
	jr .Reverse

.donerw
	pop hl
	bit 7, [hl]
	jr nz, .next
	inc hl
.next
	inc hl
	jp .Main
