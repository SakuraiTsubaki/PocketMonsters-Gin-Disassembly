import csv
import hashlib
import json
import pathlib
import unittest


ROOT = pathlib.Path(__file__).parents[1]


class ClearBoxReconstructionTests(unittest.TestCase):
    def test_release_matrix_and_evidence(self):
        summary = json.loads((ROOT / "analysis/clear-box-summary.json").read_text())
        with (ROOT / "research/releases.csv").open(encoding="utf-8", newline="") as handle:
            catalog = list(csv.DictReader(handle))
        self.assertEqual(summary["axis"], "Disassembly")
        self.assertEqual(summary["release_count"], len(catalog))
        self.assertEqual(summary["origin_reference"], catalog[0]["id"])
        self.assertEqual(catalog[0]["language"], "Japanese")
        languages = [item["language"] for item in catalog]
        if "Korean" in languages:
            self.assertLess(languages.index("Korean"), languages.index("English"))
        for release in summary["releases"]:
            evidence = json.loads((ROOT / release["evidence"]).read_text())
            self.assertEqual(evidence["target"]["sha256"], release["sha256"])
            self.assertEqual(evidence["verified_behavior"]["blank_tile_value"], 0x7F)
            self.assertEqual(evidence["verified_behavior"]["row_stride"], 20)
            self.assertFalse(evidence["raw_rom_bytes_included"])
            if release["language"] == "Korean":
                self.assertEqual(evidence["verified_behavior"]["attribute_bit_cleared"], 3)
                self.assertEqual(evidence["function"]["farcall"]["target_bank"], 0x7F)
                self.assertIn("KoreanClearBox", evidence["related_functions"])

    def test_manifest_hashes_outputs(self):
        manifest = json.loads((ROOT / "manifests/clear-box-reconstruction.json").read_text())
        self.assertFalse(manifest["raw_rom_bytes_included"])
        for output in manifest["outputs"]:
            self.assertEqual(hashlib.sha256((ROOT / output["path"]).read_bytes()).hexdigest(),
                             output["sha256"])

    def test_source_preserves_global_and_korean_paths(self):
        source = (ROOT / "src/clear_box.asm").read_text()
        for token in ("ClearBox::", "IF DEF(_KOREAN)", "farcall_reg KoreanClearBox",
                      "KoreanClearBox::", "ld de, $0940", "res 3, [hl]",
                      "ld de, SCREEN_WIDTH"):
            self.assertIn(token, source)


if __name__ == "__main__":
    unittest.main()
