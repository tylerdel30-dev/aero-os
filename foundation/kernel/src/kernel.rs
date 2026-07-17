//! Enter Aero kernel mode: ExitBootServices + arch bring-up.

use uefi::boot::{self, MemoryType};
use uefi::proto::console::gop::PixelFormat;

use crate::arch;
use crate::handoff::{self, FbInfo};
use crate::heap;
use crate::mem::FrameBump;
use crate::ps2;

/// Capture framebuffer, exit boot services, init CPU + PS/2.
///
/// # Safety
/// Callers must drop all UEFI boot-service protocols first.
pub unsafe fn enter(fb_ptr: *mut u8, fb_len: usize, width: usize, height: usize, stride: usize, format: PixelFormat) {
    heap::init();
    handoff::set_fb(FbInfo {
        ptr: fb_ptr,
        len: fb_len,
        width,
        height,
        stride,
        format,
    });

    // ExitBootServices — after this, only runtime services + our code.
    let map = unsafe { boot::exit_boot_services(MemoryType::LOADER_DATA) };
    let _frames = FrameBump::from_map(&map);

    arch::init();
    ps2::init();
    handoff::enter_kernel_mode();
}
