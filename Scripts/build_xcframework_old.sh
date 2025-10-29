#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.."; pwd)"
OUT="$ROOT/Frameworks"
SRC="$ROOT/lame-3.100"

rm -rf "$OUT"
mkdir -p "$OUT/ios-arm64/Headers" "$OUT/ios-arm64-simulator/Headers"

# Headers (.h files only)
mkdir -p "$OUT/ios-arm64/Headers/Lame" "$OUT/ios-arm64-simulator/Headers/Lame"

find "$SRC/include" -type f -name "*.h" -exec cp {} "$OUT/ios-arm64/Headers/Lame/" \;
find "$SRC/include" -type f -name "*.h" -exec cp {} "$OUT/ios-arm64-simulator/Headers/Lame/" \;


DEV_LIB="$SRC/build/ios/lib/libmp3lame.a"
SIM_LIB="$SRC/build/ios-sim/lib/libmp3lame.a"   # ここはシミュレータ版

if [ ! -f "$DEV_LIB" ]; then
  echo "❌ Not found: $DEV_LIB"
  exit 1
fi

mkdir -p "$OUT/ios-arm64" "$OUT/ios-arm64-simulator"
cp -a "$DEV_LIB" "$OUT/ios-arm64/"

if [ -f "$SIM_LIB" ]; then
  cp -a "$SIM_LIB" "$OUT/ios-arm64-simulator/"
  xcodebuild -create-xcframework \
    -library "$OUT/ios-arm64/libmp3lame.a" -headers "$OUT/ios-arm64/Headers" \
    -library "$OUT/ios-arm64-simulator/libmp3lame.a" -headers "$OUT/ios-arm64-simulator/Headers" \
    -output "$OUT/Lame.xcframework"
  echo "✅ Created (device+sim): $OUT/Lame.xcframework"
else
  # デバイス専用で作成（公開は可能。後でSIMを追加して差し替えOK）
  xcodebuild -create-xcframework \
    -library "$OUT/ios-arm64/libmp3lame.a" -headers "$OUT/ios-arm64/Headers" \
    -output "$OUT/Lame.xcframework"
  echo "✅ Created (device only): $OUT/Lame.xcframework"
  echo "ℹ️  To add simulator: place $SIM_LIB and rerun this script."
fi

