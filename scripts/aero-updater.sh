#!/bin/sh
#
# aero-updater — OTA from GitHub Releases (manifest + desktop bins + pkg)
# Never touches /home or /root user data.
#
set -eu

VERSION_FILE="/etc/aero-version"
REPOS_FILE="/etc/aero/repos.conf"
REPO="tylerdel30-dev/aero-os"
PROTECTED="/home /root /home/*/.config/aero /home/*/.local/share/aero"
TMP="/tmp/aero-ota-$$"

log() { printf '[aero-updater] %s\n' "$1"; }

die() { log "ERROR: $1"; exit 1; }

cleanup() { rm -rf "${TMP}" 2>/dev/null || true; }
trap cleanup EXIT

read_local_version() {
    if [ -f "${VERSION_FILE}" ]; then
        tr -d '[:space:]' < "${VERSION_FILE}"
    else
        echo "0.0.0"
    fi
}

release_tag_from_repos() {
    if [ -f "${REPOS_FILE}" ]; then
        # shellcheck disable=SC1090
        . "${REPOS_FILE}" 2>/dev/null || true
        if [ -n "${os_tag:-}" ]; then
            echo "${os_tag}"
            return
        fi
    fi
    echo "v1.0.1"
}

fetch_latest_tag() {
    api="https://api.github.com/repos/${REPO}/releases/latest"
    json="$(curl -fsSL -H 'Accept: application/vnd.github+json' "${api}" 2>/dev/null)" || {
        release_tag_from_repos
        return
    }
    tag="$(printf '%s' "${json}" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
    if [ -n "${tag}" ]; then
        echo "${tag}"
    else
        release_tag_from_repos
    fi
}

assert_not_protected() {
    path="$1"
    case "${path}" in
        /home|/home/*|/root|/root/*)
            die "refusing to replace protected path: ${path}"
            ;;
    esac
}

install_desktop_bins() {
    tag="$1"
    url="https://github.com/${REPO}/releases/download/${tag}/aero-desktop-amd64.tar.xz"
    mkdir -p "${TMP}/bins"
    log "fetching desktop binaries (${url})"
    if ! curl -fsSL -o "${TMP}/bins/aero-desktop-amd64.tar.xz" "${url}"; then
        log "desktop bins not on release yet — skipping binary refresh"
        return 0
    fi
    tar -xJf "${TMP}/bins/aero-desktop-amd64.tar.xz" -C "${TMP}/bins"
    for b in aero-shell aero-settings aero-lock aero-firstboot aero-store aero-update-ui; do
        if [ -f "${TMP}/bins/${b}" ]; then
            install -m 0755 "${TMP}/bins/${b}" "/usr/local/bin/${b}"
            log "installed /usr/local/bin/${b}"
        fi
    done
}

apply_manifest_assets() {
    tag="$1"
    manifest_url="https://github.com/${REPO}/releases/download/${tag}/aero-update-manifest.json"
    mkdir -p "${TMP}"
    if ! curl -fsSL -o "${TMP}/manifest.json" "${manifest_url}"; then
        log "no remote manifest at ${manifest_url}"
        return 0
    fi
    log "manifest OK for ${tag}"

    # Optional: pull desktop_bins named in manifest
    bins="$(sed -n 's/.*"desktop_bins"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "${TMP}/manifest.json" | head -n 1)"
    if [ -n "${bins}" ]; then
        url="https://github.com/${REPO}/releases/download/${tag}/${bins}"
        mkdir -p "${TMP}/bins"
        if curl -fsSL -o "${TMP}/bins/${bins}" "${url}"; then
            tar -xJf "${TMP}/bins/${bins}" -C "${TMP}/bins" 2>/dev/null || true
            for b in aero-shell aero-settings aero-lock aero-firstboot aero-store aero-update-ui; do
                [ -f "${TMP}/bins/${b}" ] && install -m 0755 "${TMP}/bins/${b}" "/usr/local/bin/${b}"
            done
        fi
    fi
}

pkg_upgrade_safe() {
    log "pkg upgrade (user space untouched)"
    env ASSUME_ALWAYS_YES=yes pkg upgrade -y || log "pkg upgrade reported issues (continuing)"
}

write_version() {
    tag="$1"
    ver="$(printf '%s' "${tag}" | sed 's/^v//')"
    echo "${ver}" > "${VERSION_FILE}"
    log "wrote ${VERSION_FILE} = ${ver}"
}

check_only() {
    local_v="$(read_local_version)"
    tag="$(fetch_latest_tag)"
    log "local version : ${local_v}"
    log "latest release: ${tag}"
    url="https://github.com/${REPO}/releases/download/${tag}/aero-desktop-amd64.tar.xz"
    if curl -fsSIL "${url}" >/dev/null 2>&1; then
        log "desktop bins  : available"
    else
        log "desktop bins  : pending"
    fi
    manifest_url="https://github.com/${REPO}/releases/download/${tag}/aero-update-manifest.json"
    if curl -fsSIL "${manifest_url}" >/dev/null 2>&1; then
        log "manifest      : available"
    else
        log "manifest      : missing"
    fi
    log "protected     : ${PROTECTED}"
    log "run with --apply to upgrade"
}

apply_upgrade() {
    [ "$(id -u)" -eq 0 ] || die "run as root: sudo aero-updater --apply"
    local_v="$(read_local_version)"
    tag="$(fetch_latest_tag)"
    log "local version : ${local_v}"
    log "target release: ${tag}"
    for p in /home /root; do
        [ -d "${p}" ] || log "warning: ${p} missing"
    done
    apply_manifest_assets "${tag}"
    install_desktop_bins "${tag}"
    pkg_upgrade_safe
    write_version "${tag}"
    log "upgrade complete — restart recommended"
    log "prove endpoints: aero-ota-prove"
}

case "${1:-}" in
    --apply)
        apply_upgrade
        ;;
    --check|"")
        check_only
        ;;
    *)
        echo "Usage: aero-updater [--check|--apply]" >&2
        exit 1
        ;;
esac
