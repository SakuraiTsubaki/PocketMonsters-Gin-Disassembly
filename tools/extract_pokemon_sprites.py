#!/usr/bin/env python3
"""Extract and cross-version-deduplicate Pokémon battle sprites from Pokémon Silver ROMs.

The source ROMs are read-only inputs used only for verification/extraction. ROM binaries are
never copied into the repository. The extractor understands Gen II LZ3, Pokémon pic pointers,
GBC Pokémon palettes, and RGBGFX --columns tile ordering.

This tool intentionally writes one canonical asset when all supplied releases decode to the
same sprite. Per-release pointer locations and hashes remain in the manifest.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import struct
import zlib
from dataclasses import dataclass
from pathlib import Path

PIC_POINTER_TABLE = 0x12 * 0x4000
PIC_POINTER_SIZE = 6
BULBASAUR_NORMAL_MIDDLE = bytes.fromhex("ec2f5f19")
PIC_BANK_FIX = {0x13: 0x1F, 0x14: 0x20, 0x1F: 0x2E}

SPECIES = {
    1: "bulbasaur",
    2: "ivysaur",
    3: "venusaur",
    4: "charmander",
    5: "charmeleon",
    6: "charizard",
    7: "squirtle",
    8: "wartortle",
    9: "blastoise",
    10: "caterpie",
}

RELEASE_FILES = {
    "JP-REV0": "Pocket Monsters Gin (Japan).gbc",
    "JP-REVA": "Pocket Monsters Gin (Japan) (Rev A).gbc",
    "KR-REV0": "Pocket Monsters Eun (Korea).gbc",
    "US-EU-REV0": "Pokemon - Silver Version (USA, Europe).gbc",
    "DE-REV0": "Pokemon - Silberne Edition (Germany).gbc",
    "FR-REV0": "Pokemon - Version Argent (France).gbc",
    "IT-REV0": "Pokemon - Versione Argento (Italy).gbc",
    "ES-REV0": "Pokemon - Edicion Plata (Spain).gbc",
}


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def reverse_bits(value: int) -> int:
    return int(f"{value:08b}"[::-1], 2)


def decompress_lz3(rom: bytes, start: int) -> tuple[bytes, bytes]:
    out = bytearray()
    pos = start
    while True:
        command_byte = rom[pos]
        pos += 1
        if command_byte == 0xFF:
            return bytes(out), rom[start:pos]
        command = command_byte >> 5
        if command == 7:
            command = (command_byte >> 2) & 7
            length = (((command_byte & 3) << 8) | rom[pos]) + 1
            pos += 1
        else:
            length = (command_byte & 0x1F) + 1
        if command == 0:
            out.extend(rom[pos : pos + length])
            pos += length
        elif command == 1:
            out.extend([rom[pos]] * length)
            pos += 1
        elif command == 2:
            a, b = rom[pos], rom[pos + 1]
            pos += 2
            out.extend(a if i % 2 == 0 else b for i in range(length))
        elif command == 3:
            out.extend(b"\x00" * length)
        elif command in (4, 5, 6):
            encoded = rom[pos]
            pos += 1
            if encoded & 0x80:
                source = len(out) - ((encoded & 0x7F) + 1)
            else:
                source = (encoded << 8) | rom[pos]
                pos += 1
            if command == 4:
                for i in range(length):
                    out.append(out[source + i])
            elif command == 5:
                for i in range(length):
                    out.append(reverse_bits(out[source + i]))
            else:
                for i in range(length):
                    out.append(out[source - i])
        else:
            raise ValueError(f"unsupported LZ3 command {command}")


def fix_pic_bank(bank: int) -> int:
    return PIC_BANK_FIX.get(bank, bank)


def banked_to_file_offset(bank: int, address: int) -> int:
    if not 0x4000 <= address <= 0x7FFF:
        raise ValueError(f"invalid switchable ROM address: {address:#06x}")
    return bank * 0x4000 + (address - 0x4000)


def palette_table_offset(rom: bytes) -> int:
    hits = []
    start = 0
    while True:
        hit = rom.find(BULBASAUR_NORMAL_MIDDLE, start)
        if hit < 0:
            break
        hits.append(hit)
        start = hit + 1
    if len(hits) != 1:
        raise ValueError(f"expected one Pokémon palette signature, found {len(hits)}")
    return hits[0]


def gbc15_to_rgb888(value: int) -> tuple[int, int, int]:
    r5 = value & 0x1F
    g5 = (value >> 5) & 0x1F
    b5 = (value >> 10) & 0x1F
    expand = lambda c: (c << 3) | (c >> 2)
    return expand(r5), expand(g5), expand(b5)


def middle_palette_to_rgb(raw4: bytes) -> list[tuple[int, int, int]]:
    c1 = gbc15_to_rgb888(int.from_bytes(raw4[0:2], "little"))
    c2 = gbc15_to_rgb888(int.from_bytes(raw4[2:4], "little"))
    return [(255, 255, 255), c1, c2, (0, 0, 0)]


def render_column_major_2bpp(raw: bytes, tiles_wide: int) -> tuple[int, int, bytes]:
    tile_count = len(raw) // 16
    if tiles_wide <= 0 or tile_count % tiles_wide:
        raise ValueError("invalid 2bpp tile geometry")
    tiles_high = tile_count // tiles_wide
    width, height = tiles_wide * 8, tiles_high * 8
    pixels = bytearray(width * height)
    for tile_index in range(tile_count):
        tile_x = tile_index // tiles_high
        tile_y = tile_index % tiles_high
        tile = raw[tile_index * 16 : (tile_index + 1) * 16]
        for y in range(8):
            lo, hi = tile[y * 2], tile[y * 2 + 1]
            for x in range(8):
                bit = 7 - x
                value = ((lo >> bit) & 1) | (((hi >> bit) & 1) << 1)
                pixels[(tile_y * 8 + y) * width + tile_x * 8 + x] = value
    return width, height, bytes(pixels)


def png_chunk(kind: bytes, payload: bytes) -> bytes:
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", zlib.crc32(kind + payload) & 0xFFFFFFFF)


def indexed_png(width: int, height: int, pixels: bytes, palette: list[tuple[int, int, int]]) -> bytes:
    signature = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 3, 0, 0, 0)
    plte = b"".join(bytes(rgb) for rgb in palette)
    scanlines = b"".join(b"\x00" + pixels[y * width : (y + 1) * width] for y in range(height))
    return signature + png_chunk(b"IHDR", ihdr) + png_chunk(b"PLTE", plte) + png_chunk(b"IDAT", zlib.compress(scanlines, 9)) + png_chunk(b"IEND", b"")


@dataclass
class PicResult:
    release: str
    defined_bank: int
    actual_bank: int
    address: int
    file_offset: int
    compressed: bytes
    decompressed: bytes
    width: int
    height: int
    pixels: bytes
    normal_png: bytes
    shiny_png: bytes
    palette_entry: bytes


def extract_one(rom: bytes, release: str, species: int, side: str) -> PicResult:
    start = PIC_POINTER_TABLE + (species - 1) * PIC_POINTER_SIZE
    entry = rom[start : start + PIC_POINTER_SIZE]
    index = 0 if side == "front" else 3
    defined_bank = entry[index]
    actual_bank = fix_pic_bank(defined_bank)
    address = int.from_bytes(entry[index + 1 : index + 3], "little")
    file_offset = banked_to_file_offset(actual_bank, address)
    decompressed, compressed = decompress_lz3(rom, file_offset)
    tile_count = len(decompressed) // 16
    if side == "front":
        edge = math.isqrt(tile_count)
        if edge not in (5, 6, 7) or edge * edge != tile_count:
            raise ValueError(f"species {species} front has unexpected tile count {tile_count}")
    else:
        edge = 6
        if tile_count != 36:
            raise ValueError(f"species {species} back has unexpected tile count {tile_count}")
    width, height, pixels = render_column_major_2bpp(decompressed, edge)
    paloff = palette_table_offset(rom) + (species - 1) * 8
    palette_entry = rom[paloff : paloff + 8]
    normal = middle_palette_to_rgb(palette_entry[:4])
    shiny = middle_palette_to_rgb(palette_entry[4:8])
    return PicResult(release, defined_bank, actual_bank, address, file_offset, compressed, decompressed, width, height, pixels, indexed_png(width, height, pixels, normal), indexed_png(width, height, pixels, shiny), palette_entry)


def parse_range(text: str) -> list[int]:
    if "-" in text:
        a, b = (int(x) for x in text.split("-", 1))
        return list(range(a, b + 1))
    return [int(text)]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("rom_dir", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--species", default="1-10")
    args = parser.parse_args()
    ids = parse_range(args.species)
    unsupported = [i for i in ids if i not in SPECIES]
    if unsupported:
        raise SystemExit(f"species names not staged yet: {unsupported}")
    roms = {}
    for release, filename in RELEASE_FILES.items():
        path = args.rom_dir / filename
        if not path.exists():
            raise SystemExit(f"missing ROM for {release}: {path}")
        roms[release] = path.read_bytes()
    out = args.output_dir
    manifest = {"schema": 1, "batch": f"{min(ids):03d}-{max(ids):03d}", "dedup_policy": "one canonical asset when exact compressed bytes, decoded 2bpp, pixels, and palette are identical across releases", "releases": list(RELEASE_FILES), "species": []}
    csv_rows = []
    for species in ids:
        slug = SPECIES[species]
        species_dir = out / "gfx" / "pokemon" / f"{species:03d}_{slug}"
        species_dir.mkdir(parents=True, exist_ok=True)
        species_item = {"id": species, "slug": slug, "sprites": {}}
        for side in ("front", "back"):
            results = [extract_one(roms[r], r, species, side) for r in RELEASE_FILES]
            groups = ({sha256(r.compressed) for r in results}, {sha256(r.decompressed) for r in results}, {sha256(r.pixels) for r in results}, {sha256(r.palette_entry) for r in results})
            if any(len(group) != 1 for group in groups):
                raise SystemExit(f"{species:03d} {side}: release variants exist; use variant paths")
            canonical = results[0]
            (species_dir / f"{side}.2bpp.lz").write_bytes(canonical.compressed)
            (species_dir / f"{side}.png").write_bytes(canonical.normal_png)
            (species_dir / f"{side}_shiny.png").write_bytes(canonical.shiny_png)
            sprite_item = {"canonical": {"lz_path": f"gfx/pokemon/{species:03d}_{slug}/{side}.2bpp.lz", "normal_png_path": f"gfx/pokemon/{species:03d}_{slug}/{side}.png", "shiny_png_path": f"gfx/pokemon/{species:03d}_{slug}/{side}_shiny.png", "compressed_sha256": sha256(canonical.compressed), "decompressed_2bpp_sha256": sha256(canonical.decompressed), "pixel_index_sha256": sha256(canonical.pixels), "palette_entry_sha256": sha256(canonical.palette_entry), "compressed_size": len(canonical.compressed), "decompressed_size": len(canonical.decompressed), "width": canonical.width, "height": canonical.height, "palette_entry_hex": canonical.palette_entry.hex()}, "release_locations": []}
            for r in results:
                sprite_item["release_locations"].append({"release": r.release, "defined_bank": f"0x{r.defined_bank:02X}", "actual_bank": f"0x{r.actual_bank:02X}", "address": f"0x{r.address:04X}", "file_offset": f"0x{r.file_offset:06X}", "compressed_sha256": sha256(r.compressed)})
                csv_rows.append({"species": species, "slug": slug, "side": side, "release": r.release, "defined_bank": f"0x{r.defined_bank:02X}", "actual_bank": f"0x{r.actual_bank:02X}", "address": f"0x{r.address:04X}", "file_offset": f"0x{r.file_offset:06X}", "compressed_size": len(r.compressed), "decompressed_size": len(r.decompressed), "compressed_sha256": sha256(r.compressed), "decompressed_2bpp_sha256": sha256(r.decompressed)})
            species_item["sprites"][side] = sprite_item
        manifest["species"].append(species_item)
    analysis_dir = out / "analysis" / "sprites"
    analysis_dir.mkdir(parents=True, exist_ok=True)
    batch = f"{min(ids):03d}_{max(ids):03d}"
    (analysis_dir / f"batch_{batch}.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with (analysis_dir / f"batch_{batch}.csv").open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(csv_rows[0]))
        writer.writeheader()
        writer.writerows(csv_rows)


if __name__ == "__main__":
    main()
