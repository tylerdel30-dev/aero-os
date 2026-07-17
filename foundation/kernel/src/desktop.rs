//! Aero desktop shell — wallpaper, glass taskbar, Start menu.

use crate::brand;
use crate::fb::{Color, Frame};
use crate::input::{self, Key};
use crate::session::{Look, Session};
use crate::ui::{self, TEXT, TEXT_DIM};
use uefi::runtime;

const TASKBAR_H: usize = 56;
const START_SIZE: usize = 40;

const MENU_ITEMS: &[&str] = &[
    "About Aero",
    "Change Look",
    "Run Setup Again",
];

pub fn run(frame: &mut Frame, session: &mut Session) -> ! {
    let mut menu_open = false;
    let mut menu_idx: usize = 0;
    let mut about_open = false;
    let mut tick: u32 = 0;
    let mut time_buf = [b'0'; 5]; // HH:MM
    update_clock(&mut time_buf);

    loop {
        draw(frame, session, menu_open, menu_idx, about_open, &time_buf, tick);
        match input::wait_key_timeout(500_000) {
            Some(key) => {
                if about_open {
                    if matches!(key, Key::Enter | Key::Escape | Key::Space) {
                        about_open = false;
                    }
                    continue;
                }
                match key {
                    Key::Escape => {
                        menu_open = false;
                    }
                    Key::Space | Key::Tab => {
                        menu_open = !menu_open;
                        menu_idx = 0;
                    }
                    Key::Up | Key::Left if menu_open => {
                        menu_idx = menu_idx.checked_sub(1).unwrap_or(MENU_ITEMS.len() - 1);
                    }
                    Key::Down | Key::Right if menu_open => {
                        menu_idx = (menu_idx + 1) % MENU_ITEMS.len();
                    }
                    Key::Enter if menu_open => {
                        match menu_idx {
                            0 => {
                                about_open = true;
                                menu_open = false;
                            }
                            1 => {
                                session.look_idx = (session.look_idx + 1) % 3;
                                session.look = crate::session::LOOKS[session.look_idx].0;
                                menu_open = false;
                            }
                            2 => {
                                crate::setup::run_wizard(frame, session);
                                menu_open = false;
                                about_open = false;
                            }
                            _ => {}
                        }
                    }
                    Key::Enter if !menu_open => {
                        menu_open = true;
                        menu_idx = 0;
                    }
                    Key::Char(b'1') => {
                        session.look_idx = 0;
                        session.look = Look::Light;
                    }
                    Key::Char(b'2') => {
                        session.look_idx = 1;
                        session.look = Look::Dark;
                    }
                    Key::Char(b'3') => {
                        session.look_idx = 2;
                        session.look = Look::Night;
                    }
                    _ => {}
                }
            }
            None => {
                tick = tick.wrapping_add(1);
                update_clock(&mut time_buf);
            }
        }
    }
}

