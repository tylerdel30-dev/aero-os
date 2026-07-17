//! Minimal ATA PIO + FAT16/32 reader/writer for the boot ESP (VMware-friendly).

use alloc::string::String;
use alloc::vec;
use alloc::vec::Vec;

use crate::arch::port::{inb, inw, outb, outw};
use crate::session::Session;

const ATA_DATA: u16 = 0x1F0;
const ATA_SECT: u16 = 0x1F2;
const ATA_LBA0: u16 = 0x1F3;
const ATA_LBA1: u16 = 0x1F4;
const ATA_LBA2: u16 = 0x1F5;
const ATA_DRIVE: u16 = 0x1F6;
const ATA_STATUS: u16 = 0x1F7;
const ATA_CMD: u16 = 0x1F7;

fn ata_ready() -> bool {
    unsafe {
        for _ in 0..100_000 {
            let s = inb(ATA_STATUS);
            if s & 0x80 == 0 {
                return true;
            }
        }
    }
    false
}

fn ata_wait_drq() -> bool {
    unsafe {
        for _ in 0..100_000 {
            let s = inb(ATA_STATUS);
            if s & 0x08 != 0 {
                return true;
            }
            if s & 0x01 != 0 {
                return false;
            }
        }
    }
    false
}

pub fn read_sector(lba: u32, buf: &mut [u8; 512]) -> bool {
    if !ata_ready() {
        return false;
    }
    unsafe {
        outb(ATA_DRIVE, (0xE0 | ((lba >> 24) & 0x0F)) as u8);
        outb(ATA_SECT, 1);
        outb(ATA_LBA0, lba as u8);
        outb(ATA_LBA1, (lba >> 8) as u8);
        outb(ATA_LBA2, (lba >> 16) as u8);
        outb(ATA_CMD, 0x20); // READ SECTORS
    }
    if !ata_wait_drq() {
        return false;
    }
    for i in 0..256 {
        let w = unsafe { inw(ATA_DATA) };
        buf[i * 2] = w as u8;
        buf[i * 2 + 1] = (w >> 8) as u8;
    }
    true
}

pub fn write_sector(lba: u32, buf: &[u8; 512]) -> bool {
    if !ata_ready() {
        return false;
    }
    unsafe {
        outb(ATA_DRIVE, (0xE0 | ((lba >> 24) & 0x0F)) as u8);
        outb(ATA_SECT, 1);
        outb(ATA_LBA0, lba as u8);
        outb(ATA_LBA1, (lba >> 8) as u8);
        outb(ATA_LBA2, (lba >> 16) as u8);
        outb(ATA_CMD, 0x30); // WRITE SECTORS
    }
    if !ata_wait_drq() {
        return false;
    }
    for i in 0..256 {
        let w = buf[i * 2] as u16 | ((buf[i * 2 + 1] as u16) << 8);
        unsafe { outw(ATA_DATA, w) };
    }
    ata_ready()
}

#[derive(Clone, Copy)]
struct FatVol {
    bytes_per_sector: u16,
    sectors_per_cluster: u8,
    reserved_sectors: u16,
    fats: u8,
    root_entries: u16,
    fat_size: u32,
    root_cluster: u32, // FAT32
    data_start: u32,
    fat_start: u32,
    is_fat32: bool,
    root_dir_sectors: u32,
    root_start: u32,
}

fn parse_bpb(sec: &[u8; 512]) -> Option<FatVol> {
    let bps = u16::from_le_bytes([sec[11], sec[12]]);
    if bps != 512 {
        return None;
    }
    let spc = sec[13];
    let reserved = u16::from_le_bytes([sec[14], sec[15]]);
    let fats = sec[16];
    let root_entries = u16::from_le_bytes([sec[17], sec[18]]);
    let fat16_size = u16::from_le_bytes([sec[22], sec[23]]) as u32;
    let fat32_size = u32::from_le_bytes([sec[36], sec[37], sec[38], sec[39]]);
    let fat_size = if fat16_size != 0 { fat16_size } else { fat32_size };
    let root_cluster = u32::from_le_bytes([sec[44], sec[45], sec[46], sec[47]]);
    let is_fat32 = fat16_size == 0;
    let root_dir_sectors = ((root_entries as u32 * 32) + (bps as u32 - 1)) / bps as u32;
    let fat_start = reserved as u32;
    let root_start = fat_start + fats as u32 * fat_size;
    let data_start = root_start + if is_fat32 { 0 } else { root_dir_sectors };
    Some(FatVol {
        bytes_per_sector: bps,
        sectors_per_cluster: spc,
        reserved_sectors: reserved,
        fats,
        root_entries,
        fat_size,
        root_cluster: if is_fat32 { root_cluster } else { 0 },
        data_start,
        fat_start,
        is_fat32,
        root_dir_sectors,
        root_start,
    })
}

