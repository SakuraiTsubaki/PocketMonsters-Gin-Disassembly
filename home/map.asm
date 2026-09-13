; Self-contained Bank 00 map source selector.
;
; Korean and Western retail map logic are source-identical except that the
; Western source has a trailing DummyEndPredef block and the Korean source does
; not. Use the shorter Korean snapshot as the common structural body, then add
; DummyEndPredef only for non-Korean Western builds. Regional macros/constants
; still come from the selected build environment, so this does not impose
; Korean macro expansion on Western releases.
;
; Japanese still has a small retail source delta (three inline default event
; strings) plus a _DEBUG-only validation block, so it remains on its vendored
; snapshot until those narrow branches are merged into the common source.

IF DEF(_JAPANESE)
	INCLUDE "home/map_variants/japanese.asm"
ELSE
	INCLUDE "home/map_variants/korean.asm"

IF !DEF(_KOREAN)
DummyEndPredef::
; Unused function at the end of PredefPointers.
rept 16
	nop
endr
	ret
ENDC
ENDC
