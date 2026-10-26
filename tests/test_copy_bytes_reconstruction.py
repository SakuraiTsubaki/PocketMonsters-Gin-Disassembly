import csv
import hashlib
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
ADDRESSES = {
    "gin-jp-rev0": (0, 0x30D6), "gin-jp-rev1": (0, 0x30D6),
    "silver-ko-rev0": (0, 0x31C2), "silver-en-rev0": (0, 0x311A),
    "silver-de-rev0": (0, 0x3147), "silver-es-rev0": (0, 0x313E),
    "silver-fr-rev0": (0, 0x312C), "silver-it-rev0": (0, 0x313F),
}
CODE_SHA256 = "9364deaa0f942c15dcd1ab29a953a4c5a14c0916e877a9e67cee53dc09e3e028"


class CopyBytesReconstructionTests(unittest.TestCase):
    def test_all_releases(self):
        with (ROOT / "research/releases.csv").open(encoding="utf-8", newline="") as handle:
            releases = {item["id"]: item for item in csv.DictReader(handle)}
        self.assertEqual(set(releases), set(ADDRESSES))
        for release, location in ADDRESSES.items():
            report = json.loads((ROOT / f"analysis/{release}-copy-bytes.json").read_text(encoding="utf-8"))
            function = report["function"]
            self.assertEqual(report["target"]["sha256"], releases[release]["sha256"])
            self.assertEqual((function["bank"], function["address"]), location)
            self.assertEqual((function["length"], function["code_sha256"]), (14, CODE_SHA256))
            self.assertTrue(report["semantics"]["zero_length_supported"])
            self.assertFalse(report["raw_rom_bytes_included"])

    def test_manifest(self):
        manifest = json.loads((ROOT / "manifests/copy-bytes-reconstruction.json").read_text(encoding="utf-8"))
        self.assertFalse(manifest["raw_rom_bytes_included"])
        for output in manifest["outputs"]:
            self.assertEqual(hashlib.sha256((ROOT / output["path"]).read_bytes()).hexdigest(), output["sha256"])


if __name__ == "__main__":
    unittest.main()
