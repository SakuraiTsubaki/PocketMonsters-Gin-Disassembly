#!/usr/bin/env python3
"""Compare Bank 00 of two Game Boy ROM images without dumping ROM bytes."""

from __future__ import annotations

import argparse
import csv
import hashlib
from collections import OrderedDict
from dataclasses import dataclass
from pathlib import Path

BANK00_SIZE = 0x4000


@dataclass(frozen=True)
class Component:
    name: str
    start: int
    end: int


def parse_int(value: str) -> int:
    return int(value, 0)


def load_ranges(path: Path) -> list[Component]:
    components: list[Component] = []
    with path.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            components.append(
                Component(
                    row["component"],
                    parse_int(row["start_hex"]),
                    parse_int(row["end_hex"]),
                )
            )
    if not components:
        raise SystemExit(f"no component ranges in {path}")
    return components


def read_bank00(path: Path) -> bytes:
    data = path.read_bytes()
    if len(data) < BANK00_SIZE:
        raise SystemExit(
            f"{path}: file is only {len(data)} bytes; Bank 00 needs {BANK00_SIZE}"
        )
    return data[:BANK00_SIZE]


def component_for(offset: int, components: list[Component]) -> str:
    for component in components:
        if component.start <= offset < component.end:
            return component.name
    return "<unmapped>"


def make_report(
    baseline_path: Path,
    candidate_path: Path,
    ranges_path: Path,
) -> tuple[str, bool]:
    baseline = read_bank00(baseline_path)
    candidate = read_bank00(candidate_path)
    components = load_ranges(ranges_path)

    differing = [i for i, (a, b) in enumerate(zip(baseline, candidate)) if a != b]
    exact = not differing

    mismatch_bytes: OrderedDict[str, int] = OrderedDict((c.name, 0) for c in components)
    mismatch_runs: OrderedDict[str, int] = OrderedDict((c.name, 0) for c in components)

    runs: list[tuple[int, int, str]] = []
    if differing:
        start = prev = differing[0]
        current_component = component_for(start, components)
        for offset in differing[1:]:
            name = component_for(offset, components)
            if offset != prev + 1 or name != current_component:
                runs.append((start, prev + 1, current_component))
                start = offset
                current_component = name
            prev = offset
        runs.append((start, prev + 1, current_component))

    for offset in differing:
        name = component_for(offset, components)
        mismatch_bytes[name] = mismatch_bytes.get(name, 0) + 1
    for _start, _end, name in runs:
        mismatch_runs[name] = mismatch_runs.get(name, 0) + 1

    lines = [
        "Bank 00 byte comparison",
        "=======================",
        f"baseline: {baseline_path}",
        f"candidate: {candidate_path}",
        f"range: 0x0000-0x3FFF ({BANK00_SIZE} bytes)",
        f"baseline_sha256: {hashlib.sha256(baseline).hexdigest()}",
        f"candidate_sha256: {hashlib.sha256(candidate).hexdigest()}",
        f"exact_match: {'yes' if exact else 'no'}",
        f"differing_bytes: {len(differing)}",
        f"diff_runs: {len(runs)}",
        "",
        "Per-component mismatches",
        "------------------------",
        "component,mismatch_bytes,diff_runs",
    ]

    for component in components:
        byte_count = mismatch_bytes.get(component.name, 0)
        run_count = mismatch_runs.get(component.name, 0)
        if byte_count:
            lines.append(f"{component.name},{byte_count},{run_count}")

    if not differing:
        lines.append("(none)")

    lines.extend(["", "Contiguous diff runs", "--------------------"])
    if runs:
        lines.append("component,start_hex,end_hex_exclusive,length")
        for start, end, name in runs:
            lines.append(f"{name},0x{start:04X},0x{end:04X},{end - start}")
    else:
        lines.append("(none)")

    return "\n".join(lines) + "\n", exact


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument(
        "--ranges",
        type=Path,
        default=Path("analysis/bank00_us_component_ranges.csv"),
    )
    parser.add_argument("--report", type=Path)
    parser.add_argument(
        "--allow-mismatch",
        action="store_true",
        help="return success even when Bank 00 differs",
    )
    args = parser.parse_args()

    report, exact = make_report(args.baseline, args.candidate, args.ranges)
    print(report, end="")
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(report, encoding="utf-8")

    return 0 if exact or args.allow_mismatch else 1


if __name__ == "__main__":
    raise SystemExit(main())
