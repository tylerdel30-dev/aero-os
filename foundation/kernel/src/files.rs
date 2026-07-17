//! In-desktop Files panel over FAT AERO/ directory.

use crate::fat::{self, DirEntry};
use crate::fb::Frame;
use crate::ui::{self, TEXT, TEXT_DIM};

pub struct FilesState {
    pub open: bool,
    pub idx: usize,
    pub entries: alloc::vec::Vec<DirEntry>,
}

impl FilesState {
    pub fn new() -> Self {
        Self {
            open: false,
            idx: 0,
            entries: alloc::vec::Vec::new(),
        }
    }

    pub fn refresh(&mut self) {
        self.entries = fat::list_aero_dir();
        if self.idx >= self.entries.len() && !self.entries.is_empty() {
            self.idx = self.entries.len() - 1;
        }
    }

    pub fn open_panel(&mut self) {
        self.refresh();
        self.open = true;
        self.idx = 0;
    }
}

pub fn draw(frame: &mut Frame, state: &FilesState) {
    if !state.open {
        return;
    }
    let w = frame.width();
    let h = frame.height();
    let pw = 480.min(w.saturating_sub(40));
    let ph = 320.min(h.saturating_sub(80));
    let px = w.saturating_sub(pw) / 2;
    let py = h.saturating_sub(ph) / 2;
    ui::draw_glass_card(frame, px, py, pw, ph);
    frame.draw_text(px + 24, py + 24, "Files — AERO/", TEXT);
    frame.draw_text(px + 24, py + 48, "Up/Down · Esc closes", TEXT_DIM);
    let list_top = py + 80;
    if state.entries.is_empty() {
        frame.draw_text(px + 24, list_top, "(no entries / disk unread)", TEXT_DIM);
        return;
    }
    for (i, e) in state.entries.iter().enumerate().take(8) {
        let label = if e.is_dir {
            alloc::format!("[{}] ", e.name)
        } else {
            alloc::format!("{} ({}b)", e.name, e.size)
        };
        ui::draw_list_item(
            frame,
            px + 20,
            list_top + i * 28,
            pw.saturating_sub(40),
            24,
            &label,
            i == state.idx,
        );
    }
}
