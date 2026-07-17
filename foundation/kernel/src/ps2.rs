//! PS/2 keyboard (scancode set 1) for post-ExitBootServices input.

use core::sync::atomic::{AtomicBool, AtomicU8, Ordering};

use crate::arch::port::{inb, outb};
use crate::input::Key;

const BUF_LEN: usize = 64;
static mut BUF: [u8; BUF_LEN] = [0; BUF_LEN];
static HEAD: AtomicU8 = AtomicU8::new(0);
static TAIL: AtomicU8 = AtomicU8::new(0);
static SHIFT: AtomicBool = AtomicBool::new(false);

pub fn init() {
    // Enable scanning; status soft-reset is enough on VMware.
    unsafe {
        // Enable keyboard interrupt on controller
        outb(0x64, 0xAE);
    }
}

pub fn push_scancode(sc: u8) {
    let head = HEAD.load(Ordering::Relaxed) as usize;
    let next = (head + 1) % BUF_LEN;
    if next == TAIL.load(Ordering::Relaxed) as usize {
        return;
    }
    unsafe { BUF[head] = sc };
    HEAD.store(next as u8, Ordering::Relaxed);
}

fn pop_scancode() -> Option<u8> {
    let tail = TAIL.load(Ordering::Relaxed) as usize;
    if tail == HEAD.load(Ordering::Relaxed) as usize {
        return None;
    }
    let sc = unsafe { BUF[tail] };
    TAIL.store(((tail + 1) % BUF_LEN) as u8, Ordering::Relaxed);
    Some(sc)
}

/// Poll hardware directly if IRQ buffer empty (polling fallback).
pub fn poll_key() -> Option<Key> {
    if let Some(sc) = pop_scancode() {
        return decode(sc);
    }
    unsafe {
        if inb(0x64) & 1 != 0 {
            let sc = inb(0x60);
            return decode(sc);
        }
    }
    None
}

fn decode(sc: u8) -> Option<Key> {
    // Break codes
    if sc & 0x80 != 0 {
        let make = sc & 0x7F;
        if make == 0x2A || make == 0x36 {
            SHIFT.store(false, Ordering::Relaxed);
        }
        return None;
    }
    match sc {
        0x2A | 0x36 => {
            SHIFT.store(true, Ordering::Relaxed);
            None
        }
        0x1C => Some(Key::Enter),
        0x01 => Some(Key::Escape),
        0x0E => Some(Key::Backspace),
        0x0F => Some(Key::Tab),
        0x39 => Some(Key::Space),
        0x48 => Some(Key::Up),
        0x50 => Some(Key::Down),
        0x4B => Some(Key::Left),
        0x4D => Some(Key::Right),
        _ => {
            let shift = SHIFT.load(Ordering::Relaxed);
            let ch = scancode_to_ascii(sc, shift)?;
            Some(Key::Char(ch))
        }
    }
}

fn scancode_to_ascii(sc: u8, shift: bool) -> Option<u8> {
    let table: &[(u8, u8, u8)] = &[
        (0x02, b'1', b'!'),
        (0x03, b'2', b'@'),
        (0x04, b'3', b'#'),
        (0x05, b'4', b'$'),
        (0x06, b'5', b'%'),
        (0x07, b'6', b'^'),
        (0x08, b'7', b'&'),
        (0x09, b'8', b'*'),
        (0x0A, b'9', b'('),
        (0x0B, b'0', b')'),
        (0x10, b'q', b'Q'),
        (0x11, b'w', b'W'),
        (0x12, b'e', b'E'),
        (0x13, b'r', b'R'),
        (0x14, b't', b'T'),
        (0x15, b'y', b'Y'),
        (0x16, b'u', b'U'),
        (0x17, b'i', b'I'),
        (0x18, b'o', b'O'),
        (0x19, b'p', b'P'),
        (0x1E, b'a', b'A'),
        (0x1F, b's', b'S'),
        (0x20, b'd', b'D'),
        (0x21, b'f', b'F'),
        (0x22, b'g', b'G'),
        (0x23, b'h', b'H'),
        (0x24, b'j', b'J'),
        (0x25, b'k', b'K'),
        (0x26, b'l', b'L'),
        (0x2C, b'z', b'Z'),
        (0x2D, b'x', b'X'),
        (0x2E, b'c', b'C'),
        (0x2F, b'v', b'V'),
        (0x30, b'b', b'B'),
        (0x31, b'n', b'N'),
        (0x32, b'm', b'M'),
        (0x33, b',', b'<'),
        (0x34, b'.', b'>'),
        (0x35, b'/', b'?'),
        (0x0C, b'-', b'_'),
        (0x0D, b'=', b'+'),
    ];
    for &(code, lower, upper) in table {
        if code == sc {
            return Some(if shift { upper } else { lower });
        }
    }
    None
}
