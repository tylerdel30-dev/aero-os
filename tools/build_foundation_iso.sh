#!/usr/bin/env bash
# Wrapper — prefer foundation/build-all.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec bash "${ROOT}/foundation/build-all.sh"
