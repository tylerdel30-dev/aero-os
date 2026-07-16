#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${AERO_PROJECT_ROOT:-}" ]]; then
    SCRIPT_DIR="${AERO_PROJECT_ROOT}"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

WORKSPACE="${SCRIPT_DIR}/build-workspace"
ISO_ROOT="${WORKSPACE}/iso-root"
STAGING="${WORKSPACE}/staging"
OUTPUT_DIR="${SCRIPT_DIR}/out"
AERO_BIN="${SCRIPT_DIR}/aero-shell"
AERO_SETTINGS_BIN="${SCRIPT_DIR}/aero-settings"
AERO_LOGO="${SCRIPT_DIR}/assets/aero-logo.png"
AERO_OS_VERSION="1.0.1"
AERO_OS_CODENAME="Stratus"
FREEBSD_ARCH="amd64"
FREEBSD_VERSION="14.3-RELEASE"
FREEBSD_MIRROR="https://download.freebsd.org/releases/${FREEBSD_ARCH}/${FREEBSD_VERSION}"

IN_CONTAINER="${AERO_BUILD_CONTAINER:-0}"

if [[ "${IN_CONTAINER}" != "1" && "$(uname -s)" != "FreeBSD" ]]; then
    echo "Aero OS native builds require FreeBSD."
    echo "On Windows, run:  .\\build_os.ps1"
    exit 1
fi

if [[ "${IN_CONTAINER}" != "1" && "${EUID}" -ne 0 ]]; then
    echo "Aero OS build requires root privileges. Re-run with: sudo $0"
    exit 1
fi

if [[ "${IN_CONTAINER}" == "1" ]]; then
    echo "==> Aero OS build (FreeBSD container — host: ${AERO_HOST_OS:-unknown})"
else
    echo "==> Installing build dependencies via pkg(8)"
    env ASSUME_ALWAYS_YES=yes pkg update
    env ASSUME_ALWAYS_YES=yes pkg install \
        bash \
        swift \
        gtk4 \
        gtk4-layer-shell \
        pkgconf \
        labwc \
        wayland \
        pipewire \
        wireplumber \
        mesa-drivers \
        drm-kmod \
        wpa_supplicant \
        sudo \
        curl \
        git \
        xorriso \
        cdrtools \
        mtools \
        gpart \
        ntfs-3g \
        thunar \
        foot \
        inter-font \
        freebsd-release \
        bsdinstall
fi

echo "==> Wiping previous workspace directories"
rm -rf "${WORKSPACE}" "${OUTPUT_DIR}" "${AERO_BIN}" "${AERO_SETTINGS_BIN}"
mkdir -p "${WORKSPACE}" "${OUTPUT_DIR}" "${ISO_ROOT}" "${STAGING}"

echo "==> Compiling Aero OS desktop shell (Swift 5.10 + GTK4)"
GTK4_CFLAGS="$(pkg-config --cflags gtk4)"
GTK4_LIBS="$(pkg-config --libs gtk4)"
LAYER_CFLAGS="$(pkg-config --cflags gtk4-layer-shell-0)"
LAYER_LIBS="$(pkg-config --libs gtk4-layer-shell-0)"

swiftc "${SCRIPT_DIR}/main.swift" \
    -O \
    -o "${AERO_BIN}" \
    ${GTK4_CFLAGS} ${LAYER_CFLAGS} \
    ${GTK4_LIBS} ${LAYER_LIBS} \
    -Xlinker -rpath -Xlinker /usr/local/lib

echo "==> Compiling Aero Settings app (Swift 5.10 + GTK4)"
swiftc "${SCRIPT_DIR}/aero-settings.swift" \
    -O \
    -o "${AERO_SETTINGS_BIN}" \
    ${GTK4_CFLAGS} \
    ${GTK4_LIBS} \
    -Xlinker -rpath -Xlinker /usr/local/lib

echo "==> Compiling Aero FirstBoot experience (Swift 5.10 + GTK4 + layer-shell)"
swiftc "${SCRIPT_DIR}/aero-firstboot.swift" \
    -O \
    -o "${SCRIPT_DIR}/aero-firstboot" \
    ${GTK4_CFLAGS} ${LAYER_CFLAGS} \
    ${GTK4_LIBS} ${LAYER_LIBS} \
    -Xlinker -rpath -Xlinker /usr/local/lib

