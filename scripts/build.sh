#!/usr/bin/env bash
# Build & publish the .NET Lambda as a self-contained linux-x64 executable named "bootstrap".
set -euo pipefail
cd "$(dirname "$0")/.."

export DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
export PATH="$DOTNET_ROOT:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

dotnet publish src/HelloWorld/HelloWorld.csproj \
  -c Release -r linux-x64 --self-contained true \
  -o src/HelloWorld/bin/Release/net8.0/linux-x64/publish
