#!/usr/bin/env bash
# Start RIE (if needed) + the .NET browser front-end.
# Usage: scripts/start-web.sh [port]   (default 3000)
set -euo pipefail
cd "$(dirname "$0")/.."

export DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
export PATH="$DOTNET_ROOT:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

PORT="${1:-3000}"
FUNC="./src/HelloWorld/bin/Release/net8.0/linux-x64/publish/bootstrap"
WEB_DLL="./src/WebFrontend/bin/Release/net8.0/WebFrontend.dll"

if [ ! -x "$FUNC" ]; then
  echo "Function not built yet. Run scripts/build.sh first." >&2
  exit 1
fi

# Make sure the Lambda emulator is up.
./scripts/start-local.sh >/dev/null

if [ ! -f "$WEB_DLL" ]; then
  echo "Building .NET web front-end..."
  ./scripts/build-web.sh >/dev/null
fi

if [ -f web.pid ] && kill -0 "$(cat web.pid)" 2>/dev/null; then
  echo "Web front-end already running (pid $(cat web.pid))."
else
  PORT="$PORT" setsid dotnet "$WEB_DLL" > web.log 2>&1 < /dev/null &
  echo $! > web.pid
  sleep 1
fi

echo "Open in your browser:  http://localhost:${PORT}/"
