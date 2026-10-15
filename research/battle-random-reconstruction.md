# Silver BattleRandom reconstruction

All eight catalogued Silver releases were SHA-256 gated and inspected at the byte immediately following the verified `Random` routine. Every release has the complete 18-byte wrapper: save the current ROM bank, switch to bank `$0f`, call `_BattleRandom`, preserve A through WRAM, restore the bank, reload A, and return.

Gold and Silver share these wrapper identities: Japanese rev0/rev1 use `$3071` → `$0f:$6c31` and `$cfd7`; Korean uses `$314e` → `$0f:$6c62` and `$d09d`; English, German, Spanish, and Italian target `$0f:$6c11` with `$cfdd`; French targets `$0f:$6c13`. This equality was established independently from every Silver ROM, not copied from the Gold reports.

The naming basis is `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `home/random.asm`. Reports contain hashes and structural operands, never ROM bytes. Language review order is Japanese, Korean, English, then the other official localizations.
