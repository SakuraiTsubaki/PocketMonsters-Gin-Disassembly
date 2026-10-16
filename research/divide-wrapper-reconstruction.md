# Silver Divide wrapper reconstruction

All eight verified Silver releases contain the complete 18-byte wrapper immediately after `Multiply`. It preserves HL, DE, and BC, saves the active ROM bank through the `homecall` expansion, switches to the release-specific bank 1 `_Divide` target with `RST $10`, calls it, restores the prior bank, restores the registers, and returns. Japanese rev0/rev1 use `hROMBank` at `$ff9f` and target `$01:$6ad5`; Korean targets `$01:$68bd`; the five Western targets are retained per report.

The routine divides `hDividend` (length in B, maximum four bytes) by `hDivisor`, producing `hQuotient` and `hRemainder`. Naming and macro expansion follow `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `home/math.asm` and `macros/farcall.asm`. No ROM bytes are published.
