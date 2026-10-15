import csv,hashlib,json,unittest
from pathlib import Path
ROOT=Path(__file__).parents[1]
EXPECTED={'gin-jp-rev0':(0x3083,0x3171),'gin-jp-rev1':(0x3083,0x3171),'silver-ko-rev0':(0x3160,0x3253),'silver-en-rev0':(0x30C7,0x31B5),'silver-de-rev0':(0x30F4,0x31E2),'silver-es-rev0':(0x30EB,0x31D9),'silver-fr-rev0':(0x30D9,0x31C7),'silver-it-rev0':(0x30EC,0x31DA)}
class Tests(unittest.TestCase):
 def test_releases(self):
  rows={r['id']:r for r in csv.DictReader((ROOT/'research/releases.csv').read_text(encoding='utf-8').splitlines())};self.assertEqual(set(rows),set(EXPECTED))
  for release,(address,divide) in EXPECTED.items():
   m=json.loads((ROOT/f'analysis/{release}-random-range.json').read_text());f=m['function'];r=json.loads((ROOT/f'analysis/{release}-random.json').read_text());w=json.loads((ROOT/f'analysis/{release}-battle-random.json').read_text())
   self.assertEqual(m['target']['sha256'],rows[release]['sha256']);self.assertEqual((f['address'],f['length']),(address,26));self.assertEqual(f['rom_offset'],w['function']['range_end_exclusive']);self.assertEqual(f['dependencies']['Random']['address'],r['function']['address']);self.assertEqual(f['dependencies']['hRandomAdd'],0xFFE3);self.assertEqual(f['dependencies']['SimpleDivide']['address'],divide);self.assertFalse(m['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((ROOT/'manifests/random-range-reconstruction.json').read_text());[self.assertEqual(hashlib.sha256((ROOT/o['path']).read_bytes()).hexdigest(),o['sha256']) for o in m['outputs']]
if __name__=='__main__':unittest.main()
