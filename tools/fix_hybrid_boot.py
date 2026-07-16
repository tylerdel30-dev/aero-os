#!/usr/bin/env python3
"""Restore FreeBSD hybrid MBR/GPT system area onto a remastered Aero ISO.

pycdlib rewrite zeroes the first 32 KiB (USB DD/Rufus boot). This copies the
original FreeBSD system area and retargets the EFI GPT partition to the new
El Torito UEFI boot image LBA.
"""

from __future__ import annotations

import struct
import sys
from pathlib import Path

import pycdlib

SECTOR = 512
SYSTEM_AREA = 16 * 2048  # 32 KiB — ISO9660 PVD starts at sector 16


def crc32_gpt(data: bytes) -> int:
    import zlib

    return zlib.crc32(data) & 0xFFFFFFFF


def uefi_eltorito(path: Path) -> tuple[int, int]:
    """Return (load_rba_2048, sector_count_512) for the UEFI El Torito entry."""
    iso = pycdlib.PyCdlib()
    iso.open(str(path))
    try:
        cat = iso.eltorito_boot_catalog
        if cat is None:
            raise RuntimeError(f"no El Torito catalog: {path}")
        for sec in cat.sections or []:
            if getattr(sec, "platform_id", None) == 239:  # UEFI
                for e in sec.section_entries or []:
                    return int(e.load_rba), int(e.sector_count)
        # aarch64 FreeBSD: UEFI image is often the initial El Torito entry
        ie = cat.initial_entry
        if ie is not None and int(getattr(ie, "sector_count", 0) or 0) > 0:
            return int(ie.load_rba), int(ie.sector_count)
        raise RuntimeError(f"no UEFI El Torito entry: {path}")
    finally:
        iso.close()


def patch_hybrid(original: Path, remastered: Path) -> None:
    src_full = original.read_bytes()
    src = bytearray(src_full[:SYSTEM_AREA])
    dst = bytearray(remastered.read_bytes())
    if len(dst) < SYSTEM_AREA:
        raise RuntimeError("remastered ISO too small")

    # If original has no GPT, just copy system area (best effort)
    if bytes(src[SECTOR : SECTOR + 8]) != b"EFI PART":
        dst[:SYSTEM_AREA] = src
        remastered.write_bytes(dst)
        print("Copied system area (no GPT on original — best effort)")
        return

    rba, sc = uefi_eltorito(remastered)
    efi_first = rba * (2048 // SECTOR)
    efi_last = efi_first + sc - 1
    iso_sectors_512 = len(dst) // SECTOR

    struct.pack_into("<B", src, 446 + 4, 0xEE)
    struct.pack_into("<I", src, 446 + 8, 1)
    struct.pack_into("<I", src, 446 + 12, max(iso_sectors_512 - 1, 1))
    src[510:512] = b"\x55\xaa"

    hdr_off = SECTOR
    part_lba, num_parts, part_entsz, _ = struct.unpack_from("<QIII", src, hdr_off + 72)
    part_off = part_lba * SECTOR
    if part_off + num_parts * part_entsz > SYSTEM_AREA:
        raise RuntimeError("GPT partition table extends past system area")

    backup_lba = iso_sectors_512 - 1
    first_usable = 34
    last_usable = max(iso_sectors_512 - 34, first_usable)
    struct.pack_into("<QQQQ", src, hdr_off + 24, 1, backup_lba, first_usable, last_usable)

    efi_type = bytes.fromhex("28732ac11ff8d211ba4b00a0c93ec93b")
    found = False
    for i in range(num_parts):
        eoff = part_off + i * part_entsz
        typ = bytes(src[eoff : eoff + 16])
        if typ == efi_type:
            struct.pack_into("<QQ", src, eoff + 32, efi_first, efi_last)
            found = True
            break
    if not found:
        # No EFI type entry — still restore MBR/GPT sizes for USB recognition
        print("WARNING: no EFI GPT type entry — restoring MBR/GPT without EFI retarget")

    freebsd_iso_type = bytes.fromhex("9d6bbd83417fdc11be0b001560b84f0f")
    for i in range(num_parts):
        eoff = part_off + i * part_entsz
        typ = bytes(src[eoff : eoff + 16])
        if typ == freebsd_iso_type:
            first = struct.unpack_from("<Q", src, eoff + 32)[0]
            struct.pack_into("<QQ", src, eoff + 32, first, last_usable)
            break

    part_array = bytes(src[part_off : part_off + num_parts * part_entsz])
    part_crc = crc32_gpt(part_array)
    struct.pack_into("<I", src, hdr_off + 88, part_crc)
    struct.pack_into("<I", src, hdr_off + 16, 0)
    hdr_size = struct.unpack_from("<I", src, hdr_off + 12)[0]
    hdr_crc = crc32_gpt(bytes(src[hdr_off : hdr_off + hdr_size]))
    struct.pack_into("<I", src, hdr_off + 16, hdr_crc)

    dst[:SYSTEM_AREA] = src

    backup = bytearray(src[hdr_off : hdr_off + hdr_size])
    struct.pack_into("<QQ", backup, 24, backup_lba, 1)
    struct.pack_into("<I", backup, 16, 0)
    backup_part_lba = backup_lba - ((num_parts * part_entsz + SECTOR - 1) // SECTOR)
    if backup_part_lba > first_usable:
        struct.pack_into("<Q", backup, 72, backup_part_lba)
        bpo = backup_part_lba * SECTOR
        if bpo + len(part_array) <= len(dst):
            dst[bpo : bpo + len(part_array)] = part_array
        struct.pack_into("<I", backup, 88, part_crc)
        bcrc = crc32_gpt(bytes(backup))
        struct.pack_into("<I", backup, 16, bcrc)
        boff = backup_lba * SECTOR
        if boff + hdr_size <= len(dst):
            dst[boff : boff + hdr_size] = backup

    remastered.write_bytes(dst)
    print(
        f"Hybrid boot fixed: EFI GPT LBA {efi_first}-{efi_last} "
        f"(El Torito RBA {rba}, {sc} sectors)"
    )


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    original = root / ".cache" / "freebsd" / "FreeBSD-14.3-RELEASE-amd64-disc1.iso"
    remastered = root / "out" / "AeroOS-1.0.1-Stratus.iso"
    if len(sys.argv) >= 3:
        original = Path(sys.argv[1])
        remastered = Path(sys.argv[2])
    if not original.is_file() or not remastered.is_file():
        print("usage: fix_hybrid_boot.py <freebsd.iso> <aero.iso>", file=sys.stderr)
        return 1
    patch_hybrid(original, remastered)
    # verify
    data = remastered.read_bytes()
    assert data[510:512] == b"\x55\xaa", "MBR signature missing"
    assert data[512:520] == b"EFI PART", "GPT signature missing"
    print("Verified MBR 55AA + GPT header present")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
