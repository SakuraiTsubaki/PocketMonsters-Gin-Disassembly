; Bank 00 reset/RST/interrupt vectors and cartridge entry point.
; Shared across supported Silver releases, with verified Korean timing helpers.

SECTION "rst0", ROM0[$0000]
	di
	jp Start

SECTION "rst8", ROM0[$0008]
FarCall::
	jp FarCall_hl

SECTION "rst10", ROM0[$0010]
Bankswitch::
	ldh [hROMBank], a
	ld [rROMB], a
	ret

IF DEF(_KOREAN)
SECTION "rst18-rst20", ROM0[$0018]
WaitHBlank::
; If already in HBlank, wait for the next scanline.
	ldh a, [rSTAT]
	and STAT_MODE
	jr z, WaitHBlank
.loop
	ldh a, [rSTAT]
	and STAT_MODE
	jr nz, .loop
	ret
ELSE
SECTION "rst18", ROM0[$0018]
	rst $38

SECTION "rst20", ROM0[$0020]
	rst $38
ENDC

SECTION "rst28", ROM0[$0028]
JumpTable::
	push de
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de
	jp hl

SECTION "rst38", ROM0[$0038]
IF DEF(_KOREAN)
	nop
WaitOneLine::
; In double-speed mode this delay returns after approximately one scanline.
	ld a, $39
.loop
	dec a
	jr nz, .loop
	ret
ELSE
	rst $38
ENDC

; Game Boy hardware interrupts.
SECTION "vblank", ROM0[$0040]
	jp VBlank

SECTION "lcd", ROM0[$0048]
	jp LCD

SECTION "timer", ROM0[$0050]
	reti

SECTION "serial", ROM0[$0058]
	jp Serial

SECTION "joypad", ROM0[$0060]
	jp Joypad

SECTION "Header", ROM0[$0100]
Start::
	nop
	jp _Start

; rgbfix will patch the cartridge header fields in this reserved area.
	ds $0150 - @, $00

ENDSECTION
