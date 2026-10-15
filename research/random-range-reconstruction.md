# Silver RandomRange reconstruction

All eight verified Silver ROMs contain the complete 26-byte `RandomRange` immediately after `BattleRandom`. For a nonzero exclusive upper bound in A, it rejects the incomplete high tail before division, preventing modulo bias. Every dependency address is taken from the same Silver release rather than inferred from Gold.

Japanese rev0/rev1 place it at `$3083`; Korean at `$3160`; English `$30c7`; German `$30f4`; Spanish `$30eb`; French `$30d9`; Italian `$30ec`. All use `hRandomAdd=$ffe3`; `Random` and `SimpleDivide` addresses remain release-specific in the reports.

The basis is `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `home/random.asm`. No ROM bytes are published.
