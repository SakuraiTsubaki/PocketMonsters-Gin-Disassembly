from __future__ import annotations
import csv, json, unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class ReleaseReportTests(unittest.TestCase):
    def test_release_evidence_is_synchronized(self):
        project=json.loads((ROOT/"project.json").read_text(encoding="utf-8")); report=json.loads((ROOT/"analysis"/"gin-release-header-report.json").read_text(encoding="utf-8"))
        with (ROOT/"research"/"releases.csv").open(newline="",encoding="utf-8") as stream: rows=list(csv.DictReader(stream))
        p={x["id"]:x for x in project["releases"]}; r={x["id"]:x for x in report["releases"]}; c={x["id"]:x for x in rows}
        self.assertEqual(set(p),set(r)); self.assertEqual(set(p),set(c)); self.assertEqual(len(p),8)
        for release_id,item in p.items(): self.assertEqual(item["status"],"candidate"); self.assertEqual(item["sha256"],r[release_id]["sha256"]); self.assertEqual(item["sha256"],c[release_id]["sha256"]); self.assertTrue(all(r[release_id]["validation"].values()))
    def test_korean_release_is_color_only_and_not_sgb(self):
        report=json.loads((ROOT/"analysis"/"gin-release-header-report.json").read_text(encoding="utf-8")); ko=next(x for x in report["releases"] if x["id"]=="silver-ko-rev0")
        self.assertEqual(ko["header"]["cgb_flag"],0xC0); self.assertEqual(ko["header"]["sgb_flag"],0)
if __name__=="__main__": unittest.main()
