//! Host builder: package aero-kernel.efi into a UEFI-bootable disk image / ISO.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

fn main() -> ExitCode {
    let foundation = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .to_path_buf();
    let repo = foundation.parent().unwrap().to_path_buf();
    let out_dir = repo.join("out");
    fs::create_dir_all(&out_dir).unwrap();

    println!("==> Building aero-kernel (x86_64-unknown-uefi)");
    let status = Command::new("cargo")
        .current_dir(&foundation)
        .args([
            "+nightly",
            "build",
            "--release",
            "-p",
            "aero-kernel",
            "--target",
            "x86_64-unknown-uefi",
        ])
        .status()
        .expect("cargo");
    if !status.success() {
        eprintln!("ERROR: kernel build failed");
        return ExitCode::FAILURE;
    }

    let efi = foundation
        .join("target/x86_64-unknown-uefi/release/aero-kernel.efi");
    if !efi.is_file() {
        eprintln!("ERROR: missing {}", efi.display());
        return ExitCode::FAILURE;
    }

    let work = foundation.join("target/foundation-esp");
    let _ = fs::remove_dir_all(&work);
    fs::create_dir_all(work.join("EFI/BOOT")).unwrap();
    fs::copy(&efi, work.join("EFI/BOOT/BOOTX64.EFI")).unwrap();
    fs::write(
        work.join("AERO-README.TXT"),
        "Aero OS Foundation Preview 0.2\nNative UEFI kernel.\n",
    )
    .unwrap();

    let img = out_dir.join("AeroOS-Foundation-0.2.0.img");
    let iso = out_dir.join("AeroOS-Foundation-0.2.0.iso");

    // FAT ESP disk image (bootable as HDD in VMware UEFI)
    if !make_esp_image(&work, &img) {
        eprintln!("ERROR: failed to create ESP image");
        return ExitCode::FAILURE;
    }

    // Also make an El Torito UEFI ISO for USB writers that expect .iso
    if !make_uefi_iso(&work, &img, &iso) {
        eprintln!("WARN: ISO creation failed (img still OK)");
    }

    sha256(&img);
    if iso.is_file() {
        sha256(&iso);
    }

    println!("==> Foundation artifacts:");
    println!("    {}", img.display());
    if iso.is_file() {
        println!("    {}", iso.display());
    }
    ExitCode::SUCCESS
}

fn make_esp_image(esp_tree: &Path, img: &Path) -> bool {
    // 64 MiB FAT32 image
    let _ = fs::remove_file(img);
    let status = Command::new("dd")
        .args([
            "if=/dev/zero",
            &format!("of={}", img.display()),
            "bs=1M",
            "count=64",
            "status=none",
        ])
        .status();
    if !status.map(|s| s.success()).unwrap_or(false) {
        return false;
    }
    if !Command::new("mkfs.vfat")
        .args(["-F", "32", "-n", "AERO_FOUND", &img.display().to_string()])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
    {
        return false;
    }
    // mcopy files into image
    let boot = esp_tree.join("EFI/BOOT/BOOTX64.EFI");
    let ok = Command::new("mmd")
        .args(["-i", &img.display().to_string(), "::/EFI"])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
        && Command::new("mmd")
            .args(["-i", &img.display().to_string(), "::/EFI/BOOT"])
            .status()
            .map(|s| s.success())
            .unwrap_or(false)
        && Command::new("mcopy")
            .args([
                "-i",
                &img.display().to_string(),
                &boot.display().to_string(),
                "::/EFI/BOOT/BOOTX64.EFI",
            ])
            .status()
            .map(|s| s.success())
            .unwrap_or(false);
    let _ = Command::new("mcopy")
        .args([
            "-i",
            &img.display().to_string(),
            &esp_tree.join("AERO-README.TXT").display().to_string(),
            "::/AERO-README.TXT",
        ])
        .status();
    ok
}

fn make_uefi_iso(esp_tree: &Path, esp_img: &Path, iso: &Path) -> bool {
    let _ = fs::remove_file(iso);
    // xorriso El Torito UEFI from the ESP image + ISO9660 tree
    Command::new("xorriso")
        .args([
            "-as",
            "mkisofs",
            "-R",
            "-J",
            "-V",
            "AERO_FOUND_01",
            "-o",
            &iso.display().to_string(),
            "-e",
            "--interval:appended_partition_2:all::",
            "-append_partition",
            "2",
            "0xef",
            &esp_img.display().to_string(),
            "-no-emul-boot",
            "-isohybrid-gpt-basdat",
            &esp_tree.display().to_string(),
        ])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn sha256(path: &Path) {
    if let Ok(out) = Command::new("sha256sum").arg(path).output() {
        if out.status.success() {
            let text = String::from_utf8_lossy(&out.stdout);
            let _ = fs::write(
                path.with_extension(format!(
                    "{}.sha256",
                    path.extension().and_then(|e| e.to_str()).unwrap_or("bin")
                )),
                text.as_bytes(),
            );
            // simpler: path.sha256
            let sha = PathBuf::from(format!("{}.sha256", path.display()));
            let _ = fs::write(&sha, text.as_bytes());
            print!("{text}");
        }
    }
}
