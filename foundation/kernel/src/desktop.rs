//! Aero desktop shell — frosted glass, Start menu, Store, mouse.

use crate::brand;
use crate::fb::{Color, Frame};
use crate::input::{self, Input, Key};
use crate::session::{Look, Session, LOOKS};
use crate::store;
use crate::ui::{self, TEXT, TEXT_DIM};
use uefi::boot;
use uefi::runtime;

const TASKBAR_H: usize = 60;
const START_SIZE: usize = 44;

const MENU_ITEMS: &[&str] = &[
    "Aero Store",
    "About Aero",
    "Control Center",
    "Change Look",
    "Run Setup Again",
];

pub fn run(frame: &mut Frame, session: &mut Session) -> ! {
    let mut input = Input::new(frame.width(), frame.height());
    let mut menu_open = false;
    let mut menu_idx: usize = 0;
    let mut about_open = false;
    let mut control_open = false;
    let mut store_open = false;
    let mut store_idx: usize = 0;
    let mut hello_open = false;
    let mut tick: u32 = 0;
    let mut time_buf = [b'0'; 5];
    update_clock(&mut time_buf);

    loop {
        let ptr = input.poll_pointer();
        draw(
            frame,
            session,
            menu_open,
            menu_idx,
            about_open,
            control_open,
            store_open,
            store_idx,
            hello_open,
            &time_buf,
            tick,
            ptr.x,
            ptr.y,
            ptr.available,
        );

        if ptr.left_pressed {
            handle_click(
                frame,
                session,
                ptr.x,
                ptr.y,
                &mut menu_open,
                &mut menu_idx,
                &mut about_open,
                &mut control_open,
                &mut store_open,
                &mut store_idx,
                &mut hello_open,
            );
        }

        match input::wait_key_timeout(50_000) {
            Some(key) => {
                if hello_open {
                    if matches!(key, Key::Enter | Key::Escape | Key::Space) {
                        hello_open = false;
                    }
                    continue;
                }
                if about_open {
                    if matches!(key, Key::Enter | Key::Escape | Key::Space) {
                        about_open = false;
                    }
                    continue;
                }
                if store_open {
                    match key {
                        Key::Escape => store_open = false,
                        Key::Up | Key::Left => {
                            store_idx = store_idx
                                .checked_sub(1)
                                .unwrap_or(store::APPS.len() - 1);
                        }
                        Key::Down | Key::Right => {
                            store_idx = (store_idx + 1) % store::APPS.len();
                        }
                        Key::Enter | Key::Space => {
                            launch_store_app(
                                store_idx,
                                session,
                                frame,
                                &mut about_open,
                                &mut control_open,
                                &mut store_open,
                                &mut hello_open,
                            );
                        }
                        _ => {}
                    }
                    continue;
                }
                if control_open {
                    match key {
                        Key::Escape | Key::Enter | Key::Space => control_open = false,
                        Key::Left | Key::Up => {
                            session.look_idx = session.look_idx.checked_sub(1).unwrap_or(2);
                            session.look = LOOKS[session.look_idx].0;
                        }
                        Key::Right | Key::Down => {
                            session.look_idx = (session.look_idx + 1) % 3;
                            session.look = LOOKS[session.look_idx].0;
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
                    continue;
                }
                match key {
                    Key::Escape => menu_open = false,
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
                        activate_menu(
                            menu_idx,
                            session,
                            frame,
                            &mut about_open,
                            &mut control_open,
                            &mut store_open,
                            &mut menu_open,
                            &mut hello_open,
                        );
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
                if tick % 10 == 0 {
                    update_clock(&mut time_buf);
                }
            }
        }
        boot::stall(8_000);
    }
}

fn handle_click(
    frame: &mut Frame,
    session: &mut Session,
    x: usize,
    y: usize,
    menu_open: &mut bool,
    menu_idx: &mut usize,
    about_open: &mut bool,
    control_open: &mut bool,
    store_open: &mut bool,
    store_idx: &mut usize,
    hello_open: &mut bool,
) {
    let w = frame.width();
    let h = frame.height();
    let bar_y = h.saturating_sub(TASKBAR_H);
    let sx = 12usize;
    let sy = bar_y + (TASKBAR_H.saturating_sub(START_SIZE)) / 2;

    if *hello_open {
        *hello_open = false;
        return;
    }
    if *about_open {
        *about_open = false;
        return;
    }
    if *store_open {
        let sw = 460.min(w.saturating_sub(40));
        let sh = 80 + store::APPS.len() * 44;
        let sx0 = w.saturating_sub(sw) / 2;
        let sy0 = h.saturating_sub(sh) / 2;
        for (i, _) in store::APPS.iter().enumerate() {
            let iy = sy0 + 64 + i * 44;
            if ui::hit(x, y, sx0 + 20, iy, sw.saturating_sub(40), 36) {
                *store_idx = i;
                launch_store_app(
                    i,
                    session,
                    frame,
                    about_open,
                    control_open,
                    store_open,
                    hello_open,
                );
                return;
            }
        }
        if !ui::hit(x, y, sx0, sy0, sw, sh) {
            *store_open = false;
        }
        return;
    }
    if *control_open {
        let cw = 360.min(w.saturating_sub(40));
        let ch = 200;
        let cx = w.saturating_sub(cw) / 2;
        let cy = h.saturating_sub(ch) / 2;
        for i in 0..3 {
            let chip_x = cx + 28 + i * 100;
            let chip_y = cy + 90;
            if ui::hit(x, y, chip_x, chip_y, 88, 32) {
                session.look_idx = i;
                session.look = LOOKS[i].0;
            }
        }
        if !ui::hit(x, y, cx, cy, cw, ch) {
            *control_open = false;
        }
        return;
    }
    if *menu_open {
        let mw = 300.min(w.saturating_sub(24));
        let mh = 70 + MENU_ITEMS.len() * 42;
        let mx = 12;
        let my = bar_y.saturating_sub(mh + 12);
        for (i, _) in MENU_ITEMS.iter().enumerate() {
            let iy = my + 70 + i * 42;
            if ui::hit(x, y, mx + 14, iy, mw.saturating_sub(28), 34) {
                *menu_idx = i;
                activate_menu(
                    i,
                    session,
                    frame,
                    about_open,
                    control_open,
                    store_open,
                    menu_open,
                    hello_open,
                );
                return;
            }
        }
        if !ui::hit(x, y, mx, my, mw, mh) {
            *menu_open = false;
        }
        return;
    }
    if ui::hit(
        x,
        y,
        sx.saturating_sub(4),
        sy.saturating_sub(4),
        START_SIZE + 8,
        START_SIZE + 8,
    ) {
        *menu_open = true;
        *menu_idx = 0;
        return;
    }
    let card_x = 28usize;
    let card_y = 28usize;
    for i in 0..3 {
        let chip_x = card_x + 24 + i * 100;
        let chip_y = card_y + 118;
        if ui::hit(x, y, chip_x, chip_y, 88, 28) {
            session.look_idx = i;
            session.look = LOOKS[i].0;
        }
    }
}

fn activate_menu(
    idx: usize,
    session: &mut Session,
    frame: &mut Frame,
    about_open: &mut bool,
    control_open: &mut bool,
    store_open: &mut bool,
    menu_open: &mut bool,
    hello_open: &mut bool,
) {
    match idx {
        0 => {
            *store_open = true;
            *menu_open = false;
        }
        1 => {
            *about_open = true;
            *menu_open = false;
        }
        2 => {
            *control_open = true;
            *menu_open = false;
        }
        3 => {
            session.look_idx = (session.look_idx + 1) % 3;
            session.look = LOOKS[session.look_idx].0;
            *menu_open = false;
        }
        4 => {
            crate::setup::run_wizard(frame, session);
            *menu_open = false;
            *about_open = false;
            *control_open = false;
            *store_open = false;
            *hello_open = false;
        }
        _ => {}
    }
}

fn launch_store_app(
    idx: usize,
    session: &mut Session,
    frame: &mut Frame,
    about_open: &mut bool,
    control_open: &mut bool,
    store_open: &mut bool,
    hello_open: &mut bool,
) {
    let Some(app) = store::APPS.get(idx) else {
        return;
    };
    match app.action {
        0 => {
            *hello_open = true;
            *store_open = false;
        }
        1 => {
            *about_open = true;
            *store_open = false;
        }
        2 => {
            *control_open = true;
            *store_open = false;
        }
        3 => {
            *store_open = false;
            crate::setup::run_wizard(frame, session);
        }
        _ => {}
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
    control_open: bool,
    store_open: bool,
    store_idx: usize,
    hello_open: bool,
    time_buf: &[u8; 5],
    tick: u32,
    mx: usize,
    my: usize,
    mouse_ok: bool,
) {
    paint_wallpaper(frame, session.look);

    let w = frame.width();
    let h = frame.height();
    let bar_y = h.saturating_sub(TASKBAR_H);

    let card_w = 440.min(w.saturating_sub(48));
    let card_h = 168;
    let card_x = 28;
    let card_y = 28;
    ui::draw_glass_card(frame, card_x, card_y, card_w, card_h);
    let mut hello = [0u8; 40];
    let hello_str = write_hello(&mut hello, session.display_name());
    frame.draw_text(card_x + 24, card_y + 24, hello_str, TEXT);
    frame.draw_text(card_x + 24, card_y + 50, "Aero Foundation 0.2", TEXT_DIM);
    frame.draw_text(
        card_x + 24,
        card_y + 72,
        if mouse_ok {
            "Click Start · Store in menu"
        } else {
            "Space = Start · Store in menu"
        },
        TEXT_DIM,
    );
    frame.draw_text(card_x + 24, card_y + 94, session.region_name(), TEXT_DIM);
    for (i, (_look, name)) in LOOKS.iter().enumerate() {
        ui::draw_chip(
            frame,
            card_x + 24 + i * 100,
            card_y + 118,
            88,
            28,
            name,
            i == session.look_idx,
        );
    }

    let logo = brand::logo();
    let lx = w.saturating_sub(logo.width + 40);
    let ly = 40;
    let pulse = if tick % 6 < 4 { 0 } else { 2 };
    frame.blit_rgba_scaled(
        &logo,
        lx + pulse,
        ly + pulse,
        logo.width.saturating_sub(pulse * 2),
        logo.height.saturating_sub(pulse * 2),
    );

    ui::draw_taskbar(frame, bar_y, TASKBAR_H);
    let start = brand::start_button();
    let sx = 12usize;
    let sy = bar_y + (TASKBAR_H.saturating_sub(START_SIZE)) / 2;
    if menu_open || ui::hit(mx, my, sx, sy, START_SIZE, START_SIZE) {
        frame.fill_round_rect(
            sx.saturating_sub(5),
            sy.saturating_sub(5),
            START_SIZE + 10,
            START_SIZE + 10,
            14,
            Color::rgba(90, 180, 255, 140),
        );
    }
    frame.blit_rgba_scaled(&start, sx, sy, START_SIZE, START_SIZE);
    frame.draw_text(sx + START_SIZE + 16, bar_y + 22, "Aero", TEXT);
    let clock = core::str::from_utf8(time_buf).unwrap_or("--:--");
    let pill_w = 88usize;
    let pill_x = w.saturating_sub(pill_w + 16);
    frame.fill_round_rect(pill_x, bar_y + 14, pill_w, 32, 16, Color::rgba(255, 255, 255, 28));
    frame.draw_text(pill_x + 22, bar_y + 22, clock, TEXT);

    if menu_open {
        let mw = 300.min(w.saturating_sub(24));
        let mh = 70 + MENU_ITEMS.len() * 42;
        let menux = 12;
        let menuy = bar_y.saturating_sub(mh + 12);
        ui::draw_menu_panel(frame, menux, menuy, mw, mh);
        let start_sm = brand::start_button();
        frame.blit_rgba_scaled(&start_sm, menux + 18, menuy + 16, 36, 36);
        frame.draw_text(menux + 64, menuy + 18, session.display_name(), TEXT);
        frame.draw_text(menux + 64, menuy + 38, "Foundation Desktop", TEXT_DIM);
        for (i, item) in MENU_ITEMS.iter().enumerate() {
            let selected = i == menu_idx
                || ui::hit(
                    mx,
                    my,
                    menux + 14,
                    menuy + 70 + i * 42,
                    mw.saturating_sub(28),
                    34,
                );
            ui::draw_list_item(
                frame,
                menux + 14,
                menuy + 70 + i * 42,
                mw.saturating_sub(28),
                34,
                item,
                selected,
            );
        }
    }

    if store_open {
        let sw = 460.min(w.saturating_sub(40));
        let sh = 80 + store::APPS.len() * 44;
        let sx0 = w.saturating_sub(sw) / 2;
        let sy0 = h.saturating_sub(sh) / 2;
        ui::draw_glass_card(frame, sx0, sy0, sw, sh);
        frame.draw_text(sx0 + 24, sy0 + 22, "Aero Store", TEXT);
        frame.draw_text(sx0 + 24, sy0 + 44, ".aero apps on Foundation", TEXT_DIM);
        for (i, app) in store::APPS.iter().enumerate() {
            let iy = sy0 + 64 + i * 44;
            let selected = i == store_idx
                || ui::hit(mx, my, sx0 + 20, iy, sw.saturating_sub(40), 36);
            ui::draw_list_item(
                frame,
                sx0 + 20,
                iy,
                sw.saturating_sub(40),
                36,
                app.name,
                selected,
            );
        }
    }

    if control_open {
        let cw = 360.min(w.saturating_sub(40));
        let ch = 200;
        let cx = w.saturating_sub(cw) / 2;
        let cy = h.saturating_sub(ch) / 2;
        ui::draw_glass_card(frame, cx, cy, cw, ch);
        frame.draw_text(cx + 28, cy + 28, "Control Center", TEXT);
        frame.draw_text(cx + 28, cy + 54, "Pick a look for your desktop", TEXT_DIM);
        for (i, (_look, name)) in LOOKS.iter().enumerate() {
            ui::draw_chip(
                frame,
                cx + 28 + i * 100,
                cy + 90,
                88,
                32,
                name,
                i == session.look_idx,
            );
        }
        frame.draw_text(cx + 28, cy + 150, "Esc / click outside to close", TEXT_DIM);
    }

    if about_open {
        let aw = 480.min(w.saturating_sub(40));
        let ah = 250;
        let ax = w.saturating_sub(aw) / 2;
        let ay = h.saturating_sub(ah) / 2;
        ui::draw_glass_card(frame, ax, ay, aw, ah);
        let about_logo = brand::logo();
        frame.blit_rgba(
            &about_logo,
            ax + aw.saturating_sub(about_logo.width) / 2,
            ay + 20,
        );
        frame.draw_text(ax + 28, ay + 130, "Aero OS Foundation 0.2", TEXT);
        frame.draw_text(ax + 28, ay + 154, "Native UEFI · frosted glass · Store", TEXT_DIM);
        frame.draw_text(ax + 28, ay + 178, "Mouse + keyboard ready", TEXT_DIM);
        frame.draw_text(ax + 28, ay + 208, "Enter / click to close", TEXT_DIM);
    }

    if hello_open {
        let aw = 420.min(w.saturating_sub(40));
        let ah = 180;
        let ax = w.saturating_sub(aw) / 2;
        let ay = h.saturating_sub(ah) / 2;
        ui::draw_glass_card(frame, ax, ay, aw, ah);
        frame.draw_text(ax + 28, ay + 36, "Hello Aero", TEXT);
        frame.draw_text(ax + 28, ay + 64, "Loaded from hello.aero", TEXT_DIM);
        frame.draw_text(ax + 28, ay + 88, "id: dev.aero.hello", TEXT_DIM);
        frame.draw_text(ax + 28, ay + 120, "Enter / click to close", TEXT_DIM);
    }

    if mouse_ok {
        ui::draw_cursor(frame, mx, my);
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