fn cluster_to_lba(vol: &FatVol, cluster: u32) -> u32 {
    vol.data_start + (cluster - 2) * vol.sectors_per_cluster as u32
}

fn read_fat_entry(vol: &FatVol, cluster: u32) -> Option<u32> {
    let mut sec = [0u8; 512];
    if vol.is_fat32 {
        let offset = cluster * 4;
        let lba = vol.fat_start + offset / 512;
        let off = (offset % 512) as usize;
        if !read_sector(lba, &mut sec) {
            return None;
        }
        Some(u32::from_le_bytes([sec[off], sec[off + 1], sec[off + 2], sec[off + 3]]) & 0x0FFF_FFFF)
    } else {
        let offset = cluster * 2;
        let lba = vol.fat_start + offset / 512;
        let off = (offset % 512) as usize;
        if !read_sector(lba, &mut sec) {
            return None;
        }
        Some(u16::from_le_bytes([sec[off], sec[off + 1]]) as u32)
    }
}

fn next_cluster(vol: &FatVol, cluster: u32) -> Option<u32> {
    let e = read_fat_entry(vol, cluster)?;
    if vol.is_fat32 {
        if e >= 0x0FFF_FFF8 {
            None
        } else {
            Some(e)
        }
    } else if e >= 0xFFF8 {
        None
    } else {
        Some(e)
    }
}

#[derive(Clone)]
pub struct DirEntry {
    pub name: String,
    pub size: u32,
    pub cluster: u32,
    pub is_dir: bool,
}

fn parse_dir_sector(sec: &[u8; 512], out: &mut Vec<DirEntry>) {
    for i in 0..16 {
        let e = &sec[i * 32..(i + 1) * 32];
        let first = e[0];
        if first == 0x00 {
            break;
        }
        if first == 0xE5 {
            continue;
        }
        let attr = e[11];
        if attr & 0x08 != 0 {
            continue; // volume label
        }
        if attr & 0x0F == 0x0F {
            continue; // LFN
        }
        let mut name = [0u8; 11];
        name.copy_from_slice(&e[0..11]);
        let base = core::str::from_utf8(&name[0..8]).unwrap_or("").trim();
        let ext = core::str::from_utf8(&name[8..11]).unwrap_or("").trim();
        let mut s = String::new();
        for c in base.chars() {
            if c != ' ' {
                s.push(c);
            }
        }
        if !ext.is_empty() {
            s.push('.');
            for c in ext.chars() {
                if c != ' ' {
                    s.push(c);
                }
            }
        }
        let cluster = u16::from_le_bytes([e[26], e[27]]) as u32
            | ((u16::from_le_bytes([e[20], e[21]]) as u32) << 16);
        let size = u32::from_le_bytes([e[28], e[29], e[30], e[31]]);
        out.push(DirEntry {
            name: s,
            size,
            cluster,
            is_dir: attr & 0x10 != 0,
        });
    }
}

fn list_root(vol: &FatVol) -> Vec<DirEntry> {
    let mut out = Vec::new();
    let mut sec = [0u8; 512];
    if vol.is_fat32 {
        let mut cluster = vol.root_cluster;
        loop {
            let lba0 = cluster_to_lba(vol, cluster);
            for s in 0..vol.sectors_per_cluster as u32 {
                if !read_sector(lba0 + s, &mut sec) {
                    return out;
                }
                parse_dir_sector(&sec, &mut out);
            }
            match next_cluster(vol, cluster) {
                Some(c) => cluster = c,
                None => break,
            }
        }
    } else {
        for s in 0..vol.root_dir_sectors {
            if !read_sector(vol.root_start + s, &mut sec) {
                break;
            }
            parse_dir_sector(&sec, &mut out);
        }
    }
    out
}

fn open_volume() -> Option<FatVol> {
    let mut sec = [0u8; 512];
    // Try LBA 0 (superfloppy / ESP image) and LBA 2048 (common GPT ESP).
    for &lba in &[0u32, 2048] {
        if read_sector(lba, &mut sec) {
            if let Some(mut vol) = parse_bpb(&sec) {
                // Adjust absolute LBAs if ESP starts at 2048.
                if lba != 0 {
                    vol.fat_start += lba;
                    vol.root_start += lba;
                    vol.data_start += lba;
                }
                return Some(vol);
            }
        }
    }
    None
}

pub fn list_aero_dir() -> Vec<DirEntry> {
    let Some(vol) = open_volume() else {
        return Vec::new();
    };
    let root = list_root(&vol);
    // Find AERO directory
    let aero = root.iter().find(|e| e.is_dir && e.name.eq_ignore_ascii_case("AERO"));
    let Some(aero) = aero else {
        return root; // show root if no AERO
    };
    list_dir(&vol, aero.cluster)
}

