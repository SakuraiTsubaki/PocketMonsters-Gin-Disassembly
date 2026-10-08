import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]


class JapaneseMainFontTests(unittest.TestCase):
    def setUp(self):
        self.report = json.loads((ROOT / "analysis/gin-jp-main-font.json").read_text(encoding="utf-8"))
        self.manifest = json.loads((ROOT / "manifests/japanese-main-font.json").read_text(encoding="utf-8"))

    def test_range_and_both_revisions(self):
        self.assertEqual((self.report["source_offset"], self.report["source_length"]), (0xF82F2, 1024))
        self.assertEqual(self.report["source_sha256"], "0902d141b40af70008d3176cf4cc13f5d5a10812ffaf08ecee5752fa7e31b8ca")
        self.assertEqual([x["id"] for x in self.manifest["releases"]], ["gin-jp-rev0", "gin-jp-rev1"])
        self.assertEqual({x["range_sha256"] for x in self.manifest["releases"]}, {self.report["source_sha256"]})

    def test_outputs_are_bound_without_raw_rom(self):
        self.assertFalse(self.manifest["raw_rom_bytes_included"])
        for output in self.manifest["outputs"]:
            self.assertEqual(hashlib.sha256((ROOT / output["path"]).read_bytes()).hexdigest(), output["sha256"])
        self.assertEqual(hashlib.sha256((ROOT / "graphics/font/main-font-jp.png").read_bytes()).hexdigest(), self.report["png_sha256"])


if __name__ == "__main__":
    unittest.main()
