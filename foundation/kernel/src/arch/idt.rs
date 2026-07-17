//! Interrupt Descriptor Table + IRQ0 tick.

use core::mem::size_of;
use core::sync::atomic::{AtomicU64, Ordering};

use super::pic;
use super::port::inb;
use crate::ps2;

pub static TICKS: AtomicU64 = AtomicU64::new(0);

#[derive(Clone, Copy)]
#[repr(C, packed)]
struct IdtEntry {
    offset_low: u16,
    selector: u16,
    ist: u8,
    type_attr: u8,
    offset_mid: u16,
    offset_high: u32,
    zero: u32,
}

impl IdtEntry {
    const fn empty() -> Self {
        Self {
            offset_low: 0,
            selector: 0,
            ist: 0,
            type_attr: 0,
            offset_mid: 0,
            offset_high: 0,
            zero: 0,
        }
    }

    fn set_handler(&mut self, handler: unsafe extern "x86-interrupt" fn(InterruptStackFrame), cs: u16) {
        let addr = handler as usize as u64;
        self.offset_low = addr as u16;
        self.selector = cs;
        self.ist = 0;
        self.type_attr = 0x8E;
        self.offset_mid = (addr >> 16) as u16;
        self.offset_high = (addr >> 32) as u32;
        self.zero = 0;
    }
}

#[repr(C, packed)]
struct IdtPtr {
    limit: u16,
    base: u64,
}

#[repr(C)]
struct InterruptStackFrame {
    rip: u64,
    cs: u64,
    rflags: u64,
    rsp: u64,
    ss: u64,
}

static mut IDT: [IdtEntry; 256] = [IdtEntry::empty(); 256];

fn current_cs() -> u16 {
    let cs: u16;
    unsafe {
        core::arch::asm!("mov {0:x}, cs", out(reg) cs, options(nomem, nostack, preserves_flags));
    }
    cs
}

pub fn init() {
    let cs = current_cs();
    unsafe {
        IDT[32].set_handler(timer_irq, cs);
        IDT[33].set_handler(keyboard_irq, cs);
        let ptr = IdtPtr {
            limit: (size_of::<[IdtEntry; 256]>() - 1) as u16,
            base: core::ptr::addr_of!(IDT) as u64,
        };
        core::arch::asm!("lidt [{}]", in(reg) &ptr, options(nostack, readonly));
    }
}

extern "x86-interrupt" fn timer_irq(_frame: InterruptStackFrame) {
    TICKS.fetch_add(1, Ordering::Relaxed);
    pic::eoi(0);
}

extern "x86-interrupt" fn keyboard_irq(_frame: InterruptStackFrame) {
    unsafe {
        if inb(0x64) & 1 != 0 {
            ps2::push_scancode(inb(0x60));
        }
    }
    pic::eoi(1);
}

pub fn sleep_ms(ms: u64) {
    let start = TICKS.load(Ordering::Relaxed);
    let need = (ms / 10).max(1);
    while TICKS.load(Ordering::Relaxed).wrapping_sub(start) < need {
        core::hint::spin_loop();
    }
}
