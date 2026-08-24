#!/bin/bash

# ---DOC-START---
# summary: Install the Nordic GTK theme straight from its upstream GitHub repo.
# description: |
#   Clones EliverLara/Nordic at install time and lays it out under the user's
#   local themes directory, replacing any previous copy. This keeps the theme
#   out of this repo entirely (previously it was a bundled static copy) and
#   guarantees the exact same directory structure that upstream ships,
#   since the theme directory *is* the upstream repo contents (minus .git).
#
#   Install path:
#   - ${XDG_DATA_HOME:-$HOME/.local/share}/themes/Nordic
# sudo: false
# interactive: false
# idempotent: true
# dependencies: git
# ---DOC-END---

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

# Drop the .git history — this repo bundles no nested git metadata anywhere
# (see the "no nested git submodules" note in install.sh), so the theme is
# copied in as plain files just like everything else fetched at install time.
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
