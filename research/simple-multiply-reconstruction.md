# Silver SimpleMultiply reconstruction

All eight verified Silver releases contain the same complete 11-byte `SimpleMultiply` routine immediately before `SimpleDivide`. It returns immediately for a zero multiplicand; otherwise it preserves BC and computes the 8-bit product by adding C exactly A times. The reports retain each release-specific home-bank address and prove the shared code hash without publishing ROM bytes.

Naming and control-flow semantics follow `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `home/math.asm`.
