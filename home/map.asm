; Self-contained Bank 00 map source selector.
; Variant files are exact source snapshots generated from the pinned references.
; A later deduplication pass will collapse common code to narrow region conditionals.

IF DEF(_JAPANESE)
	INCLUDE "home/map_variants/japanese.asm"
ELIF DEF(_KOREAN)
	INCLUDE "home/map_variants/korean.asm"
ELSE
	INCLUDE "home/map_variants/western.asm"
ENDC
