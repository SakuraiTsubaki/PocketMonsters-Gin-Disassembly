#!/usr/bin/env python3
"""Locate Bank 00 HOME component starts in regional Silver ROMs.

Uses the verified US/EU `pokesilver.sym` component starts as reference seeds.
For each component, the script decodes only LR35902 opcode identities (ignoring
immediate operands), builds a signature from the first N instructions, and
scans another Bank 00 for exact opcode-signature matches.

This intentionally reports unmatched/ambiguous components instead of guessing.
ROM binaries are read locally and are never written to the repository.
"""
from __future__ import annotations

import argparse
import csv
from pathlib import Path

BANK_SIZE = 0x4000

COMPONENTS = [
    ("vblank", 0x0150), ("delay", 0x032E), ("time_palettes", 0x0343),
    ("fade", 0x0360), ("lcd", 0x041B), ("time", 0x045B),
    ("init", 0x05B0), ("serial", 0x06AA), ("joypad", 0x08DF),
    ("decompress", 0x0AF0), ("palettes", 0x0BDF), ("gfx", 0x0D70),
    ("text", 0x0EBD), ("video", 0x1458), ("map_objects", 0x169C),
    ("sine", 0x19AC), ("movement", 0x19BB), ("menu", 0x1A4E),
    ("printer", 0x1EB3), ("game_time", 0x1EE6), ("map", 0x1F5D),
    ("farcall", 0x2E27), ("predef", 0x2E49), ("window", 0x2E80),
    ("flag", 0x2F2F), ("sprite_updates", 0x2F93), ("string", 0x2FB6),
    ("region", 0x2FD7), ("item", 0x3055), ("random", 0x30A2),
    ("sram", 0x30E1), ("call_regs", 0x30FC), ("clear_sprites", 0x30FF),
    ("copy", 0x311A), ("copy_tilemap", 0x3158), ("copy_name", 0x317B),
    ("array", 0x3186), ("math", 0x31A3), ("print_text", 0x31E2),
    ("queue_script", 0x3423), ("compare", 0x3431), ("tilemap", 0x3449),
    ("pokedex_flags", 0x35C3), ("names", 0x35EE),
    ("scrolling_menu", 0x3751), ("stone_queue", 0x37AC),
    ("trainers", 0x3844), ("pokemon", 0x3984), ("print_bcd", 0x3ADE),
    ("battle", 0x3B3A), ("sprite_anims", 0x3D2B), ("audio", 0x3D4F),
]

LEN3 = {
    0x01, 0x08, 0x11, 0x21, 0x31, 0xC2, 0xC3, 0xC4, 0xCA, 0xCC,
    0xCD, 0xD2, 0xD4, 0xDA, 0xDC, 0xEA, 0xFA,
}
LEN2 = {
    0x06, 0x0E, 0x10, 0x16, 0x18, 0x1E, 0x20, 0x26, 0x28, 0x2E,
    0x30, 0x36, 0x38, 0x3E, 0xC6, 0xCE, 0xD6, 0xDE, 0xE0, 0xE6,
    0xE8, 0xEE, 0xF0, 0xF6, 0xF8, 0xFE,
}


def opcode_key_and_length(data: bytes, pos: int) -> tuple[int, int]:
    op = data[pos]
    if op == 0xCB:
        if pos + 1 >= len(data):
            return op, 1
        return (op << 8) | data[pos + 1], 2
    if op in LEN3:
        return op, 3
    if op in LEN2:
        return op, 2
    return op, 1


def opcode_signature(data: bytes, start: int, count: int) -> tuple[int, ...]:
    out: list[int] = []
    pos = start
    for _ in range(count):
        if pos >= len(data):
            break
        key, length = opcode_key_and_length(data, pos)
        out.append(key)
        pos += length
    return tuple(out)


def exact_hits(data: bytes, signature: tuple[int, ...], count: int) -> list[int]:
    return [
        pos
        for pos in range(0x0150, BANK_SIZE)
        if opcode_signature(data, pos, count) == signature
    ]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference", required=True, help="US/EU Silver ROM")
    parser.add_argument("--rom", action="append", default=[], metavar="ID=PATH")
    parser.add_argument("--opcodes", type=int, default=16)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    reference = Path(args.reference).read_bytes()[:BANK_SIZE]
    roms: list[tuple[str, bytes]] = []
    for spec in args.rom:
        release_id, path = spec.split("=", 1)
        roms.append((release_id, Path(path).read_bytes()[:BANK_SIZE]))

    with open(args.output, "w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow([
            "component", "release", "reference_start", "candidate_start",
            "match_count", "status", "opcode_count",
        ])
        for component, start in COMPONENTS:
            signature = opcode_signature(reference, start, args.opcodes)
            writer.writerow([
                component, "US-EU", f"0x{start:04X}", f"0x{start:04X}",
                1, "reference", args.opcodes,
            ])
            for release_id, data in roms:
                hits = exact_hits(data, signature, args.opcodes)
                if len(hits) == 1:
                    candidate = f"0x{hits[0]:04X}"
                    status = "unique_exact_opcode_signature"
                elif not hits:
                    candidate = ""
                    status = "no_exact_signature_match"
                else:
                    candidate = ";".join(f"0x{hit:04X}" for hit in hits)
                    status = "ambiguous_exact_signature"
                writer.writerow([
                    component, release_id, f"0x{start:04X}", candidate,
                    len(hits), status, args.opcodes,
                ])


if __name__ == "__main__":
    main()
