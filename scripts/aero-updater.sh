#!/bin/sh
set -euo pipefail

VERSION_FILE="/etc/aero-version"
PROTECTED_MOUNTS="/home /root"

log() {
    printf '[aero-updater] %s\n' "$1"
}

verify_protected_space() {
    for mountpoint in ${PROTECTED_MOUNTS}; do
        if [ ! -d "${mountpoint}" ]; then
            log "warning: protected mount ${mountpoint} not found"
        fi
    done
}

read_local_version() {
    if [ -f "${VERSION_FILE}" ]; then
        tr -d '[:space:]' < "${VERSION_FILE}"
    else
        echo "0.0.0"
    fi
}

apply_upgrade() {
    verify_protected_space
    log "local version: $(read_local_version)"
    log "upgrading system core via pkg (user space remains untouched)"
    env ASSUME_ALWAYS_YES=yes pkg upgrade -y
    log "upgrade complete — restart recommended"
}

check_only() {
    log "local version: $(read_local_version)"
    log "run with --apply to install available packages"
}

case "${1:-}" in
    --apply)
        apply_upgrade
        ;;
    --check)
        check_only
        ;;
    *)
        echo "Usage: aero-updater [--check|--apply]" >&2
        exit 1
        ;;
esac
