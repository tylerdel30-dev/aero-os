#![no_std]
#![no_main]
#![feature(abi_x86_interrupt)]

extern crate alloc;

mod arch;
mod brand;
mod desktop;
mod fat;
mod fb;
mod files;
mod fs;
mod handoff;
mod heap;
mod input;
mod kernel;
mod mem;
mod ps2;
mod session;
mod setup;
mod store;
mod ui;

use uefi::boot;
use uefi::prelude::*;
use uefi::proto::console::gop::GraphicsOutput;

#[entry]
fn main() -> Status {
    crate::heap::init();
    if uefi::helpers::init().is_err() {
        return Status::ABORTED;
    }

    let (ptr, len, width, height, stride, format) = {
        let gop_handle = match boot::get_handle_for_protocol::<GraphicsOutput>() {
            Ok(h) => h,
            Err(_) => return Status::UNSUPPORTED,
        };
        let mut gop = match boot::open_protocol_exclusive::<GraphicsOutput>(gop_handle) {
            Ok(g) => g,
            Err(_) => return Status::UNSUPPORTED,
        };
        pick_mode(&mut gop);
        let info = gop.current_mode_info();
        let (width, height) = info.resolution();
        let stride = info.stride();
        let format = info.pixel_format();
        let mut raw = gop.frame_buffer();
        (raw.as_mut_ptr(), raw.size(), width, height, stride, format)
    };

    let mut frame = unsafe { fb::Frame::from_raw(ptr, len, width, height, stride, format) };
    setup::run(&mut frame);
}

fn pick_mode(gop: &mut GraphicsOutput) {
    let mut best_i = None;
    let mut best_score = 0usize;
    for (i, mode) in gop.modes().enumerate() {
        let (w, h) = mode.info().resolution();
        if (1024..=1920).contains(&w) && (700..=1080).contains(&h) {
            let score = w * h;
            if score > best_score {
                best_score = score;
                best_i = Some(i);
            }
        }
    }
    if let Some(i) = best_i {
        if let Some(mode) = gop.modes().nth(i) {
            let _ = gop.set_mode(&mode);
        }
    }
}
