#!/bin/zsh
set -euo pipefail

ROOT=${0:A:h:h}
SOURCE="$ROOT/.build/app/macOS UI Bridge.app"
DESTINATION="/Applications/macOS UI Bridge.app"

if [[ ! -d "$SOURCE" ]]; then
  "$ROOT/scripts/build-app.sh"
fi

pkill -x macos-ui-bridge 2>/dev/null || true
rm -rf "$DESTINATION"
cp -R "$SOURCE" "$DESTINATION"
open "$DESTINATION"
echo "$DESTINATION"