echo "==> Compiling Aero Update screen (boot logo + loading bar)"
swiftc "${SCRIPT_DIR}/aero-update-ui.swift" \
    -O \
    -o "${SCRIPT_DIR}/aero-update-ui" \
    ${GTK4_CFLAGS} ${LAYER_CFLAGS} \
    ${GTK4_LIBS} ${LAYER_LIBS} \
    -Xlinker -rpath -Xlinker /usr/local/lib

echo "==> Compiling Aero App Store (Swift 5.10 + GTK4)"
swiftc "${SCRIPT_DIR}/aero-store.swift" \
    -O \
    -o "${SCRIPT_DIR}/aero-store" \
    ${GTK4_CFLAGS} \
    ${GTK4_LIBS} \
    -Xlinker -rpath -Xlinker /usr/local/lib

echo "==> Compiling Aero Lock screen (Swift 5.10 + GTK4 + layer-shell)"
swiftc "${SCRIPT_DIR}/aero-lock.swift" \
    -O \
    -o "${SCRIPT_DIR}/aero-lock" \
    ${GTK4_CFLAGS} ${LAYER_CFLAGS} \
    ${GTK4_LIBS} ${LAYER_LIBS} \
    -Xlinker -rpath -Xlinker /usr/local/lib

echo "==> Fetching FreeBSD base system (${FREEBSD_VERSION})"
cd "${STAGING}"
fetch -o base.txz "${FREEBSD_MIRROR}/base.txz"
fetch -o kernel.txz "${FREEBSD_MIRROR}/kernel.txz"

echo "==> Extracting Unix base into ISO root"
tar -xpf "${STAGING}/base.txz" -C "${ISO_ROOT}"
tar -xpf "${STAGING}/kernel.txz" -C "${ISO_ROOT}"

echo "==> Bootstrapping pkg inside ISO root"
mkdir -p "${ISO_ROOT}/usr/local/etc/pkg/repos"
cp /etc/pkg/FreeBSD.conf "${ISO_ROOT}/usr/local/etc/pkg/FreeBSD.conf"
mkdir -p "${ISO_ROOT}/var/db/pkg/repos"
cp -R /var/db/pkg/repos/FreeBSD "${ISO_ROOT}/var/db/pkg/repos/FreeBSD" 2>/dev/null || true
chroot "${ISO_ROOT}" /usr/sbin/pkg -y bootstrap || true
chroot "${ISO_ROOT}" /usr/sbin/pkg update -f

echo "==> Installing Aero OS package set"
grep -v '^#' "${SCRIPT_DIR}/profile/packages.amd64" | grep -v '^[[:space:]]*$' | \
    chroot "${ISO_ROOT}" xargs /usr/sbin/pkg install -y

echo "==> Staging Aero OS shell, theme, and installer configuration"
install -d "${ISO_ROOT}/usr/local/bin"
install -d "${ISO_ROOT}/usr/local/share/aero"
install -d "${ISO_ROOT}/usr/local/share/aero/sounds"
install -d "${ISO_ROOT}/usr/local/etc/bsdinstall/aero"
install -d "${ISO_ROOT}/usr/local/etc/rc.d"
install -d "${ISO_ROOT}/usr/local/sbin"
install -d "${ISO_ROOT}/usr/share/skel/.config"

install -m 0755 "${AERO_BIN}" "${ISO_ROOT}/usr/local/bin/aero-shell"
install -m 0755 "${AERO_SETTINGS_BIN}" "${ISO_ROOT}/usr/local/bin/aero-settings"
install -m 0755 "${SCRIPT_DIR}/aero-firstboot" "${ISO_ROOT}/usr/local/bin/aero-firstboot"
install -m 0755 "${SCRIPT_DIR}/aero-update-ui" "${ISO_ROOT}/usr/local/bin/aero-update-ui"
install -m 0755 "${SCRIPT_DIR}/aero-store" "${ISO_ROOT}/usr/local/bin/aero-store"
install -m 0755 "${SCRIPT_DIR}/aero-lock" "${ISO_ROOT}/usr/local/bin/aero-lock"
install -m 0644 "${SCRIPT_DIR}/style.css" "${ISO_ROOT}/usr/local/share/aero/style.css"

