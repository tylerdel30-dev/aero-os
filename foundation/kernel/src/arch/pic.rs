//! 8259 PIC remap to IRQs 32–47.

use super::port::{inb, outb};

const PIC1: u16 = 0x20;
const PIC2: u16 = 0xA0;
const PIC1_DATA: u16 = 0x21;
const PIC2_DATA: u16 = 0xA1;

pub fn init() {
    unsafe {
        let a1 = inb(PIC1_DATA);
        let a2 = inb(PIC2_DATA);

        outb(PIC1, 0x11);
        outb(PIC2, 0x11);
        outb(PIC1_DATA, 0x20); // offset 32
        outb(PIC2_DATA, 0x28); // offset 40
        outb(PIC1_DATA, 4);
        outb(PIC2_DATA, 2);
        outb(PIC1_DATA, 0x01);
        outb(PIC2_DATA, 0x01);

        // Unmask timer (IRQ0) and keyboard (IRQ1); mask the rest.
        outb(PIC1_DATA, 0xFC);
        outb(PIC2_DATA, 0xFF);
        let _ = (a1, a2);
    }
}

pub fn eoi(irq: u8) {
    unsafe {
        if irq >= 8 {
            outb(PIC2, 0x20);
        }
        outb(PIC1, 0x20);
    }
}
