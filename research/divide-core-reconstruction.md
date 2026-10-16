# Silver _Divide core reconstruction

The verified `Divide` homecall target begins a complete 131-byte bank 1 routine in all eight Silver releases. Japanese rev0/rev1 are the origin reference; Korean, English, German, Spanish, French, and Italian releases share the same full code hash as Gold and the same HRAM layout. The routine implements restoring long division for one to four big-endian dividend bytes, producing a four-byte quotient and one-byte remainder. Silver uses `hDivisor`/`hRemainder` at `$ffb9` and `hDividend`/`hQuotient` at `$ffb5..$ffb8`.

Naming and control flow follow `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `engine/math/math.asm`. The verifier proves the full terminal path and final `ret`; reports contain decoded addresses and hashes, not ROM bytes.
