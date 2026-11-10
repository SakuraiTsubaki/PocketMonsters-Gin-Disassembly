import csv, hashlib, json, unittest
from pathlib import Path
R=Path(__file__).parents[1]
class Tests(unittest.TestCase):
 def test_catalog(self):
  rows=list(csv.DictReader((R/'research/releases.csv').read_text(encoding='utf-8').splitlines()));s=json.loads((R/'analysis/skip-names-add-n-times-summary.json').read_text());self.assertEqual((s['functions'],s['release_count']),(['SkipNames','AddNTimes'],len(rows)));self.assertEqual(s['releases'][2]['language'],'Korean')
  for x in s['releases']:
   e=json.loads((R/x['evidence']).read_text());a=e['functions'];self.assertEqual((a['SkipNames']['length'],a['AddNTimes']['length']),(10,7));self.assertEqual(a['SkipNames']['range_end_exclusive'],a['AddNTimes']['address']);self.assertEqual(x['name_length'],6 if x['language']=='Japanese' else 11);self.assertFalse(e['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/skip-names-add-n-times-reconstruction.json').read_text())
  for x in m['outputs']:self.assertEqual(hashlib.sha256((R/x['path']).read_bytes()).hexdigest(),x['sha256'])
if __name__=='__main__':unittest.main()
