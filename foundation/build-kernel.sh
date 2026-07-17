#!/bin/bash
set -euo pipefail
source "$HOME/.cargo/env"
cd "/mnt/c/Users/tyler/Desktop/Aero OS/foundation"
rustup default nightly
rustup target add x86_64-unknown-uefi
cargo +nightly build -p aero-kernel --release --target x86_64-unknown-uefi
echo "KERNEL_OK"
