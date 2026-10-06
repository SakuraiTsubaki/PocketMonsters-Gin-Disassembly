import hashlib, json, unittest
from pathlib import Path
ROOT=Path(__file__).parents[1]
class Tests(unittest.TestCase):
 def test_cfg(self):
  c=json.loads((ROOT/'analysis/gin-en-startup-cfg.json').read_text());self.assertEqual(c['source_sha256'],'72b190859a59623cbef6c49d601f8de52c1d2331b4f08a8d2acc17274fc19a8c');self.assertEqual([b['start_address'] for b in c['blocks']],[0x5c6,0x5ca,0x5cd,0x5cf,0x5fc]);self.assertTrue(all('block_bytes' not in b for b in c['blocks']))
 def test_manifest(self):
  m=json.loads((ROOT/'manifests/english-startup-cfg.json').read_text());self.assertFalse(m['raw_rom_bytes_included']);[self.assertEqual(hashlib.sha256((ROOT/o['path']).read_bytes()).hexdigest(),o['sha256']) for o in m['outputs']]
if __name__=='__main__':unittest.main()
