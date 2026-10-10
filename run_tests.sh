#!/usr/bin/env bash
set -uo pipefail

CDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$CDIR"

PROBES="test_playthrough"

GODOT_BIN="$(command -v godot || echo "$HOME/.local/bin/godot")"
if [ ! -x "$GODOT_BIN" ]; then
    echo "Godot binary not found at $GODOT_BIN" >&2
    exit 1
fi

echo "Running test suite: $PROBES"
OUT=$("$GODOT_BIN" --headless -s test_playthrough.gd 2>&1)
echo "$OUT"

if echo "$OUT" | grep -q "verdict=FAIL" || echo "$OUT" | grep -q "FAIL: [1-9]"; then
    echo "Tests failed: FAIL detected" >&2
    exit 1
fi

if echo "$OUT" | grep -q "verdict=PASS"; then
    echo "Tests passed: PASS, 0 FAIL"
    exit 0
fi

echo "Test runner failed to produce expected verdict" >&2
exit 1
