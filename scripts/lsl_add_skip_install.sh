#!/bin/bash
set -e

echo "$(pwd)"

# Ensure the script is run from the workspace root
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Please run this script from the root of the workspace (where pubspec.yaml is)."
  exit 1
fi

echo "✅ Updating liblsl submodule..."
cd plugins/lsl_bindings/src
git checkout master
git pull origin master

echo "📦 Applying patch..."
git apply ../../../patches/lsl_skip_install.patch

echo "✅ liblsl successfully updated and patched."
