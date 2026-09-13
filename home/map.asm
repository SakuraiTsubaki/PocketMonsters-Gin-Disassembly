; Bank 00 map source selector.
; These pinned references are temporary provenance-locked sources while the
; final self-contained vendoring pass is prepared. No ROM/base-ROM input is used.
;
; Western Silver releases share the pret/pokegold map engine source layout.
; Japanese Silver uses Narishma-gb/pokesilver, whose retail difference here is
; chiefly the three inline default event strings.
; Korean Silver uses Narishma-gb/pokegold-kr; its apparent +42-byte component
; delta in the boundary survey comes from Korean farcall helpers and
; DummyEndPredef placed immediately before FarCall_hl, not from opaque map data.

IF DEF(_JAPANESE)
	INCLUDE "reference/pokesilver/home/map.asm"
ELIF DEF(_KOREAN)
	INCLUDE "reference/pokegold-kr/home/map.asm"
ELSE
	INCLUDE "reference/pokegold/home/map.asm"
ENDC
