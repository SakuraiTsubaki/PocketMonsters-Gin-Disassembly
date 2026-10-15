import csv, hashlib, json, unittest
from pathlib import Path

ROOT=Path(__file__).parents[1]
ADDRESSES={'gin-jp-rev0':0x305E,'gin-jp-rev1':0x305E,'silver-ko-rev0':0x313B,'silver-en-rev0':0x30A2,'silver-de-rev0':0x30CF,'silver-es-rev0':0x30C6,'silver-fr-rev0':0x30B4,'silver-it-rev0':0x30C7}
class Tests(unittest.TestCase):
 def test_all_catalogued_releases(self):
  rows={r['id']:r for r in csv.DictReader((ROOT/'research/releases.csv').read_text(encoding='utf-8').splitlines())};self.assertEqual(set(rows),set(ADDRESSES))
  for release,address in ADDRESSES.items():
   m=json.loads((ROOT/f'analysis/{release}-random.json').read_text());f=m['function'];self.assertEqual(m['target']['sha256'],rows[release]['sha256']);self.assertEqual((f['bank'],f['address'],f['length']),(0,address,19));self.assertEqual(f['globals'],{'hRandomAdd':0xFFE3,'hRandomSub':0xFFE4});self.assertEqual(f['code_sha256'],'cfef65875878a56aca6d9293d9d5ec497a7486be8c613263d53fd25a63942def');self.assertFalse(m['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((ROOT/'manifests/random-reconstruction.json').read_text());self.assertFalse(m['raw_rom_bytes_included']);[self.assertEqual(hashlib.sha256((ROOT/o['path']).read_bytes()).hexdigest(),o['sha256']) for o in m['outputs']]
if __name__=='__main__':unittest.main()
