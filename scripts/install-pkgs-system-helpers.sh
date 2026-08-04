#!/bin/bash

# ---DOC-START---
# summary: Install the polkit agent and system hotkey helpers.
# description: |
#   Installs `lxpolkit`, `brightnessctl`.
#
#   `lxpolkit` is the polkit authentication agent, started in
#   `autostart.conf`. `brightnessctl` backs the brightness hotkeys.
# sudo: true
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "Please log in as root and run this script."
    exit 1
fi

echo "==> Installing polkit agent and system hotkey helpers"

echo "Updating package lists..."
apt update -q

echo "Installing polkit agent and system hotkey helpers..."
apt install -y \
    lxpolkit \
    brightnessctl

echo ""
echo "Polkit agent and system hotkey helpers installed successfully."
