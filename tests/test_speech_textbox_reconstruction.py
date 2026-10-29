import hashlib, json, pathlib, unittest
ROOT = pathlib.Path(__file__).parents[1]
class SpeechTextboxTests(unittest.TestCase):
    def test_releases(self):
        s=json.loads((ROOT/"analysis/speech-textbox-summary.json").read_text()); self.assertEqual(s["release_count"],8)
        for r in s["releases"]:
            e=json.loads((ROOT/r["evidence"]).read_text()); self.assertEqual(e["verified_behavior"]["inner_height"],4); self.assertEqual(e["verified_behavior"]["inner_width"],18); self.assertFalse(e["raw_rom_bytes_included"])
    def test_manifest(self):
        m=json.loads((ROOT/"manifests/speech-textbox-reconstruction.json").read_text())
        for x in m["outputs"]: self.assertEqual(hashlib.sha256((ROOT/x["path"]).read_bytes()).hexdigest(),x["sha256"])
if __name__ == "__main__": unittest.main()
