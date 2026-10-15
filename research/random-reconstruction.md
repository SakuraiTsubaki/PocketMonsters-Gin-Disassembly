# Silver Random reconstruction

All eight catalogued Silver releases were SHA-256 gated and scanned independently. Each contains exactly one bank-0 routine matching the complete 19-byte control/data shape of `Random`. Japanese is the origin reference, followed by the official Korean release, English, then German, Spanish, French, and Italian.

Every Silver release uses the same code hash `cfef65875878a56aca6d9293d9d5ec497a7486be8c613263d53fd25a63942def` and HRAM state at `hRandomAdd=$FFE3`, `hRandomSub=$FFE4`; localization only relocates the routine. It samples `DIV`, adds it with carry to the first state byte, subtracts the second state byte with carry from a new `DIV` sample, and returns the updated subtraction state in A.

Names and semantics are corroborated by `pret/pokegold@ef0201d8daf47e8b3ea1518eacf890f37d4cd5e8`, `home/random.asm`. Reports retain identity, address, state and hashes without publishing ROM bytes.
