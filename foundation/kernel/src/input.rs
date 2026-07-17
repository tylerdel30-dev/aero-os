//! UEFI text-input keyboard polling (uefi 0.33 globals).

use uefi::boot;
use uefi::proto::console::text::{Key as UefiKey, ScanCode};
use uefi::system;

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum Key {
    Enter,
    Escape,
    Up,
    Down,
    Left,
    Right,
    Space,
    Backspace,
    Tab,
    Char(u8),
    Other,
}

pub fn poll_key() -> Option<Key> {
    system::with_stdin(|stdin| {
        let key = stdin.read_key().ok().flatten()?;
        Some(match key {
            UefiKey::Special(ScanCode::UP) => Key::Up,
            UefiKey::Special(ScanCode::DOWN) => Key::Down,
            UefiKey::Special(ScanCode::LEFT) => Key::Left,
            UefiKey::Special(ScanCode::RIGHT) => Key::Right,
            UefiKey::Special(ScanCode::ESCAPE) => Key::Escape,
            UefiKey::Printable(c) => {
                let u = u16::from(c);
                match u {
                    0x0D | 0x0A => Key::Enter,
                    0x09 => Key::Tab,
                    0x20 => Key::Space,
                    0x08 => Key::Backspace,
                    0x20..=0x7E => Key::Char(u as u8),
                    _ => Key::Other,
                }
            }
            _ => Key::Other,
        })
    })
}

pub fn wait_key() -> Key {
    loop {
        if let Some(k) = poll_key() {
            return k;
        }
        boot::stall(10_000);
    }
}

/// Wait for a key, or return `None` after roughly `timeout_us` microseconds.
pub fn wait_key_timeout(timeout_us: usize) -> Option<Key> {
    let steps = (timeout_us / 10_000).max(1);
    for _ in 0..steps {
        if let Some(k) = poll_key() {
            return Some(k);
        }
        boot::stall(10_000);
    }
    None
}
