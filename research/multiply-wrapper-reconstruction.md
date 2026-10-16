# Silver Multiply wrapper reconstruction

All eight verified Silver releases contain the full 11-byte wrapper immediately after `SimpleDivide`. The home-bank wrapper preserves HL/BC and far-calls a release-specific bank 1 `_Multiply`. Japanese rev0/rev1 target `$01:$6a75`; Korean `$01:$685d`; every Western target differs from the corresponding Gold build and is recorded independently.

The source basis is `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `home/math.asm` and `macros/farcall.asm`. No ROM bytes are published.
