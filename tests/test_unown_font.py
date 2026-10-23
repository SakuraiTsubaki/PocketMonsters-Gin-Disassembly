import hashlib,json,struct,unittest
from pathlib import Path
R=Path(__file__).parents[1];COUNT=8;RAW='904db613490cdb3c87791e951dfb149da0ef497365be0037005bb8a1171b20c1'
class T(unittest.TestCase):
 def test_releases_and_png(self):
  s=json.loads((R/'analysis/unown-font-summary.json').read_text());self.assertEqual((s['release_count'],s['source_sha256'],sum(x['origin_reference']for x in s['releases'])),(COUNT,RAW,1));self.assertIn('Korean',[x['language']for x in s['releases']])
  for x in s['releases']:
   r=json.loads((R/x['evidence']).read_text());self.assertEqual((r['target']['sha256'],r['asset']['tile_count'],r['asset']['source_sha256']),(x['sha256'],27,RAW));self.assertFalse(r['raw_rom_bytes_included'])
  p=(R/s['png']).read_bytes();self.assertEqual(p[:8],b'\x89PNG\r\n\x1a\n');self.assertEqual(struct.unpack('>II',p[16:24]),(48,144))
 def test_manifest(self):
  m=json.loads((R/'manifests/unown-font.json').read_text());[self.assertEqual(hashlib.sha256((R/o['path']).read_bytes()).hexdigest(),o['sha256'])for o in m['outputs']]
if __name__=='__main__':unittest.main()
