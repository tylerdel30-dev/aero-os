//! Glass-lite compositor / widget helpers.

use crate::fb::{Color, Frame};

pub const GLASS: Color = Color::rgba(20, 36, 56, 160);
pub const GLASS_DARK: Color = Color::rgba(12, 22, 36, 190);
pub const GLASS_BORDER: Color = Color::rgba(180, 220, 255, 90);
pub const TEXT: Color = Color::rgb(232, 244, 255);
pub const TEXT_DIM: Color = Color::rgba(200, 220, 240, 200);
pub const ACCENT: Color = Color::rgba(80, 170, 255, 220);
pub const ACCENT_HOT: Color = Color::rgba(120, 200, 255, 240);

pub fn draw_glass_card(frame: &mut Frame, x: usize, y: usize, w: usize, h: usize) {
    // Soft outer glow
    frame.fill_round_rect(
        x.saturating_sub(4),
        y.saturating_sub(4),
        w + 8,
        h + 8,
        28,
        GLASS_BORDER,
    );
    // Main frosted panel (alpha over wallpaper)
    frame.fill_round_rect(x, y, w, h, 24, GLASS);
    // Top highlight edge
    frame.fill_round_rect(
        x + 8,
        y + 4,
        w.saturating_sub(16),
        3,
        2,
        Color::rgba(255, 255, 255, 40),
    );
}

pub fn draw_button(frame: &mut Frame, x: usize, y: usize, w: usize, h: usize, label: &str, hot: bool) {
    let bg = if hot { ACCENT_HOT } else { ACCENT };
    frame.fill_round_rect(x, y, w, h, 12, bg);
    let tw = label.len() * 9;
    let tx = x + w.saturating_sub(tw) / 2;
    let ty = y + h.saturating_sub(16) / 2;
    frame.draw_text(tx, ty, label, Color::rgb(8, 20, 36));
}

pub fn draw_list_item(
    frame: &mut Frame,
    x: usize,
    y: usize,
    w: usize,
    h: usize,
    label: &str,
    selected: bool,
) {
    if selected {
        frame.fill_round_rect(x, y, w, h, 10, Color::rgba(70, 140, 220, 180));
    } else {
        frame.fill_round_rect(x, y, w, h, 10, Color::rgba(30, 50, 75, 120));
    }
    frame.draw_text(x + 16, y + h.saturating_sub(16) / 2, label, TEXT);
}

pub fn draw_progress_dots(frame: &mut Frame, x: usize, y: usize, total: usize, current: usize) {
    for i in 0..total {
        let dx = x + i * 18;
        let filled = i <= current;
        let c = if filled {
            ACCENT_HOT
        } else {
            Color::rgba(120, 150, 180, 100)
        };
        frame.fill_round_rect(dx, y, 10, 10, 5, c);
    }
}

pub fn draw_text_field(
    frame: &mut Frame,
    x: usize,
    y: usize,
    w: usize,
    h: usize,
    text: &str,
    caret: bool,
) {
    frame.fill_round_rect(x, y, w, h, 10, Color::rgba(8, 16, 28, 180));
    frame.fill_round_rect(
        x + 1,
        y + 1,
        w.saturating_sub(2),
        h.saturating_sub(2),
        9,
        Color::rgba(40, 70, 100, 90),
    );
    frame.draw_text(x + 14, y + h.saturating_sub(16) / 2, text, TEXT);
    if caret {
        let cx = x + 14 + text.len() * 9;
        frame.fill_round_rect(cx, y + 8, 2, h.saturating_sub(16), 1, ACCENT_HOT);
    }
}

pub fn draw_taskbar(frame: &mut Frame, y: usize, h: usize) {
    let w = frame.width();
    frame.fill_round_rect(0, y, w, h, 0, GLASS_DARK);
    // Top glass edge
    frame.fill_round_rect(0, y, w, 2, 0, Color::rgba(180, 220, 255, 70));
}

pub fn draw_menu_panel(frame: &mut Frame, x: usize, y: usize, w: usize, h: usize) {
    frame.fill_round_rect(
        x.saturating_sub(3),
        y.saturating_sub(3),
        w + 6,
        h + 6,
        22,
        GLASS_BORDER,
    );
    frame.fill_round_rect(x, y, w, h, 18, GLASS_DARK);
    frame.fill_round_rect(
        x + 10,
        y + 4,
        w.saturating_sub(20),
        3,
        2,
        Color::rgba(255, 255, 255, 35),
    );
}
