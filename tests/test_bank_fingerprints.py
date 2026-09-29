from __future__ import annotations
import csv,hashlib,json,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class BankFingerprintTests(unittest.TestCase):
 def test_origin_bank_map_is_complete_and_synchronized(self):
  report=json.loads((ROOT/"analysis"/"gin-jp-rev0-bank-fingerprints.json").read_text(encoding="utf-8"));rows=list(csv.DictReader((ROOT/"analysis"/"banks.csv").read_text(encoding="utf-8").splitlines()));self.assertEqual(report["sha256"],"0a532063a3ff5750a464582aa7bbee2b6d42e1a92a136d9f4590e373487b615c");self.assertEqual(report["bank_size"],0x4000);self.assertEqual(report["bank_count"],64);self.assertEqual(len(rows),64);self.assertEqual(len({x["sha256"] for x in report["banks"]}),64);self.assertTrue(all(x["source_sha256"]==report["sha256"] for x in rows))
 def test_manifest_hashes_outputs(self):
  manifest=json.loads((ROOT/"analysis"/"gin-jp-rev0-bank-manifest.json").read_text(encoding="utf-8"));
  for output in manifest["outputs"]:self.assertEqual(hashlib.sha256((ROOT/output["path"]).read_bytes()).hexdigest(),output["sha256"])
if __name__=="__main__":unittest.main()
