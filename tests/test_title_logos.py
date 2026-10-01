import hashlib,json,unittest
from pathlib import Path

ROOT=Path(__file__).parents[1]

class TitleLogoTests(unittest.TestCase):
 def setUp(self):
  self.manifest=json.loads((ROOT/'manifests/title-logos.json').read_text(encoding='utf-8'))
 def test_all_catalog_languages_are_covered(self):
  self.assertEqual({a['language'] for a in self.manifest['artifacts']},{'ja','ko','en','de','fr','it','es'})
  self.assertEqual(self.manifest['origin_reference'],'gin-jp-rev0')
 def test_reports_and_pngs_are_hash_linked(self):
  for artifact in self.manifest['artifacts']:
   report=json.loads((ROOT/artifact['report']).read_text(encoding='utf-8'))
   png=(ROOT/artifact['png']).read_bytes()
   self.assertEqual(hashlib.sha256(png).hexdigest(),report['png_sha256'])
   self.assertEqual(report['format'],'pokemon-gen2-lz-to-game-boy-2bpp')
   self.assertEqual(report['decompressed_length'],report['tile_count']*16)
 def test_japanese_revisions_share_origin_art(self):
  reports=[json.loads((ROOT/f'analysis/gin-jp-rev{n}-title-logo.json').read_text()) for n in (0,1)]
  self.assertEqual(reports[0]['decompressed_sha256'],reports[1]['decompressed_sha256'])
  self.assertNotEqual(reports[0]['rom_sha256'],reports[1]['rom_sha256'])
 def test_global_top_is_shared_but_bottom_is_localized(self):
  langs=('en','de','fr','it','es')
  top={json.loads((ROOT/f'analysis/gin-{x}-title-logo-top.json').read_text())['decompressed_sha256'] for x in langs}
  bottom={json.loads((ROOT/f'analysis/gin-{x}-title-logo-bottom.json').read_text())['decompressed_sha256'] for x in langs}
  self.assertEqual(len(top),1)
  self.assertEqual(len(bottom),len(langs))

if __name__=='__main__':unittest.main()
