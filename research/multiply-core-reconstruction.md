# Silver _Multiply core reconstruction

The `Multiply` far-call target and `Divide` homecall target bound an exact 96-byte bank 1 routine in all eight verified Silver releases. Every release has the same code hash as Gold and the same HRAM layout (`hMultiplier` at `$ffb9`, four-byte `hProduct` at `$ffb5..$ffb8`). The routine performs eight shift-add iterations over a three-byte big-endian multiplicand and writes a four-byte product.

The Japanese builds are the origin reference; Korean, English, German, Spanish, French, and Italian binaries independently match the complete control-flow and operand-layout verifier. Naming follows `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `engine/math/math.asm`. Reports contain hashes and decoded addresses, not ROM bytes.
