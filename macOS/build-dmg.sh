#!/bin/bash
#
# Build DMG disk images for macOS installer apps.
# Usage:
#   ./build-dmg.sh                  # build DMGs for all .app bundles
#   ./build-dmg.sh UT2004Installer  # build DMG for a specific app
#
# Requires: create-dmg (brew install create-dmg)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/dist"

if ! command -v create-dmg &>/dev/null; then
	echo "Error: create-dmg is not installed."
	echo "Install it with: brew install create-dmg"
	exit 1
fi

build_dmg() {
	local app_path="$1"
	local app_name
	app_name="$(basename "$app_path" .app)"

	local dmg_path="$OUTPUT_DIR/${app_name}.dmg"

	echo ">>> Building DMG for ${app_name}..."

	# Remove previous DMG if it exists
	rm -f "$dmg_path"

	create-dmg \
		--volname "$app_name" \
		--window-pos 200 120 \
		--window-size 600 400 \
		--icon-size 100 \
		--icon "${app_name}.app" 150 190 \
		--app-drop-link 450 190 \
		"$dmg_path" \
		"$app_path"

	echo ">>> Created: $dmg_path"
}

mkdir -p "$OUTPUT_DIR"

if [ $# -gt 0 ]; then
	# Build DMG for the specified app(s)
	for name in "$@"; do
		app_path="$SCRIPT_DIR/${name%.app}.app"
		if [ ! -d "$app_path" ]; then
			echo "Error: $app_path not found"
			exit 1
		fi
		build_dmg "$app_path"
	done
else
	# Build DMGs for all .app bundles in the macOS directory
	for app_path in "$SCRIPT_DIR"/*.app; do
		[ -d "$app_path" ] || continue
		build_dmg "$app_path"
	done
fi

echo "Done."
