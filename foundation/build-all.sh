#!/bin/bash
set -euo pipefail
source "$HOME/.cargo/env"
cd "/mnt/c/Users/tyler/Desktop/Aero OS/foundation"
rustup default nightly
rustup target add x86_64-unknown-uefi
rustup component add rust-src

# Host tools for ESP/ISO packaging
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq mtools dosfstools xorriso >/dev/null 2>&1 || true

HOST="$(rustc +nightly -Vv | awk '/^host:/{print $2}')"
cargo +nightly run --release -p aero-builder --target "$HOST"
echo "FOUNDATION_OK"
