#!/bin/sh
# live.sh [shot.png] — rebuild the themes; Sable re-reads file-linked themes
# every second, so the running app updates by itself. Optionally screenshot.
# Needs Sable running with the debug port (see docs/development.md) for the screenshot.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
"$here/../build.sh" >/dev/null
/bin/sleep 2
if [ $# -ge 1 ]; then node --experimental-websocket "$here/cdp.mjs" shot "$1" 2>/dev/null; fi
