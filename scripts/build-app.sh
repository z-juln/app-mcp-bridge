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
codesign --force --deep --sign - --identifier com.juln.macos-ui-bridge "$APP"

plutil -lint "$APP/Contents/Info.plist"
codesign --verify --deep --strict --verbose=1 "$APP"
echo "$APP"
