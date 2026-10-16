import csv,hashlib,json,unittest
from pathlib import Path
R=Path(__file__).parents[1];E={'gin-jp-rev0':(0x317A,0x6A75),'gin-jp-rev1':(0x317A,0x6A75),'silver-ko-rev0':(0x325C,0x685D),'silver-en-rev0':(0x31BE,0x6783),'silver-de-rev0':(0x31EB,0x67BB),'silver-es-rev0':(0x31E2,0x67CD),'silver-fr-rev0':(0x31D0,0x67B8),'silver-it-rev0':(0x31E3,0x67B5)}
class T(unittest.TestCase):
 def test_releases(self):
  rows={x['id']:x for x in csv.DictReader((R/'research/releases.csv').read_text().splitlines())};self.assertEqual(set(rows),set(E))
  for k,(a,t) in E.items():
   m=json.loads((R/f'analysis/{k}-multiply-wrapper.json').read_text());f=m['function'];d=json.loads((R/f'analysis/{k}-simple-divide.json').read_text());self.assertEqual(m['target']['sha256'],rows[k]['sha256']);self.assertEqual((f['bank'],f['address'],f['length']),(0,a,11));self.assertEqual(f['rom_offset'],d['function']['range_end_exclusive']);self.assertEqual(f['far_call']['target']['address'],t);self.assertFalse(m['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/multiply-wrapper-reconstruction.json').read_text());[self.assertEqual(hashlib.sha256((R/o['path']).read_bytes()).hexdigest(),o['sha256'])for o in m['outputs']]
if __name__=='__main__':unittest.main()
