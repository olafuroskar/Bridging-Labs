#!/bin/bash
set -e

# Ensure the script is run from the workspace root
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Please run this script from the root of the workspace (where pubspec.yaml is)."
  exit 1
fi

cd liblsl
git checkout master
git pull origin master

echo "📦 Applying patch..."
patch -p1 <../patches/lsl_skip_install.patch

echo "✅ liblsl successfully updated and patched."

echo "🖨️ Copying patched liblsl to lsl_bindings"
cp -r . ../packages/lsl_bindings/src
rm -rf ../packages/lsl_bindings/src/.git
rm -rf ../packages/lsl_bindings/src/.github

echo "🧹 Cleaning up submodule"
git restore .
