import csv,hashlib,json,unittest
from pathlib import Path
R=Path(__file__).parents[1]
class Tests(unittest.TestCase):
 def test_catalog(self):
  rows=list(csv.DictReader((R/'research/releases.csv').read_text(encoding='utf-8').splitlines()));s=json.loads((R/'analysis/byte-fill-summary.json').read_text());self.assertEqual((s['function'],s['release_count'],sum(x['origin_reference']for x in s['releases'])),('ByteFill',len(rows),1));self.assertEqual(s['releases'][2]['language'],'Korean')
  for x in s['releases']:
   e=json.loads((R/x['evidence']).read_text());self.assertEqual((e['function']['length'],e['function']['bank'],e['semantics']['zero_length_supported']),(12,0,True));self.assertFalse(e['raw_rom_bytes_included'])
 def test_source_and_manifest(self):
  src=(R/'src/byte_fill.asm').read_text();self.assertIn('ByteFill::',src);m=json.loads((R/'manifests/byte-fill-reconstruction.json').read_text())
  for x in m['outputs']:self.assertEqual(hashlib.sha256((R/x['path']).read_bytes()).hexdigest(),x['sha256'])
if __name__=='__main__':unittest.main()
