import csv, hashlib, json, unittest
from pathlib import Path

ROOT=Path(__file__).parents[1]
EXPECTED={
 'gin-jp-rev0':(0x3071,0x6C31,0xCFD7),'gin-jp-rev1':(0x3071,0x6C31,0xCFD7),
 'silver-ko-rev0':(0x314E,0x6C62,0xD09D),'silver-en-rev0':(0x30B5,0x6C11,0xCFDD),
 'silver-de-rev0':(0x30E2,0x6C11,0xCFDD),'silver-es-rev0':(0x30D9,0x6C11,0xCFDD),
 'silver-fr-rev0':(0x30C7,0x6C13,0xCFDD),'silver-it-rev0':(0x30DA,0x6C11,0xCFDD)}
class Tests(unittest.TestCase):
 def test_all_catalogued_releases(self):
  rows={r['id']:r for r in csv.DictReader((ROOT/'research/releases.csv').read_text(encoding='utf-8').splitlines())};self.assertEqual(set(rows),set(EXPECTED))
  for release,(address,target,temp) in EXPECTED.items():
   m=json.loads((ROOT/f'analysis/{release}-battle-random.json').read_text());f=m['function'];r=json.loads((ROOT/f'analysis/{release}-random.json').read_text())
   self.assertEqual(m['target']['sha256'],rows[release]['sha256']);self.assertEqual((f['bank'],f['address'],f['length']),(0,address,18));self.assertEqual(f['rom_offset'],r['function']['range_end_exclusive']);self.assertEqual(f['target']['bank'],15);self.assertEqual(f['target']['address'],target);self.assertEqual(f['temporary_wram'],temp);self.assertEqual(f['hROMBank'],0xFF9F);self.assertFalse(m['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((ROOT/'manifests/battle-random-reconstruction.json').read_text());self.assertFalse(m['raw_rom_bytes_included']);[self.assertEqual(hashlib.sha256((ROOT/o['path']).read_bytes()).hexdigest(),o['sha256']) for o in m['outputs']]
if __name__=='__main__':unittest.main()
