#!/bin/bash

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

REPO_URL="https://github.com/EliverLara/Nordic.git"
THEMES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
THEME_DIR="$THEMES_DIR/Nordic"
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "Installing dependencies..."

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git
fi

echo ""
echo "==> Fetching Nordic theme from ${REPO_URL}"

git clone --depth 1 "$REPO_URL" "$TMP_DIR/Nordic"

rm -rf "$TMP_DIR/Nordic/.git"

mkdir -p "$THEMES_DIR"
rm -rf "$THEME_DIR"
mv "$TMP_DIR/Nordic" "$THEME_DIR"

echo ""
echo "==> Summary"

echo ""
echo "Nordic GTK theme installed successfully."

echo ""
echo "Location:"
echo "  $THEME_DIR"
