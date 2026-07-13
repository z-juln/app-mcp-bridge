#!/bin/zsh
set -euo pipefail

ROOT=${0:A:h:h}
BUILD_ROOT="$ROOT/.build/app"
APP="$BUILD_ROOT/macOS UI Bridge.app"

cd "$ROOT"
swift build -c release --product macos-ui-bridge
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ROOT/.build/release/macos-ui-bridge" "$APP/Contents/MacOS/macos-ui-bridge"
cp "$ROOT/Resources/App-Info.plist" "$APP/Contents/Info.plist"
# Keep a stable identity across local rebuilds. Without an explicit designated
# requirement, ad-hoc signing makes TCC bind grants to the executable hash.
codesign --force --deep --sign - \
  --identifier com.juln.macos-ui-bridge \
  --requirements '=designated => identifier "com.juln.macos-ui-bridge"' \
  "$APP"

plutil -lint "$APP/Contents/Info.plist"
codesign --verify --deep --strict --verbose=1 "$APP"
requirement=$(codesign -d -r- "$APP" 2>&1)
[[ "$requirement" == *'designated => identifier "com.juln.macos-ui-bridge"'* ]] || {
  echo "App signing requirement is not stable: $requirement" >&2
  exit 1
}
echo "$APP"
