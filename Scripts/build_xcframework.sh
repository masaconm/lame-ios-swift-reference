#!/usr/bin/env bash
# Build Lame.xcframework (device + optional simulator)
# - Headers are flattened under Headers/ (no subfolder), so use:  #include "lame.h"
# - If simulator lib not present, device-only XCFramework is produced.

set -euo pipefail

# -------------------------
# Paths
# -------------------------
ROOT="$(cd "$(dirname "$0")/.."; pwd)"
SRC="$ROOT/lame-3.100"
OUT="$ROOT/Frameworks"

DEV_LIB="$SRC/build/ios/lib/libmp3lame.a"       # device (arm64)
SIM_LIB="$SRC/build/ios-sim/lib/libmp3lame.a"   # simulator (arm64)

# -------------------------
# Preflight checks
# -------------------------
command -v xcodebuild >/dev/null 2>&1 || {
  echo "❌ xcodebuild not found (Xcode Command Line Tools required)"; exit 1;
}

if [[ ! -d "$SRC" ]]; then
  echo "❌ Source dir not found: $SRC"
  exit 1
fi

if [[ ! -f "$DEV_LIB" ]]; then
  echo "❌ Device lib not found: $DEV_LIB"
  echo "   Please build the device static library first."
  exit 1
fi

# -------------------------
# Prepare output layout
# -------------------------
rm -rf "$OUT"
mkdir -p \
  "$OUT/ios-arm64/Headers" \
  "$OUT/ios-arm64-simulator/Headers" \
  "$OUT/ios-arm64" \
  "$OUT/ios-arm64-simulator"

# -------------------------
# Copy headers (.h only, flatten)
# -------------------------
# Keep only public headers; exclude Makefile/.def/.sym etc.
find "$SRC/include" -type f -name "*.h" -exec cp {} "$OUT/ios-arm64/Headers/" \;
find "$SRC/include" -type f -name "*.h" -exec cp {} "$OUT/ios-arm64-simulator/Headers/" \;

# -------------------------
# Copy libraries
# -------------------------
cp -a "$DEV_LIB" "$OUT/ios-arm64/"

HAS_SIM="0"
if [[ -f "$SIM_LIB" ]]; then
  cp -a "$SIM_LIB" "$OUT/ios-arm64-simulator/"
  HAS_SIM="1"
fi

# -------------------------
# Create XCFramework
# -------------------------
if [[ "$HAS_SIM" == "1" ]]; then
  xcodebuild -create-xcframework \
    -library "$OUT/ios-arm64/libmp3lame.a"           -headers "$OUT/ios-arm64/Headers" \
    -library "$OUT/ios-arm64-simulator/libmp3lame.a" -headers "$OUT/ios-arm64-simulator/Headers" \
    -output "$OUT/Lame.xcframework"
  echo "✅ Created (device + simulator): $OUT/Lame.xcframework"
else
  xcodebuild -create-xcframework \
    -library "$OUT/ios-arm64/libmp3lame.a" -headers "$OUT/ios-arm64/Headers" \
    -output "$OUT/Lame.xcframework"
  echo "✅ Created (device only): $OUT/Lame.xcframework"
  echo "ℹ️  To add simulator later: place '$SIM_LIB' and rerun this script."
fi

# -------------------------
# Summary
# -------------------------
echo
echo "━━ Summary ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Source:        $SRC"
echo "Device lib:    $DEV_LIB"
echo "Simulator lib: ${HAS_SIM == 1 && echo "$SIM_LIB" || echo "(not present)"}"
echo "Output:        $OUT/Lame.xcframework"
echo "Headers root:  Headers/ (use #include \"lame.h\")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
