# Silver SubtractAbsolute reconstruction

All eight verified Silver releases contain the same complete seven-byte routine immediately after `Divide`. The nonnegative path returns `A - B` with carry clear. The negative path takes the two's complement of the wrapped subtraction, returns `B - A`, and explicitly sets carry. The reference source marks the function unreferenced; that status is recorded rather than treated as proof that no retail path can reach it.

Naming and semantics follow `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `home/math.asm`. Reports retain addresses and hashes without publishing ROM bytes.
