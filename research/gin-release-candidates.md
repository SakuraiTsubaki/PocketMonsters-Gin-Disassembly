# Gin / Silver release candidates

This foundation pass records eight distinct, locally observed retail ROM identities without redistributing ROM bytes. Japanese releases are the origin references, followed by the official Korean release and localized Western releases.

Every entry passed Nintendo logo, header checksum, and global checksum validation with the shared `SakuraiTsubaki/Disassembly` Game Boy ROM inspector. Hashes and decoded headers are synchronized across `project.json`, `research/releases.csv`, and `analysis/gin-release-header-report.json` by automated tests.

All identities remain `candidate`. Valid internal checksums establish that each input is structurally intact; they do not independently prove canonical retail provenance. Promotion to `verified` requires corroboration from an independent trusted reference or a reproducible matching build.

No ROM binary or byte extract is included.
