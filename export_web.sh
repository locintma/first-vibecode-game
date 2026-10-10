#!/usr/bin/env bash
# export_web.sh for first-vibecode-game
# Exports to WebAssembly and packages an itch.io HTML5 ZIP bundle
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
BUILD_DIR="$PROJECT_DIR/build/web"
ZIP_PATH="$PROJECT_DIR/build/first_vibecode_game_web.zip"

mkdir -p "$BUILD_DIR"

echo "=== Packaging first-vibecode-game for itch.io ==="

# Check Godot binary
GODOT_BIN=""
if command -v godot >/dev/null 2>&1; then
    GODOT_BIN="godot"
elif [ -x "$HOME/.local/bin/godot" ]; then
    GODOT_BIN="$HOME/.local/bin/godot"
fi

if [ -n "$GODOT_BIN" ]; then
    echo "Running Godot headless web export..."
    "$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "Web" "$BUILD_DIR/index.html" || true
else
    echo "Notice: Godot binary not found. Generating web shell bundle..."
    # Create HTML5 shell if engine binary is absent
    cat <<'HTML' > "$BUILD_DIR/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">
    <title>First Vibecode Game</title>
    <style>
        body { margin: 0; background-color: #E8D7B8; display: flex; align-items: center; justify-content: center; height: 100vh; font-family: sans-serif; }
        #canvas { width: 100%; height: 100%; max-width: 1280px; max-height: 720px; box-shadow: 0 4px 20px rgba(0,0,0,0.15); border-radius: 8px; }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>
</body>
</html>
HTML
fi

# Package itch.io ZIP bundle
python3 -c '
import sys, zipfile, os
build_dir, zip_path = sys.argv[1], sys.argv[2]
os.makedirs(os.path.dirname(zip_path), exist_ok=True)
with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(build_dir):
        for f in files:
            full_p = os.path.join(root, f)
            zf.write(full_p, os.path.relpath(full_p, build_dir))
' "$BUILD_DIR" "$ZIP_PATH"

echo "✅ Created itch.io package: $ZIP_PATH"

# If Butler is installed and BUTLER_API_KEY is available, push
if command -v butler >/dev/null 2>&1; then
    ITCH_TARGET="${ITCH_TARGET:-locionic/first-vibecode-game:html5}"
    echo "Pushing to itch.io target: $ITCH_TARGET..."
    butler push "$ZIP_PATH" "$ITCH_TARGET"
else
    echo "ℹ️ itch.io Butler CLI is not configured on this machine."
    echo "To push manually: butler push $ZIP_PATH <user>/first-vibecode-game:html5"
fi
