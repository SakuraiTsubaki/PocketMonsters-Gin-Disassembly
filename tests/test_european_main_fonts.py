import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]
GAME = "gin"


class EuropeanMainFontTests(unittest.TestCase):
    def setUp(self):
        self.manifest = json.loads((ROOT / "manifests/european-main-fonts.json").read_text(encoding="utf-8"))
        self.reports = {lang: json.loads((ROOT / f"analysis/{GAME}-{lang}-main-font.json").read_text(encoding="utf-8")) for lang in ("de", "fr", "es", "it")}

    def test_ranges_and_releases(self):
        self.assertEqual(set(self.manifest["releases"]), set(self.reports))
        for lang, report in self.reports.items():
            release = self.manifest["releases"][lang]
            self.assertEqual(report["rom_sha256"], release["sha256"])
            self.assertEqual((report["source_offset"], report["source_length"]), (0xF82F2, 1024))
            self.assertEqual(report["source_sha256"], release["range_sha256"])

    def test_language_families_and_outputs(self):
        self.assertEqual(self.reports["de"]["source_sha256"], self.reports["fr"]["source_sha256"])
        self.assertEqual(self.reports["es"]["source_sha256"], self.reports["it"]["source_sha256"])
        self.assertNotEqual(self.reports["de"]["source_sha256"], self.reports["es"]["source_sha256"])
        self.assertFalse(self.manifest["raw_rom_bytes_included"])
        for output in self.manifest["outputs"]:
            self.assertEqual(hashlib.sha256((ROOT / output["path"]).read_bytes()).hexdigest(), output["sha256"])


if __name__ == "__main__":
    unittest.main()
