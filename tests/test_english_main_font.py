import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]


class EnglishMainFontTests(unittest.TestCase):
    def setUp(self):
        self.report = json.loads((ROOT / "analysis/gin-en-main-font.json").read_text(encoding="utf-8"))
        self.manifest = json.loads((ROOT / "manifests/english-main-font.json").read_text(encoding="utf-8"))

    def test_range_and_release(self):
        self.assertEqual((self.report["source_offset"], self.report["source_length"]), (0xF82F2, 1024))
        self.assertEqual(self.report["source_sha256"], "6e2437dd65c8f64b0a97c982ff1f8315a60d43cf88be0ca9cee81508692172d7")
        self.assertEqual([x["id"] for x in self.manifest["releases"]], ["silver-en-rev0"])

    def test_outputs(self):
        self.assertFalse(self.manifest["raw_rom_bytes_included"])
        for output in self.manifest["outputs"]:
            self.assertEqual(hashlib.sha256((ROOT / output["path"]).read_bytes()).hexdigest(), output["sha256"])
        self.assertEqual(hashlib.sha256((ROOT / "graphics/font/main-font-en.png").read_bytes()).hexdigest(), self.report["png_sha256"])


if __name__ == "__main__":
    unittest.main()
