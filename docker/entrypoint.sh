#!/bin/sh
set -e

if [ ! -d /aero ]; then
    echo "Aero OS: /aero mount missing. Run build_os.ps1 from Windows." >&2
    exit 1
fi

cd /aero
export AERO_BUILD_CONTAINER=1
export AERO_PROJECT_ROOT=/aero

exec /usr/local/bin/bash /aero/build_os.sh
