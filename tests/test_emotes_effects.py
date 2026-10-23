import hashlib
import json
import struct
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]
COUNT = 8
SOURCE_SHA256 = "24108a3d88e346484161dc651c67df97f0ff2e0eaacdc1d3d53e7bc815e32b6d"


class EmoteEffectTests(unittest.TestCase):
    def test_assets_and_releases(self):
        summary = json.loads((ROOT / "analysis/emotes-effects-summary.json").read_text())
        layout = json.loads((ROOT / summary["layout"]).read_text())
        self.assertEqual((summary["release_count"], summary["source_sha256"]), (COUNT, SOURCE_SHA256))
        self.assertEqual((summary["emote_count"], summary["field_effect_count"]), (8, 4))
        self.assertIn("Korean", [item["language"] for item in summary["releases"]])
        self.assertEqual(sum(item["origin_reference"] for item in summary["releases"]), 1)
        self.assertEqual(len(layout["assets"]), 12)
        self.assertEqual(struct.unpack(">II", (ROOT / summary["emotes_png"]).read_bytes()[16:24]), (128, 64))
        self.assertEqual(struct.unpack(">II", (ROOT / summary["effects_png"]).read_bytes()[16:24]), (64, 32))
        for item in summary["releases"]:
            report = json.loads((ROOT / item["evidence"]).read_text())
            self.assertEqual((report["target"]["sha256"], report["asset"]["source_sha256"]), (item["sha256"], SOURCE_SHA256))
            self.assertFalse(report["raw_rom_bytes_included"])

    def test_manifest_hashes(self):
        manifest = json.loads((ROOT / "manifests/emotes-effects.json").read_text())
        for output in manifest["outputs"]:
            self.assertEqual(hashlib.sha256((ROOT / output["path"]).read_bytes()).hexdigest(), output["sha256"])


if __name__ == "__main__":
    unittest.main()
