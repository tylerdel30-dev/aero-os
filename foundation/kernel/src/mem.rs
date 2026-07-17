//! Physical memory helpers from the UEFI memory map (post-exit).

use uefi::mem::memory_map::{MemoryMap, MemoryType};

/// Simple bump allocator over conventional memory regions (post-exit reserve).
pub struct FrameBump {
    next: u64,
    end: u64,
}

impl FrameBump {
    pub fn from_map(map: &impl MemoryMap) -> Self {
        let mut best_start = 0u64;
        let mut best_len = 0u64;
        for desc in map.entries() {
            if desc.ty == MemoryType::CONVENTIONAL {
                let start = desc.phys_start;
                let len = desc.page_count * 4096;
                if start >= 0x100000 && len > best_len {
                    best_start = start;
                    best_len = len;
                }
            }
        }
        let start = best_start.saturating_add(8 * 1024 * 1024);
        let end = best_start.saturating_add(best_len);
        Self {
            next: if start < end { start } else { best_start },
            end,
        }
    }

    pub fn alloc_pages(&mut self, count: u64) -> Option<u64> {
        let size = count * 4096;
        let align = (self.next + 4095) & !4095;
        if align.saturating_add(size) > self.end {
            return None;
        }
        self.next = align + size;
        Some(align)
    }
}
