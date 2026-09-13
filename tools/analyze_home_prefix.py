#!/usr/bin/env python3
"""Locate the verified Bank 00 HOME prefix in Pokemon Silver ROMs.

This tool does not write or distribute ROM data. It reads user-supplied ROM
files and emits source-layout metadata suitable for comparison/reconstruction.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
from pathlib import Path

BANK0_END = 0x4000

DELAY_PATTERN = [
    0x3E, 0x01, 0xEA, None, None, 0x76, 0x00, 0xFA, None, None,
    0xA7, 0x20, None, 0xC9, 0xCD, None, None, 0x0D, 0x20, None, 0xC9,
]
FADE_PATTERN = [
    0xFA, None, None, 0x47, 0x21, None, None, 0x7D, 0x90, 0x6F,
    0x30, None, 0x25, 0x2A, 0xE0, 0x47, 0x2A, 0xE0, 0x48, 0x2A,
    0xE0, 0x49, 0xC9,
]
TIME_PATTERN = [
    0xD9, 0x3E, 0x00, 0xEA, 0x00, 0x60, 0x3E, 0x01,
    0xEA, 0x00, 0x60, 0xC9,
]
RESET_PATTERN = [
    0xCD, None, None, 0xAF, 0xE0, None, 0xCD, None, None, 0xFB,
    0x21, None, None, 0xCB, 0xFE, 0x0E, 0x20, 0xCD, None, None,
    0x18, None,
]


def u16le(data: bytes, offset: int) -> int:
    return data[offset] | (data[offset + 1] << 8)


def find_pattern(data: bytes, pattern: list[int | None], start: int, end: int) -> list[int]:
    hits: list[int] = []
    n = len(pattern)
    for pos in range(start, end - n + 1):
        if all(p is None or data[pos + i] == p for i, p in enumerate(pattern)):
            hits.append(pos)
    return hits


def one(hits: list[int], name: str) -> int:
    if len(hits) != 1:
        raise ValueError(f"{name}: expected one hit, found {len(hits)}: {hits}")
    return hits[0]


def analyze(path: Path) -> list[dict[str, object]]:
    data = path.read_bytes()
    if len(data) < BANK0_END:
        raise ValueError(f"{path}: too small to be a valid target ROM")

    vblank = u16le(data, 0x0041)
    lcd = u16le(data, 0x0049)
    serial = u16le(data, 0x0059)
    start = u16le(data, 0x0102)

    delay = one(find_pattern(data, DELAY_PATTERN, 0x0150, 0x0400), "DelayFrame")
    fade = one(find_pattern(data, FADE_PATTERN, 0x0300, 0x0500), "TimeOfDayFade")
    time = one(find_pattern(data, TIME_PATTERN, 0x0400, 0x0700), "time.asm start")
    init = one(find_pattern(data, RESET_PATTERN, max(0x0150, start - 0x40), start), "Reset")

    time_palettes = delay + len(DELAY_PATTERN)

    points = [
        ("vblank", vblank),
        ("delay", delay),
        ("time_palettes", time_palettes),
        ("fade", fade),
        ("lcd", lcd),
        ("time", time),
        ("init", init),
        ("serial", serial),
    ]

    expected = [name for name, _ in points]
    if [name for name, _ in sorted(points, key=lambda x: x[1])] != expected:
        raise ValueError(f"{path}: unexpected HOME ordering: {points}")

    rows: list[dict[str, object]] = []
    for i, (name, begin) in enumerate(points[:-1]):
        end = points[i + 1][1]
        chunk = data[begin:end]
        rows.append({
            "file": path.name,
            "component": name,
            "start_hex": f"0x{begin:04X}",
            "end_hex": f"0x{end:04X}",
            "length": len(chunk),
            "sha256": hashlib.sha256(chunk).hexdigest(),
        })
    return rows


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("rom", nargs="+", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    rows: list[dict[str, object]] = []
    for path in args.rom:
        rows.extend(analyze(path))

    fields = ["file", "component", "start_hex", "end_hex", "length", "sha256"]
    if args.output:
        fh = args.output.open("w", newline="", encoding="utf-8")
    else:
        import sys
        fh = sys.stdout
    try:
        writer = csv.DictWriter(fh, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    finally:
        if args.output:
            fh.close()


if __name__ == "__main__":
    main()
