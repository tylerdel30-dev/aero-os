//! Glass-lite compositor / widget helpers.

use crate::fb::{Color, Frame};

pub const GLASS: Color = Color::rgba(18, 34, 58, 150);
pub const GLASS_DARK: Color = Color::rgba(10, 18, 32, 200);
pub const GLASS_BORDER: Color = Color::rgba(200, 230, 255, 100);
pub const TEXT: Color = Color::rgb(236, 246, 255);
pub const TEXT_DIM: Color = Color::rgba(190, 214, 236, 210);
pub const ACCENT: Color = Color::rgba(70, 165, 255, 230);
pub const ACCENT_HOT: Color = Color::rgba(130, 205, 255, 245);

pub fn draw_glass_card(frame: &mut Frame, x: usize, y: usize, w: usize, h: usize) {
    // Soft drop shadow
    frame.fill_round_rect(
        x.saturating_add(6),
        y.saturating_add(10),
        w,
        h,
        26,
        Color::rgba(0, 0, 0, 70),
    );
    // Outer glow
    frame.fill_round_rect(
        x.saturating_sub(3),
        y.saturating_sub(3),
        w + 6,
        h + 6,
        28,
        Color::rgba(160, 210, 255, 55),
    );
    // Frosted panel
    frame.fill_glass_round_rect(x, y, w, h, 24, GLASS);
    // Specular top edge
    frame.fill_round_rect(
        x + 10,
        y + 3,
        w.saturating_sub(20),
        2,
        1,
        Color::rgba(255, 255, 255, 55),
    );
    // Inner rim
    frame.fill_round_rect(
        x + 1,
        y + 1,
        w.saturating_sub(2),
        1,
        0,
        Color::rgba(255, 255, 255, 25),
    );
}

pub fn draw_button(frame: &mut Frame, x: usize, y: usize, w: usize, h: usize, label: &str, hot: bool) {
    let bg = if hot { ACCENT_HOT } else { ACCENT };
    frame.fill_round_rect(x, y, w, h, 12, Color::rgba(0, 0, 0, 50));
    frame.fill_round_rect(x, y, w, h.saturating_sub(1), 12, bg);
    frame.fill_round_rect(
        x + 6,
        y + 2,
        w.saturating_sub(12),
        2,
        1,
        Color::rgba(255, 255, 255, 60),
    );
    let tw = label.len() * 9;
    let tx = x + w.saturating_sub(tw) / 2;
    let ty = y + h.saturating_sub(16) / 2;
    frame.draw_text(tx, ty, label, Color::rgb(6, 16, 30));
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
        frame.fill_round_rect(x, y, w, h, 10, Color::rgba(70, 150, 230, 200));
        frame.fill_round_rect(
            x + 6,
            y + 2,
            w.saturating_sub(12),
            2,
            1,
            Color::rgba(255, 255, 255, 40),
        );
    } else {
        frame.fill_round_rect(x, y, w, h, 10, Color::rgba(28, 48, 72, 110));
    }
    frame.draw_text(x + 16, y + h.saturating_sub(16) / 2, label, TEXT);
}

pub fn draw_progress_dots(frame: &mut Frame, x: usize, y: usize, total: usize, current: usize) {
    for i in 0..total {
        let dx = x + i * 18;
        let filled = i <= current;
        let (ww, hh, c) = if filled {
            (12usize, 12usize, ACCENT_HOT)
        } else {
            (10, 10, Color::rgba(120, 150, 180, 90))
        };
        let oy = if filled { y.saturating_sub(1) } else { y };
        frame.fill_round_rect(dx, oy, ww, hh, ww / 2, c);
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
    frame.fill_round_rect(x, y, w, h, 10, Color::rgba(0, 0, 0, 90));
    frame.fill_glass_round_rect(x + 1, y + 1, w.saturating_sub(2), h.saturating_sub(2), 9, Color::rgba(40, 70, 105, 100));
    frame.draw_text(x + 14, y + h.saturating_sub(16) / 2, text, TEXT);
    if caret {
        let cx = x + 14 + text.len() * 9;
        frame.fill_round_rect(cx, y + 8, 2, h.saturating_sub(16), 1, ACCENT_HOT);
    }
}

pub fn draw_taskbar(frame: &mut Frame, y: usize, h: usize) {
    let w = frame.width();
    frame.fill_round_rect(0, y + 4, w, h, 0, Color::rgba(0, 0, 0, 80));
    frame.fill_glass_round_rect(0, y, w, h, 0, GLASS_DARK);
    frame.fill_round_rect(0, y, w, 2, 0, Color::rgba(200, 230, 255, 80));
    frame.fill_round_rect(0, y + 2, w, 1, 0, Color::rgba(255, 255, 255, 20));
}

pub fn draw_menu_panel(frame: &mut Frame, x: usize, y: usize, w: usize, h: usize) {
    frame.fill_round_rect(
        x.saturating_add(4),
        y.saturating_add(8),
        w,
        h,
        20,
        Color::rgba(0, 0, 0, 80),
    );
    frame.fill_round_rect(
        x.saturating_sub(2),
        y.saturating_sub(2),
        w + 4,
        h + 4,
        20,
        Color::rgba(170, 210, 255, 60),
    );
    frame.fill_glass_round_rect(x, y, w, h, 18, GLASS_DARK);
    frame.fill_round_rect(
        x + 12,
        y + 4,
        w.saturating_sub(24),
        2,
        1,
        Color::rgba(255, 255, 255, 45),
    );
}

pub fn draw_chip(frame: &mut Frame, x: usize, y: usize, w: usize, h: usize, label: &str, on: bool) {
    let bg = if on {
        Color::rgba(80, 170, 255, 210)
    } else {
        Color::rgba(30, 50, 75, 140)
    };
    frame.fill_round_rect(x, y, w, h, h / 2, bg);
    let tw = label.len() * 9;
    frame.draw_text(
        x + w.saturating_sub(tw) / 2,
        y + h.saturating_sub(16) / 2,
        label,
        if on {
            Color::rgb(8, 20, 36)
        } else {
            TEXT
        },
    );
}

pub fn draw_cursor(frame: &mut Frame, x: usize, y: usize) {
    for i in 0..18 {
        frame.put_pixel(x, y + i, Color::rgb(15, 22, 35));
        if x + 1 < frame.width() {
            frame.put_pixel(x + 1, y + i, Color::rgb(240, 248, 255));
        }
    }
    for i in 0..10 {
        if x + i < frame.width() && y + i < frame.height() {
            frame.put_pixel(x + i, y + i, Color::rgb(15, 22, 35));
        }
        if x + i + 1 < frame.width() && y + i < frame.height() {
            frame.put_pixel(x + i + 1, y + i, Color::rgb(240, 248, 255));
        }
    }
}

pub fn hit(x: usize, y: usize, rx: usize, ry: usize, rw: usize, rh: usize) -> bool {
    x >= rx && y >= ry && x < rx + rw && y < ry + rh
}
