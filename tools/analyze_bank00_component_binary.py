#!/usr/bin/env python3
"""Verify one Bank 00 component across preserved reference ROMs.

The script reads component boundaries from
analysis/bank00_component_starts_matrix.csv, slices the requested component in
memory, and writes metadata/alignment reports only. It never writes ROM bytes.

Example:
    python tools/analyze_bank00_component_binary.py \
        --component map \
        --rom US-EU=/path/to/Pokemon-Silver-USA-Europe.gbc \
        --rom JP-REV0=/path/to/Pocket-Monsters-Gin-Japan.gbc \
        --rom JP-REVA=/path/to/Pocket-Monsters-Gin-Japan-Rev-A.gbc \
        --rom KR-REV0=/path/to/Pocket-Monsters-Eun-Korea.gbc
"""

from __future__ import annotations

import argparse
import csv
import difflib
import hashlib
from pathlib import Path
import zlib


DEFAULT_MATRIX = Path("analysis/bank00_component_starts_matrix.csv")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--component", default="map")
    parser.add_argument("--matrix", type=Path, default=DEFAULT_MATRIX)
    parser.add_argument(
        "--rom",
        action="append",
        default=[],
        metavar="RELEASE=PATH",
        help="repeat for each reference ROM to include",
    )
    parser.add_argument(
        "--output-prefix",
        type=Path,
        default=None,
        help="default: analysis/bank00_<component>_binary",
    )
    return parser.parse_args()


def load_matrix(path: Path):
    with path.open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        raise SystemExit(f"empty component matrix: {path}")
    return rows, [name for name in rows[0] if name != "component"]


def component_bounds(rows, release: str, component: str) -> tuple[int, int]:
    names = [row["component"] for row in rows]
    try:
        index = names.index(component)
    except ValueError as exc:
        raise SystemExit(f"unknown component {component!r}") from exc
    if index + 1 >= len(rows):
        raise SystemExit(
            f"{component!r} has no following component boundary in the matrix"
        )
    try:
        start = int(rows[index][release], 0)
        end = int(rows[index + 1][release], 0)
    except KeyError as exc:
        raise SystemExit(f"unknown release {release!r}") from exc
    return start, end


def parse_rom_specs(specs: list[str]) -> dict[str, Path]:
    out: dict[str, Path] = {}
    for spec in specs:
        if "=" not in spec:
            raise SystemExit(f"--rom must be RELEASE=PATH: {spec!r}")
        release, raw_path = spec.split("=", 1)
        release = release.strip()
        path = Path(raw_path).expanduser()
        if not release or not raw_path:
            raise SystemExit(f"invalid --rom spec: {spec!r}")
        if release in out:
            raise SystemExit(f"duplicate release: {release}")
        if not path.is_file():
            raise SystemExit(f"ROM not found for {release}: {path}")
        out[release] = path
    if len(out) < 2:
        raise SystemExit("provide at least two --rom RELEASE=PATH arguments")
    return out


def slice_component(path: Path, start: int, end: int) -> bytes:
    with path.open("rb") as f:
        f.seek(start)
        data = f.read(end - start)
    if len(data) != end - start:
        raise SystemExit(
            f"{path}: expected {end - start} bytes at "
            f"0x{start:04X}-0x{end:04X}, got {len(data)}"
        )
    return data


def write_csv(path: Path, fieldnames: list[str], rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    args = parse_args()
    matrix_rows, release_order = load_matrix(args.matrix)
    roms = parse_rom_specs(args.rom)

    unknown = sorted(set(roms) - set(release_order))
    if unknown:
        raise SystemExit(
            "release labels not present in matrix: " + ", ".join(unknown)
        )

    ordered = [release for release in release_order if release in roms]
    slices: dict[str, bytes] = {}
    summary_rows: list[dict] = []

    for release in ordered:
        start, end = component_bounds(matrix_rows, release, args.component)
        data = slice_component(roms[release], start, end)
        slices[release] = data
        summary_rows.append(
            {
                "release": release,
                "start": f"0x{start:04X}",
                "end_exclusive": f"0x{end:04X}",
                "size": len(data),
                "sha1": hashlib.sha1(data).hexdigest(),
                "sha256": hashlib.sha256(data).hexdigest(),
                "crc32": f"{zlib.crc32(data) & 0xffffffff:08x}",
            }
        )

    pair_rows: list[dict] = []
    for i, release_a in enumerate(ordered):
        for release_b in ordered[i + 1 :]:
            a = slices[release_a]
            b = slices[release_b]
            matcher = difflib.SequenceMatcher(None, a, b, autojunk=False)
            opcodes = matcher.get_opcodes()
            pair_rows.append(
                {
                    "release_a": release_a,
                    "release_b": release_b,
                    "size_a": len(a),
                    "size_b": len(b),
                    "byte_identical": "yes" if a == b else "no",
                    "same_length": "yes" if len(a) == len(b) else "no",
                    "matching_bytes": sum(
                        i2 - i1
                        for tag, i1, i2, j1, j2 in opcodes
                        if tag == "equal"
                    ),
                    "sequence_ratio": f"{matcher.ratio():.6f}",
                    "replace_spans": sum(tag == "replace" for tag, *_ in opcodes),
                    "insert_spans": sum(tag == "insert" for tag, *_ in opcodes),
                    "delete_spans": sum(tag == "delete" for tag, *_ in opcodes),
                }
            )

    prefix = (
        args.output_prefix
        if args.output_prefix is not None
        else Path(f"analysis/bank00_{args.component}_binary")
    )
    summary_path = prefix.with_name(prefix.name + "_summary.csv")
    pairwise_path = prefix.with_name(prefix.name + "_pairwise.csv")

    write_csv(
        summary_path,
        [
            "release",
            "start",
            "end_exclusive",
            "size",
            "sha1",
            "sha256",
            "crc32",
        ],
        summary_rows,
    )
    write_csv(
        pairwise_path,
        [
            "release_a",
            "release_b",
            "size_a",
            "size_b",
            "byte_identical",
            "same_length",
            "matching_bytes",
            "sequence_ratio",
            "replace_spans",
            "insert_spans",
            "delete_spans",
        ],
        pair_rows,
    )

    print(summary_path)
    print(pairwise_path)


if __name__ == "__main__":
    main()
