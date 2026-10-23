import hashlib
import json
import struct
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]
RELEASE_COUNT = 8
SOURCE_SHA256 = "c06b31c95d7bd0c80b17ca9d1a7e7d55c1cb0f2f4f0eb302e5c1d7547f755c77"


class PartyIconTests(unittest.TestCase):
    def test_atlas_and_release_evidence(self):
        summary = json.loads((ROOT / "analysis/party-icons-summary.json").read_text())
        layout = json.loads((ROOT / summary["layout"]).read_text())
        self.assertEqual((summary["release_count"], summary["source_sha256"], summary["icon_count"]), (RELEASE_COUNT, SOURCE_SHA256, 38))
        self.assertEqual(sum(item["origin_reference"] for item in summary["releases"]), 1)
        self.assertIn("Korean", [item["language"] for item in summary["releases"]])
        self.assertEqual((layout["icon_count"], layout["icons_per_row"]), (38, 8))
        png = (ROOT / summary["png"]).read_bytes()
        self.assertEqual(struct.unpack(">II", png[16:24]), (256, 320))
        for item in summary["releases"]:
            report = json.loads((ROOT / item["evidence"]).read_text())
            self.assertEqual((report["target"]["sha256"], report["asset"]["source_sha256"], report["asset"]["icon_count"]), (item["sha256"], SOURCE_SHA256, 38))
            self.assertFalse(report["raw_rom_bytes_included"])

    def test_manifest_hashes(self):
        manifest = json.loads((ROOT / "manifests/party-icons.json").read_text())
        for output in manifest["outputs"]:
            self.assertEqual(hashlib.sha256((ROOT / output["path"]).read_bytes()).hexdigest(), output["sha256"])


if __name__ == "__main__":
    unittest.main()
