import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]


class KoreanHangulRendererTests(unittest.TestCase):
    def setUp(self):
        self.manifest = json.loads((ROOT / "manifests/korean-hangul-renderer.json").read_text(encoding="utf-8"))
        self.report = json.loads((ROOT / self.manifest["analysis"]).read_text(encoding="utf-8"))

    def test_release_and_source_are_bound(self):
        self.assertEqual(self.manifest["release"], "silver-ko-rev0")
        self.assertEqual(self.report["rom_sha256"], "ebbac63c0c4309c82dbb6723e7163369784f962b4fd3e2f486075307c3008a22")
        source = (ROOT / self.manifest["implementation"]).read_bytes()
        self.assertEqual(hashlib.sha256(source).hexdigest(), self.report["source_asm_sha256"])

    def test_all_verified_routines_have_consistent_banked_offsets(self):
        self.assertEqual([item["name"] for item in self.report["ranges"]], self.manifest["routines"])
        self.assertEqual(sum(item["length"] for item in self.report["ranges"]), 390)
        for item in self.report["ranges"]:
            start = int(item["cpu_start"], 0)
            end = int(item["cpu_end_exclusive"], 0)
            self.assertEqual(item["length"], end - start)
            self.assertEqual(int(item["file_offset"], 0), 0x7F * 0x4000 + start - 0x4000)
            self.assertEqual(len(item["range_sha256"]), 64)

    def test_public_report_contains_no_rom_bytes(self):
        for item in self.report["ranges"]:
            self.assertNotIn("range_bytes", item)
            self.assertNotIn("raw_bytes", item)
            self.assertNotIn("bytes", item)
        self.assertFalse(self.report["verification"]["raw_bytes_embedded"])

    def test_assembly_exposes_every_verified_label(self):
        source = (ROOT / self.manifest["implementation"]).read_text(encoding="utf-8")
        for name in self.manifest["routines"]:
            self.assertIn(f"_{name}::" if name != "PlaceDoubleByteChar" else f"{name}::", source)


if __name__ == "__main__":
    unittest.main()