echo "==> Staging chill sound scheme"
if [[ ! -d "${SCRIPT_DIR}/assets/sounds" ]] || [[ -z "$(ls -A "${SCRIPT_DIR}/assets/sounds"/*.wav 2>/dev/null || true)" ]]; then
    if command -v python3 >/dev/null 2>&1; then
        python3 "${SCRIPT_DIR}/tools/generate_sounds.py" || true
    elif command -v python >/dev/null 2>&1; then
        python "${SCRIPT_DIR}/tools/generate_sounds.py" || true
    fi
fi
if [[ -d "${SCRIPT_DIR}/assets/sounds" ]]; then
    install -m 0644 "${SCRIPT_DIR}/assets/sounds/"*.wav "${ISO_ROOT}/usr/local/share/aero/sounds/" 2>/dev/null || true
    install -m 0644 "${SCRIPT_DIR}/assets/sounds/scheme.json" \
        "${ISO_ROOT}/usr/local/share/aero/sounds/scheme.json" 2>/dev/null || true
fi
install -m 0755 "${SCRIPT_DIR}/tools/aero-sound" "${ISO_ROOT}/usr/local/bin/aero-sound"

if [[ -f "${AERO_LOGO}" ]]; then
    echo "==> Staging Aero OS boot splash and branding"
    install -m 0644 "${AERO_LOGO}" "${ISO_ROOT}/usr/local/share/aero/aero-logo.png"
    install -m 0644 "${AERO_LOGO}" "${ISO_ROOT}/boot/aero-splash.png"
else
    echo "WARNING: assets/aero-logo.png not found — skipping boot splash staging"
fi

if [[ -f "${SCRIPT_DIR}/assets/firstboot-logo.png" ]]; then
    echo "==> Staging first-boot logo"
    install -m 0644 "${SCRIPT_DIR}/assets/firstboot-logo.png" \
        "${ISO_ROOT}/usr/local/share/aero/firstboot-logo.png"
else
    echo "WARNING: assets/firstboot-logo.png not found — first boot will skip straight to setup"
fi

if [[ -f "${SCRIPT_DIR}/assets/start-button.png" ]]; then
    echo "==> Staging start menu button icon"
    install -m 0644 "${SCRIPT_DIR}/assets/start-button.png" \
        "${ISO_ROOT}/usr/local/share/aero/start-button.png"
else
    echo "WARNING: assets/start-button.png not found — start button will use text fallback"
fi

if [[ -d "${SCRIPT_DIR}/assets/wallpapers" ]]; then
    echo "==> Staging Aero OS wallpapers (light / dark / night)"
    install -d "${ISO_ROOT}/usr/local/share/aero/wallpapers"
    for mode in light dark night; do
        if [[ -f "${SCRIPT_DIR}/assets/wallpapers/${mode}.png" ]]; then
            install -m 0644 "${SCRIPT_DIR}/assets/wallpapers/${mode}.png" \
                "${ISO_ROOT}/usr/local/share/aero/wallpapers/${mode}.png"
        else
            echo "WARNING: wallpaper ${mode}.png missing"
        fi
    done
else
    echo "WARNING: assets/wallpapers directory not found — desktop will use gradient fallback"
fi

cat > "${ISO_ROOT}/boot/loader.conf" <<'LOADER'
autoboot_delay="1"
beastie_disable="YES"
loader_logo="none"
boot_mute="YES"
splash="/boot/aero-splash.png"
vbe_max_resolution="1920x1080"
kern.vty=vt
LOADER
install -m 0644 "${SCRIPT_DIR}/bsdinstall/installer.conf" \
    "${ISO_ROOT}/usr/local/etc/bsdinstall/aero/installer.conf"
install -m 0644 "${SCRIPT_DIR}/bsdinstall/partition.conf" \
    "${ISO_ROOT}/usr/local/etc/bsdinstall/aero/partition.conf"
install -m 0755 "${SCRIPT_DIR}/overlay/usr/local/sbin/aero-install" \
    "${ISO_ROOT}/usr/local/sbin/aero-install"
install -m 0755 "${SCRIPT_DIR}/overlay/usr/local/etc/rc.d/aero_shell" \
    "${ISO_ROOT}/usr/local/etc/rc.d/aero_shell"
