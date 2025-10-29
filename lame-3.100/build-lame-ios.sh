#!/bin/bash

ARCH=arm64
PLATFORM=iPhoneOS
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
DEVELOPER=$(xcode-select -p)

PREFIX=$(pwd)/build/ios

mkdir -p $PREFIX

./configure \
  --host=aarch64-apple-darwin \
  --disable-shared \
  --enable-static \
  --prefix=$PREFIX \
  CC="$(xcrun -sdk iphoneos -find clang)" \
  CFLAGS="-arch $ARCH -isysroot $SDK -mios-version-min=11.0"

make clean
make -j$(sysctl -n hw.ncpu)
make install

