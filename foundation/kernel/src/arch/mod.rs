//! x86_64 bring-up: ports, GDT, IDT, PIC, PIT.

pub mod gdt;
pub mod idt;
pub mod pic;
pub mod pit;
pub mod port;

pub fn init() {
    gdt::init();
    idt::init();
    pic::init();
    pit::init(100); // 100 Hz
    unsafe { core::arch::asm!("sti") };
}

pub fn hlt() {
    unsafe { core::arch::asm!("hlt") };
}
