# Bank 00 map source delta

This document records the source-level comparison used to collapse the three vendored Bank 00 map snapshots.

The comparison is intentionally separate from raw ROM-byte alignment. Earlier Bank 00 components move labels between releases, so absolute operands inside otherwise identical map logic can differ after linking.

## Baselines

| source | pinned provenance | role |
| --- | --- | --- |
| `home/map_variants/western.asm` | `pret/pokegold` @ `656583c939d30f920a316177311a502dd222b57c` | shared structural baseline |
| `home/map_variants/japanese.asm` | `Narishma-gb/pokesilver` @ `edbe53978ef1777fc5c41019e17b7544070eab92` | Japanese source reference |
| `home/map_variants/korean.asm` | `Narishma-gb/pokegold-kr` @ `f4496dda3003ccc5fc26f2757171a3b111e65307` | Korean source reference |

## Korean versus Western

Ignoring the provenance comment, the Korean snapshot has only one source-text addition relative to the Western baseline:

```asm
DummyEndPredef::
; Unused function at the end of PredefPointers.
rept 16
	nop
endr
	ret
```

No separate Korean body of map logic is required. `home/map.asm` therefore compiles the Western baseline for Korean and appends this exact `_KOREAN` block. The historical Korean snapshot remains in `home/map_variants/` as provenance and a regression reference, but it is no longer the compiled source path.

The ROM-level Korean map component is still larger than the Western component. That additional binary delta must not be misread as 42 bytes of different map logic: regional definitions, macro expansion, relocated operands, and the component-boundary placement around the far-call/predef helpers all contribute. Final truth remains byte-identical assembly against the preserved Korean ROM.

## Japanese versus Western

Ignoring the provenance comment, the retail Japanese map source differs in only three map-event text stubs. Western releases use far text:

```asm
ObjectEventText::
	text_far _ObjectEventText
	text_end

BGEventText::
	text_far _BGEventText
	text_end

CoordinatesEventText::
	text_far _CoordinatesEventText
	text_end
```

Japanese uses inline text instead:

```asm
ObjectEventText::
	text "オブジェイベント"
	done

BGEventText::
	text "ビージーイベント"
	done

CoordinatesEventText::
	text "ざひょうイベント"
	done
```

The Japanese snapshot also contains a script-pointer validation/debug block guarded by `IF DEF(_DEBUG)`. It does not contribute to retail builds and is not a retail region delta.

The Japanese Rev 0 and Rev A map components are byte-identical, so the final shared map source must not introduce a revision branch for this component.

## Current collapse state

- Western releases: compile `home/map_variants/western.asm`.
- Korean: compile the same Western baseline plus the exact `_KOREAN` `DummyEndPredef` tail.
- Japanese: still compiles the Japanese vendored snapshot while the three inline text stubs are moved into narrow `_JAPANESE` conditionals in the common source.

This is deliberately incremental: every collapse step keeps the original snapshots available until assembly verification proves the common source reproduces the preserved retail bytes.

## Completion gate

The map source is considered fully collapsed only when:

1. one common map source contains all retail logic;
2. region differences are limited to narrow `_JAPANESE` / `_KOREAN` blocks;
3. JP Rev 0 and Rev A use the same map path;
4. all eight Bank 00 builds assemble cleanly; and
5. the linked map component matches each preserved ROM byte-for-byte.