install -m 0755 "${SCRIPT_DIR}/overlay/usr/local/etc/rc.d/labwc" \
    "${ISO_ROOT}/usr/local/etc/rc.d/labwc"
install -m 0755 "${SCRIPT_DIR}/overlay/usr/local/etc/rc.d/aero_firstboot" \
    "${ISO_ROOT}/usr/local/etc/rc.d/aero_firstboot"
install -m 0644 "${SCRIPT_DIR}/overlay/etc/rc.conf.aero" \
    "${ISO_ROOT}/etc/rc.conf.aero"

echo "==> Staging labwc window management configuration"
install -d "${ISO_ROOT}/etc/xdg/labwc"
install -m 0644 "${SCRIPT_DIR}/overlay/etc/xdg/labwc/rc.xml" \
    "${ISO_ROOT}/etc/xdg/labwc/rc.xml"
install -m 0644 "${SCRIPT_DIR}/overlay/etc/xdg/labwc/autostart" \
    "${ISO_ROOT}/etc/xdg/labwc/autostart"

echo "==> Installing aero-open launcher and .aero/.exe file associations"
install -m 0755 "${SCRIPT_DIR}/tools/aero-open" "${ISO_ROOT}/usr/local/bin/aero-open"
install -m 0755 "${SCRIPT_DIR}/tools/aexes" "${ISO_ROOT}/usr/local/bin/aexes"
install -m 0755 "${SCRIPT_DIR}/tools/aero-notify" "${ISO_ROOT}/usr/local/bin/aero-notify"
install -m 0755 "${SCRIPT_DIR}/tools/aero-fetch-icon" "${ISO_ROOT}/usr/local/bin/aero-fetch-icon"

echo "==> Installing the aero command language"
install -m 0755 "${SCRIPT_DIR}/tools/aero" "${ISO_ROOT}/usr/local/bin/aero"
ln -sf aero "${ISO_ROOT}/usr/local/bin/Aero"

echo "==> Staging Aero App Store index and update repos config"
install -d "${ISO_ROOT}/usr/local/share/aero/store"
install -d "${ISO_ROOT}/etc/aero"
install -m 0644 "${SCRIPT_DIR}/store/index.json" \
    "${ISO_ROOT}/usr/local/share/aero/store/index.json"
install -m 0644 "${SCRIPT_DIR}/config/repos.conf" \
    "${ISO_ROOT}/etc/aero/repos.conf"
install -m 0644 "${SCRIPT_DIR}/store/aero-update-manifest.example.json" \
    "${ISO_ROOT}/usr/local/share/aero/store/aero-update-manifest.example.json"
install -d "${ISO_ROOT}/usr/local/share/mime/packages"
install -d "${ISO_ROOT}/usr/local/share/applications"
install -m 0644 "${SCRIPT_DIR}/overlay/usr/local/share/mime/packages/aero.xml" \
    "${ISO_ROOT}/usr/local/share/mime/packages/aero.xml"
install -m 0644 "${SCRIPT_DIR}/overlay/usr/local/share/applications/aero-open.desktop" \
    "${ISO_ROOT}/usr/local/share/applications/aero-open.desktop"
chroot "${ISO_ROOT}" /usr/local/bin/update-mime-database /usr/local/share/mime || true
chroot "${ISO_ROOT}" /usr/local/bin/update-desktop-database /usr/local/share/applications || true

cat > "${ISO_ROOT}/usr/share/skel/.config/mimeapps.list" <<'MIMEAPPS'
[Default Applications]
application/x-aero-app=aero-open.desktop
application/x-ms-dos-executable=aero-open.desktop
application/vnd.microsoft.portable-executable=aero-open.desktop
MIMEAPPS

echo "==> Building example .aero app bundle"
install -d "${ISO_ROOT}/usr/local/share/aero/examples"
EXAMPLE_STAGING="${STAGING}/hello-aero"
mkdir -p "${EXAMPLE_STAGING}"
cp "${SCRIPT_DIR}/examples/hello-aero/manifest.json" "${EXAMPLE_STAGING}/"
cp "${SCRIPT_DIR}/examples/hello-aero/hello.sh" "${EXAMPLE_STAGING}/"
chmod +x "${EXAMPLE_STAGING}/hello.sh"
tar -cJf "${ISO_ROOT}/usr/local/share/aero/examples/hello.aero" -C "${EXAMPLE_STAGING}" .

