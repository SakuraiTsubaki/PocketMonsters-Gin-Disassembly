; Self-contained Bank 00 map source selector.
;
; Western is the shared structural baseline. Source comparison proved that the
; Korean snapshot differs from it only by the trailing DummyEndPredef block;
; the rest of the Korean byte delta is produced by Korean build definitions and
; macro expansion, not by a separate map logic body. Keep the vendored Korean
; snapshot as provenance/reference, but do not compile a duplicate copy.
;
; Japanese still has a small retail source delta (three inline default event
; strings) plus a _DEBUG-only validation block, so it remains on its vendored
; snapshot until those narrow branches are merged into the common source.

IF DEF(_JAPANESE)
	INCLUDE "home/map_variants/japanese.asm"
ELSE
	INCLUDE "home/map_variants/western.asm"

IF DEF(_KOREAN)
DummyEndPredef::
; Unused function at the end of PredefPointers.
rept 16
	nop
endr
	ret
ENDC
ENDC
