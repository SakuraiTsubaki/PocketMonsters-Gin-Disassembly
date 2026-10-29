import hashlib
import json
import pathlib
import unittest


ROOT = pathlib.Path(__file__).parents[1]


class ClearScreenReconstructionTests(unittest.TestCase):
    def test_release_matrix_and_maps(self):
        summary = json.loads((ROOT / "analysis/clear-screen-summary.json").read_text())
        with (ROOT / "research/releases.csv").open(encoding="utf-8", newline="") as handle:
            catalog = list(__import__("csv").DictReader(handle))
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
            variant = evidence["verified_behavior"]["variant"]
            self.assertEqual(evidence["functions"]["ClearTilemap"]["length"],
                             16 if variant == "korean-split-wait" else 19)
            self.assertEqual(evidence["functions"]["ClearScreen"]["length"],
                             18 if variant == "korean-split-wait" else 13)
            self.assertEqual(evidence["functions"]["ClearTilemap"]["calls"][0]["name"],
                             "ByteFill")
            self.assertEqual(evidence["functions"]["ClearScreen"]["clear_tilemap_transfer"]["name"],
                             "ClearTilemap")
            self.assertEqual(evidence["verified_behavior"]["filled_byte_count_each"], 360)
            self.assertFalse(evidence["raw_rom_bytes_included"])

    def test_manifest_hashes_outputs(self):
        manifest = json.loads((ROOT / "manifests/clear-screen-reconstruction.json").read_text())
        self.assertFalse(manifest["raw_rom_bytes_included"])
        for output in manifest["outputs"]:
            self.assertEqual(hashlib.sha256((ROOT / output["path"]).read_bytes()).hexdigest(),
                             output["sha256"])

    def test_source_preserves_both_clear_paths(self):
        source = (ROOT / "src/clear_screen.asm").read_text()
        for token in ("ClearTilemap::", "ClearScreen::", "call ByteFill",
                      "bit B_LCDC_ENABLE, a", "jp WaitBGMap", "jr ClearTilemap"):
            self.assertIn(token, source)


if __name__ == "__main__":
    unittest.main()