echo "${AERO_OS_VERSION}" > "${ISO_ROOT}/etc/aero-version"

cat > "${ISO_ROOT}/etc/aero-release" <<RELEASE
Aero OS ${AERO_OS_VERSION} "${AERO_OS_CODENAME}"
Built: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Foundation: FreeBSD ${FREEBSD_VERSION} (${FREEBSD_ARCH})
RELEASE

cat > "${ISO_ROOT}/etc/rc.conf" <<'RCCONF'
hostname="aero"
sshd_enable="YES"
clear_tmp_enable="YES"
syslogd_flags="-ss"
powerd_enable="YES"
moused_enable="YES"
dbus_enable="YES"
wireplumber_enable="YES"
pipewire_enable="YES"
labwc_enable="YES"
RCCONF

cat >> "${ISO_ROOT}/etc/rc.conf" <<'RCCONF_AERO'
. /etc/rc.conf.aero
RCCONF_AERO

cat > "${ISO_ROOT}/etc/fstab" <<'FSTAB'
# Device                          Mountpoint  Fstype  Options  Dump  Pass#
/dev/iso9660                      /cdrom      cd9660  ro       0     0
FSTAB

cat > "${ISO_ROOT}/etc/master.passwd" <<'PASSWD'
root:$6$rounds=4096$saltsalt$changemehashedpasswordplaceholder:0:0::0:0:Charlie &:/root:/bin/sh
PASSWD

pwd_mkdb -p -d "${ISO_ROOT}/etc" "${ISO_ROOT}/etc/master.passwd"

echo "==> Building bootable Aero OS ISO"
ISO_LABEL="AERO_OS_10"
ISO_FILE="${OUTPUT_DIR}/AeroOS-${AERO_OS_VERSION}-${AERO_OS_CODENAME}.iso"
mkdir -p "${MEMSTICK_DIR:-${STAGING}/memstick}"

MKISO=""
for candidate in \
    "/usr/src/release/${FREEBSD_ARCH}/mkisoimages.sh" \
    "/usr/share/freebsd-release/mkisoimages.sh" \
    "/usr/local/share/freebsd-release/mkisoimages.sh"; do
    if [[ -x "${candidate}" ]]; then
        MKISO="${candidate}"
        break
    fi
done

if [[ -n "${MKISO}" ]]; then
    "${MKISO}" "${ISO_FILE}" "${ISO_LABEL}" "${ISO_ROOT}" "${FREEBSD_ARCH}"
else
    echo "mkisoimages.sh not found; using makefs + xorriso fallback"
    if [[ ! -f "${ISO_ROOT}/boot/cdboot" ]]; then
        echo "Fetching FreeBSD boot loader payload"
        fetch -o "${STAGING}/bootonly.iso" \
            "https://download.freebsd.org/releases/${FREEBSD_ARCH}/ISO-IMAGES/${FREEBSD_VERSION}/FreeBSD-${FREEBSD_VERSION}-amd64-bootonly.iso"
        mkdir -p "${STAGING}/bootonly-mount"
        MD_DEV="$(mdconfig -a -t vnode -f "${STAGING}/bootonly.iso")"
        mount -t cd9660 "/dev/${MD_DEV}" "${STAGING}/bootonly-mount"
        cp -R "${STAGING}/bootonly-mount/boot" "${ISO_ROOT}/"
        umount "${STAGING}/bootonly-mount"
        mdconfig -d -u "${MD_DEV}"
    fi
    IMG="${STAGING}/aero-root.img"
    makefs -t ufs -o softupdates,version=2 -s 4g "${IMG}" "${ISO_ROOT}"
    xorriso -as mkisofs \
        -o "${ISO_FILE}" \
        -V "${ISO_LABEL}" \
        -J -R \
        -b boot/cdboot \
        -no-emul-boot \
        -boot-load-size 4 \
        "${ISO_ROOT}"
fi

echo "==> Generating SHA-256 checksum"
sha256 -q "${ISO_FILE}" > "${ISO_FILE}.sha256" 2>/dev/null || true

echo "==> Build complete"
echo "Aero OS ${AERO_OS_VERSION} \"${AERO_OS_CODENAME}\""
echo "ISO output: ${ISO_FILE}"
ls -lh "${OUTPUT_DIR}"
