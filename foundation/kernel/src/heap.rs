//! Kernel heap (works before and after ExitBootServices).

use core::sync::atomic::{AtomicBool, Ordering};
use linked_list_allocator::LockedHeap;

#[global_allocator]
static ALLOCATOR: LockedHeap = LockedHeap::empty();

static INIT: AtomicBool = AtomicBool::new(false);

/// 4 MiB static heap — independent of UEFI boot-services allocator.
static mut HEAP: [u8; 4 * 1024 * 1024] = [0; 4 * 1024 * 1024];

pub fn init() {
    if INIT.swap(true, Ordering::SeqCst) {
        return;
    }
    unsafe {
        let start = core::ptr::addr_of_mut!(HEAP) as *mut u8;
        ALLOCATOR.lock().init(start, HEAP.len());
    }
}
