//! Host build script: bake PNG branding into raw RGBA for the UEFI kernel.

use std::env;
use std::fs;
use std::path::{Path, PathBuf};

fn main() {
    let manifest = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
    let repo = manifest
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .to_path_buf();
    let assets = repo.join("assets");
    let out = PathBuf::from(env::var("OUT_DIR").unwrap());

    println!("cargo:rerun-if-changed={}", assets.join("aero-logo.png").display());
    println!(
        "cargo:rerun-if-changed={}",
        assets.join("boot-splash.png").display()
    );
    println!(
        "cargo:rerun-if-changed={}",
        assets.join("start-button.png").display()
    );
    println!(
        "cargo:rerun-if-changed={}",
        assets.join("wallpapers/aero-clouds-dark.png").display()
    );
    println!(
        "cargo:rerun-if-changed={}",
        assets.join("wallpapers/aero-clouds-light.png").display()
    );
    println!(
        "cargo:rerun-if-changed={}",
        assets.join("wallpapers/night.png").display()
    );

    // Prefer cloud wallpapers the user provided; fall back to night.png.
    let dark_src = first_existing(&[
        assets.join("wallpapers/aero-clouds-dark.png"),
        assets.join("wallpapers/dark.png"),
        assets.join("wallpapers/night.png"),
    ]);
    let light_src = first_existing(&[
        assets.join("wallpapers/aero-clouds-light.png"),
        assets.join("wallpapers/light.png"),
        assets.join("wallpapers/night.png"),
    ]);
    let night_src = first_existing(&[
        assets.join("wallpapers/night.png"),
        assets.join("wallpapers/aero-clouds-dark.png"),
        assets.join("wallpapers/dark.png"),
    ]);
    let logo_src = first_existing(&[
        assets.join("aero-logo.png"),
        assets.join("firstboot-logo.png"),
        assets.join("aero-mark.png"),
    ]);
    let splash_src = first_existing(&[
        assets.join("boot-splash.png"),
        assets.join("aero-logo.png"),
    ]);
    let start_src = first_existing(&[
        assets.join("start-button.png"),
        assets.join("aero-logo.png"),
        assets.join("aero-mark.png"),
    ]);

    // Keep sizes modest for UEFI binary size / blit speed.
    bake_rgba(&dark_src, &out.join("wp_dark.rgba"), 960, 540);
    bake_rgba(&light_src, &out.join("wp_light.rgba"), 960, 540);
    bake_rgba(&night_src, &out.join("wp_night.rgba"), 960, 540);
    bake_rgba(&logo_src, &out.join("logo.rgba"), 96, 96);
    bake_rgba(&logo_src, &out.join("logo_lg.rgba"), 256, 256);
    bake_rgba(&splash_src, &out.join("boot_splash.rgba"), 1280, 720);
    bake_rgba(&start_src, &out.join("start_btn.rgba"), 48, 48);

    println!("cargo:rustc-env=AERO_WP_W=960");
    println!("cargo:rustc-env=AERO_WP_H=540");
    println!("cargo:rustc-env=AERO_LOGO_W=96");
    println!("cargo:rustc-env=AERO_LOGO_H=96");
    println!("cargo:rustc-env=AERO_LOGO_LG_W=256");
    println!("cargo:rustc-env=AERO_LOGO_LG_H=256");
    println!("cargo:rustc-env=AERO_SPLASH_W=1280");
    println!("cargo:rustc-env=AERO_SPLASH_H=720");
}

fn first_existing(paths: &[PathBuf]) -> PathBuf {
    for p in paths {
        if p.is_file() {
            return p.clone();
        }
    }
    panic!("missing branding PNG — expected files under assets/");
}

fn bake_rgba(src: &Path, dest: &Path, w: u32, h: u32) {
    let img = image::open(src)
        .unwrap_or_else(|e| panic!("open {}: {e}", src.display()))
        .resize_exact(w, h, image::imageops::FilterType::Lanczos3)
        .to_rgba8();
    fs::write(dest, img.as_raw()).unwrap_or_else(|e| panic!("write {}: {e}", dest.display()));
}
