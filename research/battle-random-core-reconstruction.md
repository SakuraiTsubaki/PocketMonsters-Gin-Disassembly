# Silver _BattleRandom core reconstruction

The target reached by every verified Silver `BattleRandom` wrapper was decoded independently from all eight SHA-256-gated ROMs. Each is the complete 55-byte routine: non-link battles tail-jump to `Random`; link battles consume a shared ten-byte stream and refresh all seeds using `seed = (seed * 5 + 1) mod 256` at the boundary.

Japanese rev0/rev1 use `$0f:$6c31`, link mode `$d03c`, count `$cbb7`, and seeds `$d0d5`. Korean uses `$0f:$6c62`, `$d0fd`, `$cbcb`, and `$d1a0`. Western releases use `$d042`, `$cbc3`, and `$d0e3`; French uses routine address `$6c13`, while the others use `$6c11`. Matching Gold layouts were verified from Silver inputs rather than copied.

The basis is `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `engine/battle/core.asm`. Only reproducible source, structure, and hashes are published. Review order is Japanese, Korean, English, then the remaining official languages.
