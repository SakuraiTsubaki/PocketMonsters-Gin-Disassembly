import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]
PREFIX = "gin"
KOREAN_RELEASE = "silver-ko-rev0"


class StandardFontLoaderTests(unittest.TestCase):
    def setUp(self):
        self.project = json.loads((ROOT / "project.json").read_text())
        self.source = (ROOT / "src/load_standard_font.asm").read_text()
        self.manifest = json.loads((ROOT / "manifests/standard-font-loaders.json").read_text())

    def reports(self):
        for release in self.project["releases"]:
            path = ROOT / f"analysis/{release['id']}-standard-font-loader.json"
            yield release, json.loads(path.read_text())

    def test_every_release_is_identity_gated(self):
        self.assertEqual(len(list(self.reports())), len(self.project["releases"]))
        for release, report in self.reports():
            self.assertEqual(report["source_sha256"], release["sha256"])
            self.assertFalse(report["raw_bytes_published"])
            self.assertEqual(report["loader_offset"], 0xF8000)
            self.assertEqual(report["font"]["destination"], 0x8800)
            self.assertEqual(report["font"]["tile_count"], 128)

    def test_korean_initializer_is_preserved(self):
        for release, report in self.reports():
            if release["id"] == KOREAN_RELEASE:
                self.assertEqual(report["code_length"], 16)
                self.assertEqual(report["font"]["source_offset"], 0xF82F5)
                self.assertEqual(report["initializer_call"]["target"], 0x1470)
            else:
                self.assertEqual(report["code_length"], 13)
                self.assertEqual(report["font"]["source_offset"], 0xF82F2)
                self.assertIsNone(report["initializer_call"])

    def test_reconstruction_covers_three_families(self):
        self.assertIn("LoadStandardFont_Japanese::", self.source)
        self.assertIn("LoadStandardFont_Global::", self.source)
        self.assertIn("LoadStandardFont_Korean::", self.source)
        self.assertIn("call SetStandardHangulFont", self.source)

    def test_manifest_hashes_outputs(self):
        self.assertFalse(self.manifest["raw_rom_bytes_included"])
        for output in self.manifest["outputs"]:
            self.assertEqual(
                hashlib.sha256((ROOT / output["path"]).read_bytes()).hexdigest(),
                output["sha256"],
            )


if __name__ == "__main__":
    unittest.main()

