import csv,hashlib,json,unittest
from pathlib import Path
R=Path(__file__).parents[1];E={'gin-jp-rev0':0x6AD5,'gin-jp-rev1':0x6AD5,'silver-ko-rev0':0x68BD,'silver-en-rev0':0x67E3,'silver-de-rev0':0x681B,'silver-es-rev0':0x682D,'silver-fr-rev0':0x6818,'silver-it-rev0':0x6815};H='7874fe9005f762f369a472d108e8b970ba0818d593bd0e30260432caf2beba39'
class T(unittest.TestCase):
 def test_releases(self):
  rows={x['id']:x for x in csv.DictReader((R/'research/releases.csv').read_text().splitlines())};self.assertEqual(set(rows),set(E))
  for k,s in E.items():
   m=json.loads((R/f'analysis/{k}-divide-core.json').read_text());f=m['function'];w=json.loads((R/f'analysis/{k}-divide-wrapper.json').read_text());self.assertEqual(m['target']['sha256'],rows[k]['sha256']);self.assertEqual((f['bank'],f['address'],f['rom_offset'],f['range_end_exclusive'],f['length']),(1,s,s,s+131,131));self.assertEqual(f['code_sha256'],H);self.assertEqual(s,w['function']['home_call']['target']['rom_offset']);self.assertEqual(f['hram_layout']['divisor'],0xFFB9);self.assertEqual(f['hram_layout']['quotient'],[0xFFB5,0xFFB6,0xFFB7,0xFFB8]);self.assertFalse(m['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/divide-core-reconstruction.json').read_text());[self.assertEqual(hashlib.sha256((R/o['path']).read_bytes()).hexdigest(),o['sha256'])for o in m['outputs']]
if __name__=='__main__':unittest.main()
