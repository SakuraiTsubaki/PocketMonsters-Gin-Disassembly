import csv, hashlib, json, unittest
from pathlib import Path
R=Path(__file__).parents[1]
class Tests(unittest.TestCase):
 def test_catalog(self):
  rows=list(csv.DictReader((R/'research/releases.csv').read_text(encoding='utf-8').splitlines()));s=json.loads((R/'analysis/disable-lcd-summary.json').read_text());self.assertEqual((s['function'],s['release_count']),('DisableLCD',len(rows)));self.assertEqual(s['releases'][2]['language'],'Korean')
  for x in s['releases']:
   e=json.loads((R/x['evidence']).read_text());expected=0x0436 if x['language']=='Korean' else 0x0432;self.assertEqual((e['function']['bank'],e['function']['address'],e['function']['length'],e['function']['vblank_wait_ly']),(0,expected,34,145));self.assertFalse(e['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/disable-lcd-reconstruction.json').read_text())
  for x in m['outputs']:self.assertEqual(hashlib.sha256((R/x['path']).read_bytes()).hexdigest(),x['sha256'])
if __name__=='__main__':unittest.main()
