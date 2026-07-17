//! Programmable Interval Timer (channel 0).

use super::port::outb;

pub fn init(hz: u32) {
    let hz = hz.max(18);
    let divisor = 1193182u32 / hz;
    unsafe {
        outb(0x43, 0x36);
        outb(0x40, (divisor & 0xFF) as u8);
        outb(0x40, ((divisor >> 8) & 0xFF) as u8);
    }
}
