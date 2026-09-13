OpenSRAM::
; Switch to SRAM bank a.
	push af
IF DEF(_KOREAN)
	; Korean retail rejects banks above 3 and tracks the active bank.
	cp 4
	jr c, .valid_bank
	pop af
	jr CloseSRAM

.valid_bank
ENDC
	ld a, 1
	ld [rRTCLATCH], a
	ld a, RAMG_SRAM_ENABLE
	ld [rRAMG], a
	pop af
	ld [rRAMB], a
IF DEF(_KOREAN)
	ld [wSRAMBank], a
ENDC
	ret

CloseSRAM::
	push af
	ld a, RAMG_SRAM_DISABLE
	ld [rRTCLATCH], a
	ld [rRAMG], a
IF DEF(_KOREAN)
	ld a, $ff
	ld [wSRAMBank], a
ENDC
	pop af
	ret
