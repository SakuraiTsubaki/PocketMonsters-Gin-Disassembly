# Bank 00 map source provenance

`home/map.asm` currently selects one of three **commit-pinned public disassembly references**. This is a temporary, provenance-locked bridge used to avoid retyping roughly 2,500 lines of map-engine source by hand before the self-contained vendoring pass.

Pinned references:

- Western baseline (`USA/Europe`, `DE`, `FR`, `IT`, `ES`): `pret/pokegold` @ `656583c939d30f920a316177311a502dd222b57c`
- Japanese Silver (`JP Rev 0`, `JP Rev A`): `Narishma-gb/pokesilver` @ `edbe53978ef1777fc5c41019e17b7544070eab92`
- Korean Silver: `Narishma-gb/pokegold-kr` @ `f4496dda3003ccc5fc26f2757171a3b111e65307`

## What the comparison established

The Western releases have the same Bank 00 map-component length (`3786` bytes). Their differences are therefore treated as relocation/data-address effects until assembly verification proves otherwise.

Japanese Silver has a `+15` byte map-component delta relative to the Western baseline. Source comparison isolates the meaningful retail source difference to the three default event-text stubs: Japanese uses inline strings for Object/BG/Coordinates events, while the Western source uses `text_far` references.

The Korean boundary survey appeared `+42` bytes longer than the Western map component. That does **not** represent 42 bytes of additional map logic. The Korean source places `Function2e73`, `Function2e94`, and `DummyEndPredef` immediately before `FarCall_hl` in `home/farcall.asm`; the signature-based boundary mapper therefore attributed those bytes to the preceding `map` component. The Korean `home/map.asm` logic itself closely follows the Western source.

## Next step

Before declaring the repository fully self-contained, vendor the three pinned `home/map.asm` sources into this repository and collapse them to one common file with narrow `_JAPANESE` / `_KOREAN` conditionals. Then assemble every release and compare Bank 00 byte-for-byte with the preserved originals.

No ROM or base-ROM file is referenced by this mechanism.
