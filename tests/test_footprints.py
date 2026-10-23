import hashlib,json,struct,unittest
from pathlib import Path
R=Path(__file__).parents[1];COUNT=8;RAW='f4cace658ec069903ac01dcceac2d1a637a74bb88ee84ed448482f521d977de9'
class T(unittest.TestCase):
 def test_atlas_and_releases(self):
  s=json.loads((R/'analysis/footprints-summary.json').read_text());l=json.loads((R/s['layout']).read_text());self.assertEqual((s['release_count'],s['source_sha256'],sum(x['origin_reference']for x in s['releases'])),(COUNT,RAW,1));self.assertIn('Korean',[x['language']for x in s['releases']]);self.assertEqual((l['slot_count'],l['official_species_slots'],l['unused_slots']),(256,251,5));p=(R/s['png']).read_bytes();self.assertEqual(struct.unpack('>II',p[16:24]),(256,1024))
  for x in s['releases']:
   r=json.loads((R/x['evidence']).read_text());self.assertEqual((r['target']['sha256'],r['asset']['source_sha256'],r['asset']['footprint_slots']),(x['sha256'],RAW,256));self.assertFalse(r['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/footprints.json').read_text());[self.assertEqual(hashlib.sha256((R/o['path']).read_bytes()).hexdigest(),o['sha256'])for o in m['outputs']]
if __name__=='__main__':unittest.main()
