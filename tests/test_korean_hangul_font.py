import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]


class KoreanHangulFontTests(unittest.TestCase):
    def setUp(self):
        self.manifest = json.loads((ROOT / "manifests/korean-hangul-font.json").read_text(encoding="utf-8"))

    def test_verified_retail_identity_and_complete_table_set(self):
        self.assertEqual(self.manifest["release"], "silver-ko-rev0")
        self.assertEqual(self.manifest["rom_sha256"], "ebbac63c0c4309c82dbb6723e7163369784f962b4fd3e2f486075307c3008a22")
        self.assertEqual([item["table"] for item in self.manifest["artifacts"]], list("0123456789a"))

    def test_reports_bind_pngs_to_safe_source_ranges(self):
        for item in self.manifest["artifacts"]:
            report = json.loads((ROOT / item["report"]).read_text(encoding="utf-8"))
            png = (ROOT / item["png"]).read_bytes()
            self.assertEqual(report["rom_sha256"], self.manifest["rom_sha256"])
            self.assertEqual(report["source_offset"], int(item["offset"], 0))
            self.assertEqual(report["source_length"], 4096)
            self.assertEqual(report["tile_count"], 512)
            self.assertEqual(report["tiles_per_row"], 16)
            self.assertEqual((report["logical_width"], report["logical_height"]), (128, 256))
            self.assertEqual(hashlib.sha256(png).hexdigest(), report["png_sha256"])
            self.assertNotIn("source_bytes", report)

    def test_table_zero_duplicate_is_hash_linked(self):
        report = json.loads((ROOT / "analysis/gin-ko-hangul-table-0.json").read_text(encoding="utf-8"))
        self.assertEqual(report["source_sha256"], self.manifest["layout"]["duplicate_table_0"]["sha256"])


if __name__ == "__main__":
    unittest.main()
