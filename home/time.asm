; Functions relating to the timer interrupt and the real-time clock.
; JP Silver omits one CCF in FixDays.quit; all other mapped releases retain it.

Timer:: ; unreferenced
	reti

LatchClock::
	ld a, 0
	ld [rRTCLATCH], a
	ld a, 1
	ld [rRTCLATCH], a
	ret

UpdateTime::
	call GetClock
	call FixDays
	call FixTime
	farcall GetTimeOfDay
	ret

GetClock::
	ld a, RAMG_SRAM_ENABLE
	ld [rRAMG], a

	call LatchClock
	ld hl, rRAMB
	ld de, rRTCREG

	ld [hl], RAMB_RTC_S
	ld a, [de]
	maskbits 60
	ldh [hRTCSeconds], a

	ld [hl], RAMB_RTC_M
	ld a, [de]
	maskbits 60
	ldh [hRTCMinutes], a

	ld [hl], RAMB_RTC_H
	ld a, [de]
	maskbits 24
	ldh [hRTCHours], a

	ld [hl], RAMB_RTC_DL
	ld a, [de]
	ldh [hRTCDayLo], a

	ld [hl], RAMB_RTC_DH
	ld a, [de]
	ldh [hRTCDayHi], a

	call CloseSRAM
	ret

FixDays::
	ldh a, [hRTCDayHi]
	bit B_RAMB_RTC_DH_HIGH, a
	jr z, .daylo
	res B_RAMB_RTC_DH_HIGH, a
	ldh [hRTCDayHi], a

	ldh a, [hRTCDayLo]
.modh
	sub 140
	jr nc, .modh
.modl
	sub 140
	jr nc, .modl
	add 140

	ldh [hRTCDayLo], a
	ld a, RTC_DAYS_EXCEED_255
	jr .set

.daylo
	ldh a, [hRTCDayLo]
	cp 140
	jr c, .quit

.mod
	sub 140
	jr nc, .mod
	add 140

	ldh [hRTCDayLo], a
	ld a, RTC_DAYS_EXCEED_139

.set
	push af
	call SetClock
	pop af
	scf
	ret

.quit
IF !DEF(_JAPANESE)
	; Present in KR and western releases, absent in JP Rev 0 / Rev A.
	ccf
ENDC
	xor a
	ret

FixTime::
	ldh a, [hRTCSeconds]
	ld c, a
	ld a, [wStartSecond]
	add c
	sub 60
	jr nc, .updatesec
	add 60
.updatesec
	ldh [hSeconds], a

	ccf
	ldh a, [hRTCMinutes]
	ld c, a
	ld a, [wStartMinute]
	adc c
	sub 60
	jr nc, .updatemin
	add 60
.updatemin
	ldh [hMinutes], a

	ccf
	ldh a, [hRTCHours]
	ld c, a
	ld a, [wStartHour]
	adc c
	sub 24
	jr nc, .updatehr
	add 24
.updatehr
	ldh [hHours], a

	ccf
	ldh a, [hRTCDayLo]
	ld c, a
	ld a, [wStartDay]
	adc c
	ld [wCurDay], a
	ret

InitTimeOfDay::
	xor a
	ld [wStringBuffer2], a
	ld a, 0
	ld [wStringBuffer2 + 3], a
	jr InitTime

InitDayOfWeek::
	call UpdateTime
	ldh a, [hHours]
	ld [wStringBuffer2 + 1], a
	ldh a, [hMinutes]
	ld [wStringBuffer2 + 2], a
	ldh a, [hSeconds]
	ld [wStringBuffer2 + 3], a
	jr InitTime

InitTime::
	farcall _InitTime
	ret

ClearClock::
	call .ClearhRTC
	call SetClock
	ret

.ClearhRTC:
	xor a
	ldh [hRTCSeconds], a
	ldh [hRTCMinutes], a
	ldh [hRTCHours], a
	ldh [hRTCDayLo], a
	ldh [hRTCDayHi], a
	ret

SetClock::
	ld a, RAMG_SRAM_ENABLE
	ld [rRAMG], a

	call LatchClock
	ld hl, rRAMB
	ld de, rRTCREG

	ld [hl], RAMB_RTC_DH
	ld a, [de]
	bit B_RAMB_RTC_DH_HALT, a
	ld [de], a

	ld [hl], RAMB_RTC_S
	ldh a, [hRTCSeconds]
	ld [de], a
	ld [hl], RAMB_RTC_M
	ldh a, [hRTCMinutes]
	ld [de], a
	ld [hl], RAMB_RTC_H
	ldh a, [hRTCHours]
	ld [de], a
	ld [hl], RAMB_RTC_DL
	ldh a, [hRTCDayLo]
	ld [de], a
	ld [hl], RAMB_RTC_DH
	ldh a, [hRTCDayHi]
	res B_RAMB_RTC_DH_HALT, a
	ld [de], a

	call CloseSRAM
	ret

ClearRTCStatus:: ; unreferenced
	xor a
	push af
	ld a, BANK(sRTCStatusFlags)
	call OpenSRAM
	pop af
	ld [sRTCStatusFlags], a
	call CloseSRAM
	ret

RecordRTCStatus::
	ld hl, sRTCStatusFlags
	push af
	ld a, BANK(sRTCStatusFlags)
	call OpenSRAM
	pop af
	or [hl]
	ld [hl], a
	call CloseSRAM
	ret

CheckRTCStatus::
	ld a, BANK(sRTCStatusFlags)
	call OpenSRAM
	ld a, [sRTCStatusFlags]
	call CloseSRAM
	ret
