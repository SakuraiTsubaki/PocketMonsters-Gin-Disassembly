import csv, hashlib, json, unittest
from pathlib import Path
R=Path(__file__).parents[1]
class Tests(unittest.TestCase):
 def test_catalog(self):
  rows=list(csv.DictReader((R/'research/releases.csv').read_text(encoding='utf-8').splitlines()));s=json.loads((R/'analysis/is-in-array-summary.json').read_text());self.assertEqual((s['function'],s['release_count']),('IsInArray',len(rows)));self.assertEqual(s['releases'][2]['language'],'Korean');self.assertEqual(len({x['code_sha256'] for x in s['releases']}),1)
  for x in s['releases']:
   e=json.loads((R/x['evidence']).read_text());self.assertEqual((e['function']['bank'],e['function']['length']),(0,19));self.assertFalse(e['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/is-in-array-reconstruction.json').read_text())
  for x in m['outputs']:self.assertEqual(hashlib.sha256((R/x['path']).read_bytes()).hexdigest(),x['sha256'])
if __name__=='__main__':unittest.main()
