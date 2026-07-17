//! Boot handoff: framebuffer + flags after ExitBootServices.

use core::sync::atomic::{AtomicBool, Ordering};
use uefi::proto::console::gop::PixelFormat;

static KERNEL_MODE: AtomicBool = AtomicBool::new(false);

#[derive(Clone, Copy)]
pub struct FbInfo {
    pub ptr: *mut u8,
    pub len: usize,
    pub width: usize,
    pub height: usize,
    pub stride: usize,
    pub format: PixelFormat,
}

static mut FB: Option<FbInfo> = None;

pub fn set_fb(info: FbInfo) {
    unsafe { FB = Some(info) };
}

pub fn fb() -> Option<FbInfo> {
    unsafe { FB }
}

pub fn enter_kernel_mode() {
    KERNEL_MODE.store(true, Ordering::SeqCst);
}

pub fn is_kernel_mode() -> bool {
    KERNEL_MODE.load(Ordering::SeqCst)
}
