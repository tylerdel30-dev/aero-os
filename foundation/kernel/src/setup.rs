//! Aero Setup: boot splash → wizard → desktop.

use crate::brand;
use crate::desktop;
use crate::fb::{Color, Frame};
use crate::input::{self, Key};
use crate::session::{Look, Session, LOOKS, REGIONS};
use crate::ui::{self, TEXT, TEXT_DIM};
use uefi::boot;

#[derive(Clone, Copy, PartialEq, Eq)]
enum Page {
    Hello,
    Account,
    Region,
    Appearance,
    Done,
}

pub fn run(frame: &mut Frame) -> ! {
    let mut session = Session::new();
    show_boot_to_setup(frame, session.look);
    run_wizard(frame, &mut session);
    desktop::run(frame, &mut session);
}

/// Interactive setup wizard (also reachable from the Start menu).
pub fn run_wizard(frame: &mut Frame, session: &mut Session) {
    let mut page = Page::Hello;

    loop {
        draw(frame, page, session);
        let key = input::wait_key();

        match page {
            Page::Hello => {
                if matches!(key, Key::Enter | Key::Space) {
                    page = Page::Account;
                }
            }
            Page::Account => match key {
                Key::Backspace => {
                    if session.name_len > 0 {
                        session.name_len -= 1;
                        session.name[session.name_len] = 0;
                    }
                }
                Key::Char(c) if session.name_len < session.name.len() => {
                    if c.is_ascii_alphanumeric() || c == b'-' || c == b'_' || c == b'.' {
                        session.name[session.name_len] = c;
                        session.name_len += 1;
                    }
                }
                Key::Space if session.name_len < session.name.len() => {
                    session.name[session.name_len] = b' ';
                    session.name_len += 1;
                }
                Key::Enter => page = Page::Region,
                Key::Escape => page = Page::Hello,
                _ => {}
            },
            Page::Region => match key {
                Key::Up | Key::Left => {
                    session.region_idx = session
                        .region_idx
                        .checked_sub(1)
                        .unwrap_or(REGIONS.len() - 1);
                }
                Key::Down | Key::Right => {
                    session.region_idx = (session.region_idx + 1) % REGIONS.len();
                }
                Key::Enter | Key::Space => page = Page::Appearance,
                Key::Escape => page = Page::Account,
                _ => {}
            },
            Page::Appearance => match key {
                Key::Up | Key::Left => {
                    session.look_idx = session.look_idx.checked_sub(1).unwrap_or(LOOKS.len() - 1);
                    session.look = LOOKS[session.look_idx].0;
                }
                Key::Down | Key::Right => {
                    session.look_idx = (session.look_idx + 1) % LOOKS.len();
                    session.look = LOOKS[session.look_idx].0;
                }
                Key::Enter | Key::Space => page = Page::Done,
                Key::Escape => page = Page::Region,
                _ => {}
            },
            Page::Done => {
                if matches!(key, Key::Enter | Key::Space) {
                    return;
                }
                if matches!(key, Key::Escape) {
                    page = Page::Appearance;
                }
            }
        }
    }
}

fn lerp(a: isize, b: isize, i: usize, n: usize) -> isize {
    if n == 0 {
        return b;
    }
    a + (b - a) * i as isize / n as isize
}

fn setup_card_geom(frame: &Frame) -> (usize, usize, usize, usize) {
    let w = frame.width();
    let h = frame.height();
    let card_w = 520.min(w.saturating_sub(40));
    let card_h = 420.min(h.saturating_sub(40));
    let card_x = w.saturating_sub(card_w) / 2;
    let card_y = h.saturating_sub(card_h) / 2;
    (card_x, card_y, card_w, card_h)
}

fn paint_boot_bg(frame: &mut Frame) {
    frame.clear(Color::rgb(0, 0, 0));
    let splash = brand::boot_splash();
    if splash.pixels.len() >= splash.width * splash.height * 4 {
        frame.blit_contain(&splash);
    }
}

/// Boot splash with logo overlay, then shrink the logo into the Setup card.
fn show_boot_to_setup(frame: &mut Frame, look: Look) {
    let logo = brand::logo_large();
    let w = frame.width() as isize;
    let h = frame.height() as isize;

    let start_size = 280isize.min(w.min(h) * 45 / 100).max(160);
    let start_x = (w - start_size) / 2;
    let start_y = (h - start_size) / 2 - h / 18;

    let (card_x, card_y, card_w, _card_h) = setup_card_geom(frame);
    let end_size = 96isize;
    let end_x = (card_x + card_w.saturating_sub(end_size as usize) / 2) as isize;
    let end_y = (card_y + 18) as isize;

    paint_boot_bg(frame);
    frame.blit_rgba_scaled(
        &logo,
        start_x.max(0) as usize,
        start_y.max(0) as usize,
        start_size as usize,
        start_size as usize,
    );
    for _ in 0..180 {
        if input::poll_key().is_some() {
            break;
        }
        boot::stall(10_000);
    }
    while input::poll_key().is_some() {}

    const FRAMES: usize = 28;
    for i in 0..=FRAMES {
        let size = lerp(start_size, end_size, i, FRAMES).max(24) as usize;
        let x = lerp(start_x, end_x, i, FRAMES).max(0) as usize;
        let y = lerp(start_y, end_y, i, FRAMES).max(0) as usize;

        if i < FRAMES / 2 {
            paint_boot_bg(frame);
        } else {
            paint_wallpaper(frame, look);
            let card_progress = (i - FRAMES / 2) * 2;
            if card_progress > FRAMES / 3 {
                let (cx, cy, cw, ch) = setup_card_geom(frame);
                ui::draw_glass_card(frame, cx, cy, cw, ch);
            }
        }

        frame.blit_rgba_scaled(&logo, x, y, size, size);
        boot::stall(16_000);
        if input::poll_key().is_some() {
            break;
        }
    }
    while input::poll_key().is_some() {}
}

