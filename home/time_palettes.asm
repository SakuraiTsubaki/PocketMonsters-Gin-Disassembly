UpdateTimeAndPals::
; Update time and time-sensitive palettes.
	ld a, [wSpriteUpdatesEnabled]
	cp FALSE
	ret z

	call UpdateTime

	ld a, [wStateFlags]
	bit SPRITE_UPDATES_DISABLED_F, a
	ret z

TimeOfDayPals::
	callfar _TimeOfDayPals
	ret

UpdateTimePals::
	callfar _UpdateTimePals
	ret