fn list_dir(vol: &FatVol, start_cluster: u32) -> Vec<DirEntry> {
    let mut out = Vec::new();
    let mut cluster = start_cluster;
    let mut sec = [0u8; 512];
    loop {
        let lba0 = cluster_to_lba(vol, cluster);
        for s in 0..vol.sectors_per_cluster as u32 {
            if !read_sector(lba0 + s, &mut sec) {
                return out;
            }
            parse_dir_sector(&sec, &mut out);
        }
        match next_cluster(vol, cluster) {
            Some(c) => cluster = c,
            None => break,
        }
    }
    out
}

pub fn read_file(path_name: &str) -> Option<Vec<u8>> {
    let vol = open_volume()?;
    let entries = list_aero_dir();
    // Also search AERO/store
    let mut all = entries.clone();
    if let Some(store) = entries
        .iter()
        .find(|e| e.is_dir && e.name.eq_ignore_ascii_case("STORE"))
    {
        all.extend(list_dir(&vol, store.cluster));
    }
    let ent = all
        .iter()
        .find(|e| !e.is_dir && e.name.eq_ignore_ascii_case(path_name))?;
    read_clusters(&vol, ent.cluster, ent.size as usize)
}

fn read_clusters(vol: &FatVol, start: u32, size: usize) -> Option<Vec<u8>> {
    let mut out = vec![0u8; size];
    let mut cluster = start;
    let mut written = 0usize;
    let mut sec = [0u8; 512];
    while written < size {
        let lba0 = cluster_to_lba(vol, cluster);
        for s in 0..vol.sectors_per_cluster as u32 {
            if !read_sector(lba0 + s, &mut sec) {
                return Some(out);
            }
            let take = (size - written).min(512);
            out[written..written + take].copy_from_slice(&sec[..take]);
            written += take;
            if written >= size {
                break;
            }
        }
        match next_cluster(vol, cluster) {
            Some(c) => cluster = c,
            None => break,
        }
    }
    Some(out)
}

/// Best-effort session save after ExitBootServices (overwrite existing file clusters).
pub fn save_session_file(session: &Session) -> bool {
    let data = format_session_bytes(session);
    let Some(vol) = open_volume() else {
        return false;
    };
    let entries = list_aero_dir();
    let Some(ent) = entries
        .iter()
        .find(|e| !e.is_dir && e.name.eq_ignore_ascii_case("SESSION.JSON"))
    else {
        return false;
    };
    write_clusters(&vol, ent.cluster, &data)
}

fn format_session_bytes(session: &Session) -> Vec<u8> {
    let name = session.display_name();
    let mut buf = Vec::new();
    buf.extend_from_slice(b"{\"v\":1,\"name\":\"");
    buf.extend_from_slice(name.as_bytes());
    buf.extend_from_slice(b"\",\"region\":");
    let mut n = session.region_idx;
    if n == 0 {
        buf.push(b'0');
    } else {
        let mut tmp = [0u8; 12];
        let mut i = 12;
        while n > 0 {
            i -= 1;
            tmp[i] = b'0' + (n % 10) as u8;
            n /= 10;
        }
        buf.extend_from_slice(&tmp[i..]);
    }
    buf.extend_from_slice(b",\"look\":");
    buf.push(b'0' + (session.look_idx.min(9) as u8));
    buf.push(b'}');
    // Pad to not shrink unexpectedly
    while buf.len() < 128 {
        buf.push(b' ');
    }
    buf
}

fn write_clusters(vol: &FatVol, start: u32, data: &[u8]) -> bool {
    let mut cluster = start;
    let mut offset = 0usize;
    let mut sec = [0u8; 512];
    while offset < data.len() {
        let lba0 = cluster_to_lba(vol, cluster);
        for s in 0..vol.sectors_per_cluster as u32 {
            sec = [0u8; 512];
            let take = (data.len() - offset).min(512);
            sec[..take].copy_from_slice(&data[offset..offset + take]);
            if !write_sector(lba0 + s, &sec) {
                return false;
            }
            offset += take;
            if offset >= data.len() {
                return true;
            }
        }
        match next_cluster(vol, cluster) {
            Some(c) => cluster = c,
            None => return offset >= data.len(),
        }
    }
    true
}

pub fn list_store_aero() -> Vec<String> {
    let mut names = Vec::new();
    let Some(vol) = open_volume() else {
        return names;
    };
    let root = list_root(&vol);
    let Some(aero) = root.iter().find(|e| e.is_dir && e.name.eq_ignore_ascii_case("AERO")) else {
        return names;
    };
    let aero_ents = list_dir(&vol, aero.cluster);
    let Some(store) = aero_ents
        .iter()
        .find(|e| e.is_dir && e.name.eq_ignore_ascii_case("STORE"))
    else {
        return names;
    };
    for e in list_dir(&vol, store.cluster) {
        if !e.is_dir && e.name.to_ascii_lowercase().ends_with(".aero") {
            names.push(e.name);
        }
    }
    names
}
