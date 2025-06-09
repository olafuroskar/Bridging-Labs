#!/bin/bash
set -e

# Ensure the script is run from the workspace root
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Please run this script from the root of the workspace (where pubspec.yaml is)."
  exit 1
fi

cd liblsl

echo "📦 Applying patch..."
git apply ../patches/lsl_skip_install.patch

echo "✅ liblsl successfully updated and patched."

echo "🖨️ Copying patched liblsl to lsl_bindings"
cp -r . ../plugins/lsl_bindings/src
rm -rf ../plugins/lsl_bindings/src/.git

echo "🧹 Cleaning up submodule"
git restore .
