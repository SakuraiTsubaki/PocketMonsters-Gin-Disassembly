from __future__ import annotations
import hashlib,json,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class EntryCfgTests(unittest.TestCase):
 def setUp(self):
  self.report_path=next((ROOT/"analysis").glob("*-jp-entry-cfg.json"));self.report=json.loads(self.report_path.read_text());self.source=(ROOT/"src"/"entry_cfg.asm").read_text();self.manifest=json.loads((ROOT/"manifests"/"entry-cfg.json").read_text())
 def test_blocks_edges_and_source(self):
  self.assertEqual((len(self.report["blocks"]),len(self.report["edges"])),(3,5));chunks=[];cursor=self.report["blocks"][0]["start_address"]
  for block in self.report["blocks"]:
   self.assertEqual(block["start_address"],cursor);raw=b"".join(bytes.fromhex(i["bytes"]) for i in block["instructions"]);self.assertEqual(hashlib.sha256(raw).hexdigest(),block["block_bytes_sha256"]);self.assertIn(f"Block_{block['start_address']:04x}::",self.source);chunks.append(raw);cursor=block["end_address"]
  self.assertEqual(hashlib.sha256(b"".join(chunks)).hexdigest(),self.manifest["inputs"][0]["slice_sha256"])
 def test_manifest_hashes_and_identity(self):
  i=self.manifest["inputs"][0];self.assertEqual((i["sha256"],i["offset"]),(self.report["source_sha256"],self.report["start_address"]));self.assertTrue(all(hashlib.sha256((ROOT/o["path"]).read_bytes()).hexdigest()==o["sha256"] for o in self.manifest["outputs"]))
if __name__=="__main__":unittest.main()

