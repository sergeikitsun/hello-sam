#!/usr/bin/env bash
# Build the .NET browser front-end (ASP.NET Core minimal API).
set -euo pipefail
cd "$(dirname "$0")/.."

export DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
export PATH="$DOTNET_ROOT:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

dotnet build src/WebFrontend/WebFrontend.csproj -c Release
