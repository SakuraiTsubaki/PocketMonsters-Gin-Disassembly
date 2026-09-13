PrinterReceive::
	homecall _PrinterReceive
	ret

AskSerial::
; Send a handshake while the serial interrupt is off.
	ld a, [wPrinterConnectionOpen]
	bit PRINTER_CONNECTION_OPEN, a
	ret z
	ld a, [wPrinterOpcode]
	and a
	ret nz
	ld hl, wHandshakeFrameDelay
	inc [hl]
	ld a, [hl]
	cp 6
	ret c
	xor a
	ld [hl], a
	ld a, $0c
	ld [wPrinterOpcode], a
	ld a, $88
	ldh [rSB], a
	ld a, SC_INTERNAL
	ldh [rSC], a
	ld a, SC_START | SC_INTERNAL
	ldh [rSC], a
	ret
