import csv, hashlib, json, unittest
from pathlib import Path
R=Path(__file__).parents[1]
class Tests(unittest.TestCase):
 def test_catalog(self):
  rows=list(csv.DictReader((R/'research/releases.csv').read_text(encoding='utf-8').splitlines()));s=json.loads((R/'analysis/clear-hide-sprites-summary.json').read_text());self.assertEqual((s['functions'],s['release_count']),(['ClearSprites','HideSprites'],len(rows)));self.assertEqual(s['releases'][2]['language'],'Korean')
  for x in s['releases']:
   e=json.loads((R/x['evidence']).read_text());a=e['functions']['ClearSprites'];b=e['functions']['HideSprites'];self.assertEqual((a['bank'],a['length'],a['byte_count']),(0,11,160));self.assertEqual((b['address'],b['length'],b['object_stride'],b['object_count'],b['hidden_y']),(a['address']+11,16,4,40,160));self.assertEqual(a['w_shadow_oam_address'],b['w_shadow_oam_y_address']);self.assertFalse(e['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/clear-hide-sprites-reconstruction.json').read_text())
  for x in m['outputs']:self.assertEqual(hashlib.sha256((R/x['path']).read_bytes()).hexdigest(),x['sha256'])
if __name__=='__main__':unittest.main()
