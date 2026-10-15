import csv, hashlib, json, unittest
from pathlib import Path
ROOT=Path(__file__).parents[1]
EXPECTED={
'gin-jp-rev0':(0x6C31,0xD03C,0xCBB7,0xD0D5),'gin-jp-rev1':(0x6C31,0xD03C,0xCBB7,0xD0D5),
'silver-ko-rev0':(0x6C62,0xD0FD,0xCBCB,0xD1A0),'silver-en-rev0':(0x6C11,0xD042,0xCBC3,0xD0E3),
'silver-de-rev0':(0x6C11,0xD042,0xCBC3,0xD0E3),'silver-es-rev0':(0x6C11,0xD042,0xCBC3,0xD0E3),
'silver-fr-rev0':(0x6C13,0xD042,0xCBC3,0xD0E3),'silver-it-rev0':(0x6C11,0xD042,0xCBC3,0xD0E3)}
class Tests(unittest.TestCase):
 def test_all_catalogued_releases(self):
  rows={r['id']:r for r in csv.DictReader((ROOT/'research/releases.csv').read_text(encoding='utf-8').splitlines())};self.assertEqual(set(rows),set(EXPECTED))
  for release,(address,link,count,seeds) in EXPECTED.items():
   m=json.loads((ROOT/f'analysis/{release}-battle-random-core.json').read_text());f=m['function'];w=json.loads((ROOT/f'analysis/{release}-battle-random.json').read_text());r=json.loads((ROOT/f'analysis/{release}-random.json').read_text())
   self.assertEqual(m['target']['sha256'],rows[release]['sha256']);self.assertEqual((f['bank'],f['address'],f['length']),(15,address,55));self.assertEqual(f['rom_offset'],w['function']['target']['rom_offset']);self.assertEqual(f['control_flow']['non_link_jump']['address'],r['function']['address']);self.assertEqual(f['state'],{'wLinkMode':link,'wLinkBattleRNCount':count,'wLinkBattleRNs':seeds,'stream_length':10});self.assertEqual(f['prng']['seed_count'],10);self.assertFalse(m['raw_rom_bytes_included'])
 def test_manifest(self):
  m=json.loads((ROOT/'manifests/battle-random-core-reconstruction.json').read_text());self.assertFalse(m['raw_rom_bytes_included']);[self.assertEqual(hashlib.sha256((ROOT/o['path']).read_bytes()).hexdigest(),o['sha256']) for o in m['outputs']]
if __name__=='__main__':unittest.main()