fn paint_wallpaper(frame: &mut Frame, look: Look) {
    let img = match look {
        Look::Light => brand::wallpaper_light(),
        Look::Dark => brand::wallpaper_dark(),
        Look::Night => brand::wallpaper_night(),
    };
    if img.pixels.len() >= img.width * img.height * 4 {
        frame.blit_cover(&img);
    } else {
        frame.draw_wallpaper_fallback();
    }
}

fn page_index(page: Page) -> usize {
    match page {
        Page::Hello => 0,
        Page::Account => 1,
        Page::Region => 2,
        Page::Appearance => 3,
        Page::Done => 4,
    }
}

fn draw(frame: &mut Frame, page: Page, session: &Session) {
    paint_wallpaper(frame, session.look);

    let h = frame.height();
    let (card_x, card_y, card_w, card_h) = setup_card_geom(frame);

    ui::draw_glass_card(frame, card_x, card_y, card_w, card_h);

    let logo = brand::logo();
    let lx = card_x + card_w.saturating_sub(logo.width) / 2;
    let ly = card_y + 18;
    frame.blit_rgba(&logo, lx, ly);

    frame.draw_text(card_x + 28, card_y + 18 + logo.height + 8, "Aero OS", TEXT);
    frame.draw_text(
        card_x + 28,
        card_y + 18 + logo.height + 28,
        "Foundation Preview 0.2",
        TEXT_DIM,
    );

    ui::draw_progress_dots(
        frame,
        card_x + 28,
        card_y + 18 + logo.height + 48,
        5,
        page_index(page),
    );

    let body_y = card_y + 18 + logo.height + 72;

    match page {
        Page::Hello => {
            frame.draw_text(card_x + 28, body_y, "Hello", TEXT);
            frame.draw_text(card_x + 28, body_y + 28, "Welcome to Aero.", TEXT_DIM);
            frame.draw_text(
                card_x + 28,
                body_y + 48,
                "A few quick steps, then your desktop.",
                TEXT_DIM,
            );
            frame.draw_text(card_x + 28, body_y + 78, "Press Enter to continue.", TEXT_DIM);
            ui::draw_button(
                frame,
                card_x + card_w.saturating_sub(160) / 2,
                card_y + card_h.saturating_sub(70),
                160,
                40,
                "Continue",
                true,
            );
        }
        Page::Account => {
            frame.draw_text(card_x + 28, body_y, "Your Name", TEXT);
            frame.draw_text(card_x + 28, body_y + 22, "Type a name, then Enter", TEXT_DIM);
            let name = session.name_str();
            ui::draw_text_field(
                frame,
                card_x + 28,
                body_y + 56,
                card_w.saturating_sub(56),
                40,
                name,
                true,
            );
            ui::draw_button(
                frame,
                card_x + card_w.saturating_sub(160) / 2,
                card_y + card_h.saturating_sub(70),
                160,
                40,
                "Next",
                true,
            );
        }
        Page::Region => {
            frame.draw_text(card_x + 28, body_y, "Select Region", TEXT);
            frame.draw_text(card_x + 28, body_y + 22, "Up/Down then Enter", TEXT_DIM);
            let list_top = body_y + 48;
            for (i, name) in REGIONS.iter().enumerate() {
                let iy = list_top + i * 28;
                if iy + 24 > card_y + card_h.saturating_sub(50) {
                    break;
                }
                ui::draw_list_item(
                    frame,
                    card_x + 28,
                    iy,
                    card_w.saturating_sub(56),
                    24,
                    name,
                    i == session.region_idx,
                );
            }
        }
        Page::Appearance => {
            frame.draw_text(card_x + 28, body_y, "Choose Your Look", TEXT);
            frame.draw_text(
                card_x + 28,
                body_y + 22,
                "Wallpaper updates behind the glass.",
                TEXT_DIM,
            );
            let list_top = body_y + 56;
            for (i, (_look, name)) in LOOKS.iter().enumerate() {
                let iy = list_top + i * 36;
                ui::draw_list_item(
                    frame,
                    card_x + 28,
                    iy,
                    card_w.saturating_sub(56),
                    30,
                    name,
                    i == session.look_idx,
                );
            }
        }
        Page::Done => {
            frame.draw_text(card_x + 28, body_y, "You're Ready", TEXT);
            frame.draw_text(card_x + 28, body_y + 28, "Enter opens your desktop.", TEXT_DIM);
            frame.draw_text(card_x + 28, body_y + 60, "Name:", TEXT_DIM);
            frame.draw_text(card_x + 100, body_y + 60, session.display_name(), TEXT);
            frame.draw_text(card_x + 28, body_y + 84, "Region:", TEXT_DIM);
            frame.draw_text(card_x + 100, body_y + 84, session.region_name(), TEXT);
            frame.draw_text(card_x + 28, body_y + 108, "Look:", TEXT_DIM);
            frame.draw_text(card_x + 100, body_y + 108, session.look_name(), TEXT);
            ui::draw_button(
                frame,
                card_x + card_w.saturating_sub(180) / 2,
                card_y + card_h.saturating_sub(70),
                180,
                40,
                "Enter Desktop",
                true,
            );
        }
    }

    frame.draw_text(
        16,
        h.saturating_sub(28),
        "Aero Native Foundation",
        Color::rgba(180, 210, 240, 140),
    );
}