fn update_clock(buf: &mut [u8; 5]) {
    buf[2] = b':';
    if let Ok(t) = runtime::get_time() {
        buf[0] = b'0' + (t.hour() / 10) as u8;
        buf[1] = b'0' + (t.hour() % 10) as u8;
        buf[3] = b'0' + (t.minute() / 10) as u8;
        buf[4] = b'0' + (t.minute() % 10) as u8;
    } else {
        buf.copy_from_slice(b"--:--");
    }
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

fn draw(
    frame: &mut Frame,
    session: &Session,
    menu_open: bool,
    menu_idx: usize,
    about_open: bool,
    time_buf: &[u8; 5],
    tick: u32,
) {
    paint_wallpaper(frame, session.look);

    let w = frame.width();
    let h = frame.height();
    let bar_y = h.saturating_sub(TASKBAR_H);

    // Soft welcome card
    let card_w = 420.min(w.saturating_sub(48));
    let card_h = 150;
    let card_x = 28;
    let card_y = 28;
    ui::draw_glass_card(frame, card_x, card_y, card_w, card_h);
    let mut hello = [0u8; 40];
    let hello_str = write_hello(&mut hello, session.display_name());
    frame.draw_text(card_x + 24, card_y + 28, hello_str, TEXT);
    frame.draw_text(card_x + 24, card_y + 56, "Aero Foundation Desktop", TEXT_DIM);
    frame.draw_text(card_x + 24, card_y + 84, "Space = Start menu", TEXT_DIM);
    frame.draw_text(card_x + 24, card_y + 108, "1/2/3 = Light/Dark/Night", TEXT_DIM);

    // Subtle pulse hint on logo mark
    let logo = brand::logo();
    let lx = w.saturating_sub(logo.width + 36);
    let ly = 36;
    if tick % 4 < 3 {
        frame.blit_rgba(&logo, lx, ly);
    } else {
        frame.blit_rgba_scaled(&logo, lx + 2, ly + 2, logo.width.saturating_sub(4), logo.height.saturating_sub(4));
    }

    // Taskbar
    ui::draw_taskbar(frame, bar_y, TASKBAR_H);
    let start = brand::start_button();
    let sx: usize = 10;
    let sy = bar_y + (TASKBAR_H.saturating_sub(START_SIZE)) / 2;
    if menu_open {
        frame.fill_round_rect(
            sx.saturating_sub(4),
            sy.saturating_sub(4),
            START_SIZE + 8,
            START_SIZE + 8,
            12,
            Color::rgba(80, 170, 255, 120),
        );
    }
    frame.blit_rgba_scaled(&start, sx, sy, START_SIZE, START_SIZE);

    frame.draw_text(sx + START_SIZE + 14, bar_y + 20, "Aero", TEXT);
    let clock = core::str::from_utf8(time_buf).unwrap_or("--:--");
    frame.draw_text(w.saturating_sub(70), bar_y + 20, clock, TEXT);

    if menu_open {
        let mw = 280.min(w.saturating_sub(24));
        let mh = 52 + MENU_ITEMS.len() * 40;
        let mx = 12;
        let my = bar_y.saturating_sub(mh + 10);
        ui::draw_menu_panel(frame, mx, my, mw, mh);
        frame.draw_text(mx + 20, my + 16, session.display_name(), TEXT);
        frame.draw_text(mx + 20, my + 34, session.region_name(), TEXT_DIM);
        for (i, item) in MENU_ITEMS.iter().enumerate() {
            ui::draw_list_item(
                frame,
                mx + 14,
                my + 56 + i * 40,
                mw.saturating_sub(28),
                32,
                item,
                i == menu_idx,
            );
        }
    }

    if about_open {
        let aw = 460.min(w.saturating_sub(40));
        let ah = 220;
        let ax = w.saturating_sub(aw) / 2;
        let ay = h.saturating_sub(ah) / 2;
        ui::draw_glass_card(frame, ax, ay, aw, ah);
        let about_logo = brand::logo();
        frame.blit_rgba(
            &about_logo,
            ax + aw.saturating_sub(about_logo.width) / 2,
            ay + 18,
        );
        frame.draw_text(ax + 28, ay + 120, "Aero OS Foundation 0.1", TEXT);
        frame.draw_text(ax + 28, ay + 144, "Native UEFI · glass desktop", TEXT_DIM);
        frame.draw_text(ax + 28, ay + 168, "Enter to close", TEXT_DIM);
    }
}

fn write_hello<'a>(buf: &'a mut [u8; 40], name: &str) -> &'a str {
    let prefix = b"Welcome, ";
    let mut i = 0;
    for &b in prefix {
        if i < buf.len() {
            buf[i] = b;
            i += 1;
        }
    }
    for b in name.bytes().take(20) {
        if i < buf.len() {
            buf[i] = b;
            i += 1;
        }
    }
    if i < buf.len() {
        buf[i] = b'!';
        i += 1;
    }
    core::str::from_utf8(&buf[..i]).unwrap_or("Welcome!")
}
