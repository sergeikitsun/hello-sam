#!/usr/bin/env bash
# Stop the browser front-end (if any) and the local Lambda Runtime Interface Emulator.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f web.pid ] && kill -0 "$(cat web.pid)" 2>/dev/null; then
  kill "$(cat web.pid)"
  rm -f web.pid
  echo "Web front-end stopped."
else
  echo "Web front-end not running."
  rm -f web.pid
fi

if [ -f rie.pid ] && kill -0 "$(cat rie.pid)" 2>/dev/null; then
  kill "$(cat rie.pid)"
  rm -f rie.pid
  echo "RIE stopped."
else
  echo "RIE not running."
  rm -f rie.pid
fi
