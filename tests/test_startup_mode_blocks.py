import hashlib,json,unittest
from pathlib import Path
ROOT=Path(__file__).parents[1]
class Tests(unittest.TestCase):
 def test_paths(self):
  n=json.loads((ROOT/'analysis/gin-jp-startup-noncgb-block.json').read_text());c=json.loads((ROOT/'analysis/gin-jp-startup-cgb-block.json').read_text());self.assertEqual(n['terminator'],'jr $05ce');self.assertEqual(c['terminator'],'jr nz $05f5');self.assertEqual(c['instruction_count'],24);self.assertEqual(c['instructions'][18]['source'],'ld [$cf1f], a')
 def test_manifest(self):
  m=json.loads((ROOT/'manifests/startup-mode-blocks.json').read_text());self.assertFalse(m['raw_rom_bytes_included']);[self.assertEqual(hashlib.sha256((ROOT/o['path']).read_bytes()).hexdigest(),o['sha256']) for o in m['outputs']]
if __name__=='__main__':unittest.main()
