//! UEFI filesystem helpers for the AERO volume (session + store).

use alloc::format;
use alloc::string::{String, ToString};
use alloc::vec::Vec;
use uefi::boot;
use uefi::fs::FileSystem;
use uefi::proto::media::fs::SimpleFileSystem;
use uefi::CString16;

use crate::session::{Look, Session, LOOKS, REGIONS};

const SESSION_PATH: &str = "\\AERO\\session.json";

fn open_boot_fs() -> Option<FileSystem> {
    let proto = boot::get_image_file_system(boot::image_handle()).ok()?;
    Some(FileSystem::new(proto))
}

fn to_path(s: &str) -> Option<CString16> {
    CString16::try_from(s).ok()
}

/// Load session from `\\AERO\\session.json` on the boot volume.
pub fn load_session() -> Option<Session> {
    let mut fs = open_boot_fs()?;
    let path = to_path(SESSION_PATH)?;
    let bytes = fs.read(path.as_ref()).ok()?;
    parse_session(&bytes)
}

/// Persist session to the boot volume (and other writable volumes).
pub fn save_session(session: &Session) -> bool {
    let data = format_session(session);
    let mut wrote = false;

    if let Some(mut fs) = open_boot_fs() {
        if ensure_aero_dirs(&mut fs) && write_bytes(&mut fs, SESSION_PATH, &data) {
            wrote = true;
        }
    }

    if let Ok(handles) = boot::find_handles::<SimpleFileSystem>() {
        for handle in handles {
            if let Ok(proto) = boot::open_protocol_exclusive::<SimpleFileSystem>(handle) {
                let mut fs = FileSystem::new(proto);
                if ensure_aero_dirs(&mut fs) && write_bytes(&mut fs, SESSION_PATH, &data) {
                    wrote = true;
                }
            }
        }
    }

    wrote
}

/// True if a saved session exists on the boot volume.
pub fn session_exists() -> bool {
    let Some(mut fs) = open_boot_fs() else {
        return false;
    };
    let Some(path) = to_path(SESSION_PATH) else {
        return false;
    };
    fs.try_exists(path.as_ref()).unwrap_or(false)
}

/// List `.aero` filenames under `\\AERO\\store` (best-effort).
pub fn list_store_files() -> Vec<String> {
    let mut out = Vec::new();
    let Some(mut fs) = open_boot_fs() else {
        return out;
    };
    let Some(path) = to_path("\\AERO\\store") else {
        return out;
    };
    let Ok(iter) = fs.read_dir(path.as_ref()) else {
        return out;
    };
    for entry in iter.flatten() {
        let name = entry.file_name().to_string();
        if name.ends_with(".aero") || name.ends_with(".AERO") {
            out.push(name);
        }
    }
    out
}

fn ensure_aero_dirs(fs: &mut FileSystem) -> bool {
    let Some(aero) = to_path("\\AERO") else {
        return false;
    };
    let Some(store) = to_path("\\AERO\\store") else {
        return false;
    };
    let _ = fs.create_dir(aero.as_ref());
    let _ = fs.create_dir(store.as_ref());
    true
}

fn write_bytes(fs: &mut FileSystem, path: &str, data: &[u8]) -> bool {
    let Some(p) = to_path(path) else {
        return false;
    };
    fs.write(p.as_ref(), data).is_ok()
}

fn format_session(session: &Session) -> Vec<u8> {
    let name = session.display_name();
    let look = session.look_idx.min(2);
    let region = session.region_idx;
    let mut buf = Vec::new();
    buf.extend_from_slice(b"{\"v\":1,\"name\":\"");
    for b in name.bytes() {
        if b == b'\\' || b == b'"' {
            buf.push(b'\\');
        }
        buf.push(b);
    }
    buf.extend_from_slice(b"\",\"region\":");
    push_usize(&mut buf, region);
    buf.extend_from_slice(b",\"look\":");
    push_usize(&mut buf, look);
    buf.push(b'}');
    buf
}

fn push_usize(buf: &mut Vec<u8>, n: usize) {
    if n == 0 {
        buf.push(b'0');
        return;
    }
    let mut tmp = [0u8; 20];
    let mut i = tmp.len();
    let mut x = n;
    while x > 0 {
        i -= 1;
        tmp[i] = b'0' + (x % 10) as u8;
        x /= 10;
    }
    buf.extend_from_slice(&tmp[i..]);
}

fn parse_session(bytes: &[u8]) -> Option<Session> {
    let text = core::str::from_utf8(bytes).ok()?;
    let mut session = Session::new();

    if let Some(name) = extract_string(text, "name") {
        let nb = name.as_bytes();
        let n = nb.len().min(session.name.len());
        session.name[..n].copy_from_slice(&nb[..n]);
        session.name_len = n;
    }
    if let Some(r) = extract_usize(text, "region") {
        session.region_idx = r % REGIONS.len();
    }
    if let Some(l) = extract_usize(text, "look") {
        session.look_idx = l % LOOKS.len();
        session.look = LOOKS[session.look_idx].0;
    } else {
        session.look = Look::Dark;
    }
    Some(session)
}

fn extract_string<'a>(text: &'a str, key: &str) -> Option<&'a str> {
    let pattern = format!("\"{key}\":\"");
    let start = text.find(&pattern)? + pattern.len();
    let rest = &text[start..];
    let mut end = 0;
    let bytes = rest.as_bytes();
    while end < bytes.len() {
        if bytes[end] == b'\\' && end + 1 < bytes.len() {
            end += 2;
            continue;
        }
        if bytes[end] == b'"' {
            break;
        }
        end += 1;
    }
    Some(&rest[..end])
}

fn extract_usize(text: &str, key: &str) -> Option<usize> {
    let pattern = format!("\"{key}\":");
    let start = text.find(&pattern)? + pattern.len();
    let rest = text[start..].trim_start();
    let mut n = 0usize;
    let mut found = false;
    for c in rest.bytes() {
        if c.is_ascii_digit() {
            found = true;
            n = n.saturating_mul(10).saturating_add((c - b'0') as usize);
        } else {
            break;
        }
    }
    if found {
        Some(n)
    } else {
        None
    }
}

/// Install Aero onto writable volumes: dirs + session + marker.
pub fn install_aero(session: &Session) -> InstallResult {
    let data = format_session(session);
    let marker = b"Aero OS Foundation 0.3 installed.\n";
    let mut volumes = 0usize;
    let mut ok = 0usize;

    if let Some(mut fs) = open_boot_fs() {
        volumes += 1;
        if install_one(&mut fs, &data, marker) {
            ok += 1;
        }
    }

    if let Ok(handles) = boot::find_handles::<SimpleFileSystem>() {
        for handle in handles {
            if let Ok(proto) = boot::open_protocol_exclusive::<SimpleFileSystem>(handle) {
                volumes += 1;
                let mut fs = FileSystem::new(proto);
                if install_one(&mut fs, &data, marker) {
                    ok += 1;
                }
            }
        }
    }

    InstallResult { volumes, ok }
}

fn install_one(fs: &mut FileSystem, data: &[u8], marker: &[u8]) -> bool {
    if !ensure_aero_dirs(fs) {
        return false;
    }
    if !write_bytes(fs, SESSION_PATH, data) {
        return false;
    }
    let _ = write_bytes(fs, "\\AERO\\INSTALLED.TXT", marker);
    true
}

pub struct InstallResult {
    pub volumes: usize,
    pub ok: usize,
}

impl InstallResult {
    pub fn success(&self) -> bool {
        self.ok > 0
    }
}
