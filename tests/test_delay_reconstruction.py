import csv, hashlib, json, unittest
from pathlib import Path
R = Path(__file__).parents[1]
class Tests(unittest.TestCase):
 def test_catalog(self):
  rows=list(csv.DictReader((R/'research/releases.csv').read_text(encoding='utf-8').splitlines()));s=json.loads((R/'analysis/delay-summary.json').read_text());self.assertEqual((s['functions'],s['release_count'],sum(x['origin_reference'] for x in s['releases'])),(['DelayFrame','DelayFrames'],len(rows),1));self.assertEqual(s['releases'][2]['language'],'Korean')
  for x in s['releases']:
   e=json.loads((R/x['evidence']).read_text());self.assertEqual((e['functions']['DelayFrame']['bank'],e['functions']['DelayFrame']['address'],e['functions']['DelayFrame']['length']),(0,0x032E,14));self.assertEqual((e['functions']['DelayFrames']['address'],e['functions']['DelayFrames']['length']),(0x033C,7));self.assertFalse(e['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/delay-reconstruction.json').read_text());self.assertFalse(m['raw_rom_bytes_included'])
  for x in m['outputs']:self.assertEqual(hashlib.sha256((R/x['path']).read_bytes()).hexdigest(),x['sha256'])
if __name__=='__main__':unittest.main()
