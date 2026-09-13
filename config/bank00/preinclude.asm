; Bank 00 assembly pre-include.
;
; The pinned reference projects currently provide the regional constants,
; macros, WRAM/HRAM symbols, and baseline charmaps needed to assemble HOME.
; This wrapper selects the appropriate reference include tree and then applies
; only the localized character mappings proven directly from preserved Silver
; ROM bytes.

IF DEF(_KOREAN)
	INCLUDE "reference/pokegold-kr/includes.asm"
ELIF DEF(_JAPANESE)
	INCLUDE "reference/pokesilver/includes.asm"
ELSE
	INCLUDE "reference/pokegold/includes.asm"
ENDC

; Localized Bank 00 weekday strings use glyphs that are not present in the
; pret/pokegold baseline charmap. Values below are verified against the
; preserved Italian/Spanish Silver ROMs; see
; analysis/bank00_regional_charmap_overrides.csv.
IF DEF(_ITALIAN)
	charmap "Ì", $c8
ENDC

IF DEF(_SPANISH)
	charmap "É", $c7
	charmap "Á", $bf
ENDC
