import csv,hashlib,json,unittest
from pathlib import Path
R=Path(__file__).parents[1];E={'gin-jp-rev0':(0x6A75,0x6AD5),'gin-jp-rev1':(0x6A75,0x6AD5),'silver-ko-rev0':(0x685D,0x68BD),'silver-en-rev0':(0x6783,0x67E3),'silver-de-rev0':(0x67BB,0x681B),'silver-es-rev0':(0x67CD,0x682D),'silver-fr-rev0':(0x67B8,0x6818),'silver-it-rev0':(0x67B5,0x6815)};H='cfceda1a48a109a1b1e7df95eab6391c73dae4338c637ddf0f411779c60a75d4'
class T(unittest.TestCase):
 def test_releases(self):
  rows={x['id']:x for x in csv.DictReader((R/'research/releases.csv').read_text().splitlines())};self.assertEqual(set(rows),set(E))
  for k,(s,e) in E.items():
   m=json.loads((R/f'analysis/{k}-multiply-core.json').read_text());f=m['function'];w=json.loads((R/f'analysis/{k}-multiply-wrapper.json').read_text());d=json.loads((R/f'analysis/{k}-divide-wrapper.json').read_text());self.assertEqual(m['target']['sha256'],rows[k]['sha256']);self.assertEqual((f['bank'],f['address'],f['rom_offset'],f['range_end_exclusive'],f['length']),(1,s,s,e,96));self.assertEqual(f['code_sha256'],H);self.assertEqual(s,w['function']['far_call']['target']['rom_offset']);self.assertEqual(e,d['function']['home_call']['target']['rom_offset']);self.assertEqual(f['hram_layout']['multiplier'],0xFFB9);self.assertFalse(m['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((R/'manifests/multiply-core-reconstruction.json').read_text());[self.assertEqual(hashlib.sha256((R/o['path']).read_bytes()).hexdigest(),o['sha256'])for o in m['outputs']]
if __name__=='__main__':unittest.main()
