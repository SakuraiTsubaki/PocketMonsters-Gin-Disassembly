#!/usr/bin/env python3
"""Analyze read-only Pokémon Silver ROM inputs without committing ROM binaries.

The script emits header metadata and bank hashes used during disassembly reconstruction.
"""
from pathlib import Path
import argparse, csv, hashlib

BANK_SIZE = 0x4000

def header_checksum(data):
    value = 0
    for byte in data[0x134:0x14D]:
        value = (value - byte - 1) & 0xFF
    return value

def global_checksum(data):
    return (sum(data) - data[0x14E] - data[0x14F]) & 0xFFFF

def analyze(path):
    data = path.read_bytes()
    if len(data) % BANK_SIZE:
        raise ValueError(f"{path}: size is not a multiple of 16 KiB")
    return {
        "file": path.name,
        "size_bytes": len(data),
        "banks": len(data) // BANK_SIZE,
        "title": data[0x134:0x13F].rstrip(b"\0").decode("ascii", "replace"),
        "maker_code": data[0x13F:0x143].decode("ascii", "replace"),
        "cgb_flag": f"0x{data[0x143]:02X}",
        "sgb_flag": f"0x{data[0x146]:02X}",
        "cartridge_type": f"0x{data[0x147]:02X}",
        "rom_size_code": f"0x{data[0x148]:02X}",
        "ram_size_code": f"0x{data[0x149]:02X}",
        "destination_code": f"0x{data[0x14A]:02X}",
        "version": data[0x14C],
        "header_checksum_valid": header_checksum(data) == data[0x14D],
        "global_checksum_valid": global_checksum(data) == ((data[0x14E] << 8) | data[0x14F]),
        "sha1": hashlib.sha1(data).hexdigest(),
        "sha256": hashlib.sha256(data).hexdigest(),
    }, data

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("roms", nargs="+", type=Path)
    ap.add_argument("--out", type=Path, default=Path("analysis"))
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    headers=[]
    with (args.out / "bank_hashes.csv").open("w", newline="", encoding="utf-8") as bankf:
        bw=csv.writer(bankf)
        bw.writerow(["file","bank_hex","bank_dec","offset_start","offset_end","sha1","sha256"])
        for path in args.roms:
            meta,data=analyze(path); headers.append(meta)
            for bank in range(meta["banks"]):
                chunk=data[bank*BANK_SIZE:(bank+1)*BANK_SIZE]
                bw.writerow([path.name,f"{bank:02X}",bank,f"0x{bank*BANK_SIZE:06X}",f"0x{(bank+1)*BANK_SIZE-1:06X}",hashlib.sha1(chunk).hexdigest(),hashlib.sha256(chunk).hexdigest()])
    with (args.out / "header_matrix.csv").open("w", newline="", encoding="utf-8") as hf:
        w=csv.DictWriter(hf, fieldnames=headers[0].keys()); w.writeheader(); w.writerows(headers)

if __name__ == "__main__":
    main()
