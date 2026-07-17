//! Embedded branding (RGBA bytes produced by build.rs).

pub struct RgbaImage {
    pub width: usize,
    pub height: usize,
    pub pixels: &'static [u8],
}

const WP_W: usize = 960;
const WP_H: usize = 540;
const LOGO_W: usize = 96;
const LOGO_H: usize = 96;
const LOGO_LG_W: usize = 256;
const LOGO_LG_H: usize = 256;
const SPLASH_W: usize = 1280;
const SPLASH_H: usize = 720;
const START_W: usize = 48;
const START_H: usize = 48;

pub fn wallpaper_dark() -> RgbaImage {
    RgbaImage {
        width: WP_W,
        height: WP_H,
        pixels: include_bytes!(concat!(env!("OUT_DIR"), "/wp_dark.rgba")),
    }
}

pub fn wallpaper_light() -> RgbaImage {
    RgbaImage {
        width: WP_W,
        height: WP_H,
        pixels: include_bytes!(concat!(env!("OUT_DIR"), "/wp_light.rgba")),
    }
}

pub fn wallpaper_night() -> RgbaImage {
    RgbaImage {
        width: WP_W,
        height: WP_H,
        pixels: include_bytes!(concat!(env!("OUT_DIR"), "/wp_night.rgba")),
    }
}

pub fn logo() -> RgbaImage {
    RgbaImage {
        width: LOGO_W,
        height: LOGO_H,
        pixels: include_bytes!(concat!(env!("OUT_DIR"), "/logo.rgba")),
    }
}

pub fn logo_large() -> RgbaImage {
    RgbaImage {
        width: LOGO_LG_W,
        height: LOGO_LG_H,
        pixels: include_bytes!(concat!(env!("OUT_DIR"), "/logo_lg.rgba")),
    }
}

pub fn boot_splash() -> RgbaImage {
    RgbaImage {
        width: SPLASH_W,
        height: SPLASH_H,
        pixels: include_bytes!(concat!(env!("OUT_DIR"), "/boot_splash.rgba")),
    }
}

pub fn start_button() -> RgbaImage {
    RgbaImage {
        width: START_W,
        height: START_H,
        pixels: include_bytes!(concat!(env!("OUT_DIR"), "/start_btn.rgba")),
    }
}
