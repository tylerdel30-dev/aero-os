//! Host builder: package aero-kernel.efi + AERO/ store into a sized ESP / ISO.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const VERSION: &str = "0.3.0";

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
        format!("Aero OS Foundation {VERSION}\nNative UEFI kernel + installable AERO volume.\n"),
    )
    .unwrap();

    // Pack store catalog into AERO/store on the ESP.
    let aero = work.join("AERO");
    let store_dst = aero.join("store");
    fs::create_dir_all(&store_dst).unwrap();
    fs::write(
        aero.join("INSTALLED.TXT"),
        "Boot media — run Setup Install to persist session.\n",
    )
    .unwrap();

    let store_src = repo.join("store");
    if store_src.join("index.json").is_file() {
        let _ = fs::copy(store_src.join("index.json"), store_dst.join("index.json"));
    }
    let apps_src = store_src.join("apps");
    if apps_src.is_dir() {
        for entry in fs::read_dir(&apps_src).unwrap() {
            let entry = entry.unwrap();
            let path = entry.path();
            if path.extension().and_then(|e| e.to_str()) == Some("aero") {
                let name = path.file_name().unwrap();
                fs::copy(&path, store_dst.join(name)).unwrap();
            }
        }
    }

    let img = out_dir.join(format!("AeroOS-Foundation-{VERSION}.img"));
    let iso = out_dir.join(format!("AeroOS-Foundation-{VERSION}.iso"));

    let mib = estimate_esp_mib(&work);
    println!("==> ESP size: {mib} MiB (payload-based)");

    if !make_esp_image(&work, &img, mib) {
        eprintln!("ERROR: failed to create ESP image");
        return ExitCode::FAILURE;
    }

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

fn dir_size(path: &Path) -> u64 {
    let mut total = 0u64;
    let walker = match fs::read_dir(path) {
        Ok(w) => w,
        Err(_) => return 0,
    };
    for entry in walker.flatten() {
        let p = entry.path();
        if p.is_dir() {
            total = total.saturating_add(dir_size(&p));
        } else if let Ok(meta) = entry.metadata() {
            total = total.saturating_add(meta.len());
        }
    }
    total
}

fn estimate_esp_mib(esp_tree: &Path) -> u64 {
    let bytes = dir_size(esp_tree);
    // FAT overhead + headroom for session.json writes after install.
    let need = bytes.saturating_add(2 * 1024 * 1024);
    let mib = (need + 1024 * 1024 - 1) / (1024 * 1024);
    mib.clamp(8, 32)
}

fn make_esp_image(esp_tree: &Path, img: &Path, mib: u64) -> bool {
    let _ = fs::remove_file(img);
    let status = Command::new("dd")
        .args([
            "if=/dev/zero",
            &format!("of={}", img.display()),
            "bs=1M",
            &format!("count={mib}"),
            "status=none",
        ])
        .status();
    if !status.map(|s| s.success()).unwrap_or(false) {
        return false;
    }
    // Let mkfs pick FAT12/16/32 based on size (avoids FAT32 33MiB minimum).
    if !Command::new("mkfs.vfat")
        .args(["-n", "AERO_OS", &img.display().to_string()])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
    {
        return false;
    }

    let img_s = img.display().to_string();
    let boot = esp_tree.join("EFI/BOOT/BOOTX64.EFI");

    let mut ok = mmd(&img_s, "::/EFI")
        && mmd(&img_s, "::/EFI/BOOT")
        && mcopy(
            &img_s,
            &boot.display().to_string(),
            "::/EFI/BOOT/BOOTX64.EFI",
        );

    let _ = mcopy(
        &img_s,
        &esp_tree.join("AERO-README.TXT").display().to_string(),
        "::/AERO-README.TXT",
    );

    // Recursive copy of AERO/ tree via mcopy -s
    let aero = esp_tree.join("AERO");
    if aero.is_dir() {
        ok = Command::new("mcopy")
            .args(["-i", &img_s, "-s", &aero.display().to_string(), "::/AERO"])
            .status()
            .map(|s| s.success())
            .unwrap_or(false)
            && ok;
    }
    ok
}

fn mmd(img: &str, path: &str) -> bool {
    Command::new("mmd")
        .args(["-i", img, path])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn mcopy(img: &str, src: &str, dst: &str) -> bool {
    Command::new("mcopy")
        .args(["-i", img, src, dst])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn make_uefi_iso(esp_tree: &Path, esp_img: &Path, iso: &Path) -> bool {
    let _ = fs::remove_file(iso);
    Command::new("xorriso")
        .args([
            "-as",
            "mkisofs",
            "-R",
            "-J",
            "-V",
            "AERO_OS",
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
            let sha = PathBuf::from(format!("{}.sha256", path.display()));
            let _ = fs::write(&sha, text.as_bytes());
            print!("{text}");
        }
    }
}
