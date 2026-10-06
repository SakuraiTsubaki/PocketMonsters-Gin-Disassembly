# Korean startup control flow

The official Korean Silver candidate is analyzed after the Japanese origin reference. Its cartridge entry reaches `$05ca`, five bytes later than Japanese revision zero, and its startup logic is not substituted from the Japanese build.

The Korean path adds a `bit 0, b` mode test after setting the CGB flag. Both mode branches converge at `$05dc`; the shared initialization writes the Korean WRAM flag at `$cec0`, rather than the Japanese `$cf1f`, and then enters the WRAM-clear loop at `$0609`. The depth-three CFG preserves those boundaries without overlapping blocks.

`analysis/gin-ko-startup-cfg.json` is publication-safe: it records instruction semantics, addresses, control-flow edges, and SHA-256 evidence but no verbatim ROM byte strings. `src/startup_ko_cfg.asm` is generated RGBDS reconstruction source. Candidate status is unchanged.
