import hashlib, json, unittest
from pathlib import Path
ROOT=Path(__file__).parents[1]
EXPECTED={'de':'c3d1fd0dec1d5fa9aa7f85275e79c52aa9175d191c63cbed7b406c306d946348','fr':'e120c4ddb0dc3e25b95c9c71b3ffd59ff57ce689cf4d79d04913ba59140c18c2','it':'04c442246d1ae0ed6bf5e072bb7e3d06376e584b953d6b14047b39e45fbb0cb4','es':'6797010c052e8f9373ea2b9e855ec078b34fda12e5ccf742eb19bb5e8f6947c2'}
class Tests(unittest.TestCase):
 def test_languages(self):
  for lang,digest in EXPECTED.items():
   c=json.loads((ROOT/f'analysis/gin-{lang}-startup-cfg.json').read_text());self.assertEqual(c['source_sha256'],digest);self.assertEqual([b['start_address'] for b in c['blocks']],[0x5c6,0x5ca,0x5cd,0x5cf,0x5fc]);self.assertTrue(all('block_bytes' not in b for b in c['blocks']))
 def test_manifests(self):
  for lang in EXPECTED:
   m=json.loads((ROOT/f'manifests/{lang}-startup-cfg.json').read_text());self.assertFalse(m['raw_rom_bytes_included']);[self.assertEqual(hashlib.sha256((ROOT/o['path']).read_bytes()).hexdigest(),o['sha256']) for o in m['outputs']]
if __name__=='__main__':unittest.main()
