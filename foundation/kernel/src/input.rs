//! Unified input: UEFI before ExitBootServices, PS/2 after.

use uefi::boot::{self, ScopedProtocol};
use uefi::proto::console::pointer::Pointer;
use uefi::proto::console::text::{Key as UefiKey, ScanCode};
use uefi::system;

use crate::arch::idt;
use crate::handoff;
use crate::ps2;

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

pub struct PointerState {
    pub x: usize,
    pub y: usize,
    pub left: bool,
    pub left_pressed: bool,
    pub available: bool,
}

pub struct Input {
    pointer: Option<ScopedProtocol<Pointer>>,
    mouse_x: isize,
    mouse_y: isize,
    width: usize,
    height: usize,
    prev_left: bool,
}

impl Input {
    pub fn new(width: usize, height: usize) -> Self {
        let pointer = if handoff::is_kernel_mode() {
            None
        } else {
            boot::get_handle_for_protocol::<Pointer>()
                .ok()
                .and_then(|h| boot::open_protocol_exclusive::<Pointer>(h).ok())
        };
        Self {
            pointer,
            mouse_x: (width / 2) as isize,
            mouse_y: (height / 2) as isize,
            width,
            height,
            prev_left: false,
        }
    }

    pub fn poll_key() -> Option<Key> {
        if handoff::is_kernel_mode() {
            return ps2::poll_key();
        }
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

    pub fn poll_pointer(&mut self) -> PointerState {
        if handoff::is_kernel_mode() || self.pointer.is_none() {
            return PointerState {
                x: self.mouse_x as usize,
                y: self.mouse_y as usize,
                left: false,
                left_pressed: false,
                available: false,
            };
        }
        let mut left = false;
        if let Some(ptr) = self.pointer.as_mut() {
            if let Ok(Some(state)) = ptr.read_state() {
                self.mouse_x += state.relative_movement[0] as isize / 2;
                self.mouse_y += state.relative_movement[1] as isize / 2;
                left = state.button[0];
            }
        }
        self.mouse_x = self.mouse_x.clamp(0, self.width.saturating_sub(1) as isize);
        self.mouse_y = self.mouse_y.clamp(0, self.height.saturating_sub(1) as isize);
        let left_pressed = left && !self.prev_left;
        self.prev_left = left;
        PointerState {
            x: self.mouse_x as usize,
            y: self.mouse_y as usize,
            left,
            left_pressed,
            available: true,
        }
    }
}

pub fn poll_key() -> Option<Key> {
    Input::poll_key()
}

pub fn wait_key() -> Key {
    loop {
        if let Some(k) = poll_key() {
            return k;
        }
        stall_us(10_000);
    }
}

pub fn wait_key_timeout(timeout_us: usize) -> Option<Key> {
    let steps = (timeout_us / 10_000).max(1);
    for _ in 0..steps {
        if let Some(k) = poll_key() {
            return Some(k);
        }
        stall_us(10_000);
    }
    None
}

pub fn stall_us(us: usize) {
    if handoff::is_kernel_mode() {
        idt::sleep_ms((us as u64 / 1000).max(1));
    } else {
        boot::stall(us);
    }
}
