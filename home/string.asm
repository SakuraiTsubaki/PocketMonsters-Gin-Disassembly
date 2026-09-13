InitString::
	push hl
	jr _InitString

InitName::
	push hl
	ld c, NAME_LENGTH - 1

_InitString::
	push bc
.loop
	ld a, [hli]
	cp '@'
	jr z, .blank
IF DEF(_KOREAN)
	cp $c
	jr nc, .single_byte
	cp $b
	jr nz, .notblank
	dec c
	jr z, .blank
	ld a, [hli]
	cp $ff
	jr nz, .notblank
	jr .next
.single_byte
	cp ' '
	jr nz, .notblank
.next
	dec c
	jr nz, .loop
ELSE
IF DEF(_JAPANESE)
	cp '　'
ELSE
	cp ' '
ENDC
	jr nz, .notblank
	dec c
	jr nz, .loop
ENDC
.blank
	pop bc
	ld l, e
	ld h, d
	pop de
	ld b, 0
	inc c
	call CopyBytes
	ret

.notblank
	pop bc
	pop hl
	ret
