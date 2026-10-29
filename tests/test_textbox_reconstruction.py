import hashlib, json, pathlib, unittest

ROOT = pathlib.Path(__file__).parents[1]

class TextboxReconstructionTests(unittest.TestCase):
    def test_releases_and_korean_variant(self):
        summary = json.loads((ROOT / "analysis/textbox-summary.json").read_text())
        self.assertEqual(summary["release_count"], 8)
        for release in summary["releases"]:
            evidence = json.loads((ROOT / release["evidence"]).read_text())
            self.assertEqual(evidence["target"]["sha256"], release["sha256"])
            self.assertEqual(evidence["verified_behavior"]["palette_value"], 7)
            self.assertFalse(evidence["raw_rom_bytes_included"])
            if release["language"] == "Korean":
                self.assertEqual(evidence["variant"], "korean-farcall-suite")
                self.assertEqual(evidence["functions"]["KoreanTextbox"]["bank"], 0x7F)
    def test_manifest(self):
        m = json.loads((ROOT / "manifests/textbox-reconstruction.json").read_text())
        for item in m["outputs"]:
            self.assertEqual(hashlib.sha256((ROOT / item["path"]).read_bytes()).hexdigest(), item["sha256"])
    def test_source(self):
        s = (ROOT / "src/textbox.asm").read_text()
        for token in ("Textbox::", "KoreanTextbox::", "TextboxBorder::", "TextboxPalette::"):
            self.assertIn(token, s)

if __name__ == "__main__": unittest.main()
