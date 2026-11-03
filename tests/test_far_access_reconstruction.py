import hashlib,json,pathlib,unittest
ROOT=pathlib.Path(__file__).parents[1]
class T(unittest.TestCase):
 def test_releases(self):
  s=json.loads((ROOT/"analysis/far-access-summary.json").read_text());self.assertEqual(s["release_count"],8);self.assertEqual(s["functions"],["GetFarByte","GetFarWord"])
  for r in s["releases"]:
   e=json.loads((ROOT/r["evidence"]).read_text());b=e["functions"]["GetFarByte"];w=e["functions"]["GetFarWord"];self.assertEqual(w["rom_offset"],b["range_end_exclusive"]);self.assertEqual(b["bank"],0);self.assertEqual(w["bank"],0);self.assertFalse(e["raw_rom_bytes_included"])
 def test_manifest(self):
  m=json.loads((ROOT/"manifests/far-access-reconstruction.json").read_text())
  for x in m["outputs"]:self.assertEqual(hashlib.sha256((ROOT/x["path"]).read_bytes()).hexdigest(),x["sha256"])
if __name__=="__main__":unittest.main()
