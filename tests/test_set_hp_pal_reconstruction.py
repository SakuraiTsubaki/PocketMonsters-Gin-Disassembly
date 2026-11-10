import csv, hashlib, json, unittest
from pathlib import Path
R=Path(__file__).parents[1]
TARGET={'Japanese':0x34F8,'Korean':0x356B,'English':0x3596,'German':0x358D,'Spanish':0x3553,'French':0x3541,'Italian':0x3585}
class Tests(unittest.TestCase):
 def test_catalog(self):
  rows=list(csv.DictReader((R/'research/releases.csv').read_text(encoding='utf-8').splitlines()));s=json.loads((R/'analysis/set-hp-pal-summary.json').read_text());self.assertEqual((s['function'],s['release_count']),('SetHPPal',len(rows)));self.assertEqual(s['releases'][2]['language'],'Korean')
  for x in s['releases']:
   e=json.loads((R/x['evidence']).read_text());f=e['function'];self.assertEqual((f['bank'],f['address'],f['length'],f['get_hp_pal_target']),(0,TARGET[x['language']]-5,5,TARGET[x['language']]));self.assertFalse(e['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/set-hp-pal-reconstruction.json').read_text())
  for x in m['outputs']:self.assertEqual(hashlib.sha256((R/x['path']).read_bytes()).hexdigest(),x['sha256'])
if __name__=='__main__':unittest.main()
