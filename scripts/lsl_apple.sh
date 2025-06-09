#!/bin/bash
set -e

# Ensure the script is run from the workspace root
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Please run this script from the root of the workspace (where pubspec.yaml is)."
  exit 1
fi

cd liblsl

echo "📦 Applying patch..."
git apply ../patches/lsl_apple.patch

echo "✅ liblsl successfully updated and patched."

echo "🖨️ Copying patched liblsl to apple"
cp -r . ../apple/liblsl-1.16
rm -rf ../apple/liblsl-1.16/.git
rm -rf ../apple/liblsl-1.16/.github

echo "🧹 Cleaning up submodule"
git restore .

cd ../apple/liblsl-1.16

echo "Building for iOS"
# For iOS devices
cmake -G "Xcode" -B build/ios -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES="arm64"

echo "Building for iOS simulators"
# For iOS simulators
cmake -G "Xcode" -B build/ios-sim \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphonesimulator \
  -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64"

echo "Building for macOS"
# For macOS devices
cmake -G "Xcode" -B build/macos -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"

echo "Building release"
# Build Release configuration. Run
cmake --build build/ios --config Release
cmake --build build/ios-sim --config Release
cmake --build build/macos --config Release

echo "🍎 Creating framework"
# Then create an xcframework by running
xcodebuild -create-xcframework \
  -framework build/macos/Release/lsl.framework \
  -framework build/ios/Release-iphoneos/lsl.framework \
  -framework build/ios-sim/Release-iphonesimulator/lsl.framework \
  -output xcframeworks/lsl.xcframework
