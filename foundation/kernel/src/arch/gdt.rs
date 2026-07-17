//! Flat GDT — UEFI already set long-mode segments; keep a valid table loaded.

use core::mem::size_of;

#[repr(C, packed)]
struct GdtPtr {
    limit: u16,
    base: u64,
}

#[repr(C, align(8))]
struct Gdt {
    null: u64,
    code: u64,
    data: u64,
}

static mut GDT: Gdt = Gdt {
    null: 0,
    code: 0x00AF_9A00_0000_FFFF,
    data: 0x00CF_9200_0000_FFFF,
};

pub fn init() {
    // Load our GDT but do not far-jump — keep UEFI CS selector for IDT compatibility.
    unsafe {
        let ptr = GdtPtr {
            limit: (size_of::<Gdt>() - 1) as u16,
            base: core::ptr::addr_of!(GDT) as u64,
        };
        core::arch::asm!("lgdt [{}]", in(reg) &ptr, options(nostack, readonly));
    }
}
