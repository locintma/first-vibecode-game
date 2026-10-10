#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
BUILD_DIR="$PROJECT_DIR/build/web"
GODOT_BIN="$(command -v godot || echo "$HOME/.local/bin/godot")"

mkdir -p "$BUILD_DIR"

echo "=== Exporting Cozy Critter (first-vibecode-game) for Web ==="

# Build class cache
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --import >/dev/null 2>&1 || true

# Export release
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "Web" "$BUILD_DIR/index.html"

echo "Export succeeded! Packaging for itch.io..."
python3 -c '
import sys, zipfile, os
build_dir = sys.argv[1]
zip_path = sys.argv[2]
with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(build_dir):
        for f in files:
            full_p = os.path.join(root, f)
            zf.write(full_p, os.path.relpath(full_p, build_dir))
' "$BUILD_DIR" "$PROJECT_DIR/build/cozy_critter_web.zip"

echo "Package created at: $PROJECT_DIR/build/cozy_critter_web.zip"
