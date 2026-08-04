#!/bin/bash

# ---DOC-START---
# summary: Install the audio stack (PipeWire/WirePlumber).
# description: |
#   Installs `pipewire`, `pipewire-pulse`, `wireplumber`, `alsa-utils`.
#
#   This stack is required for the `wpctl`/`pactl` commands used in
#   `audio.conf` and `waybar`.
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

echo "==> Installing audio stack (PipeWire/WirePlumber)"

echo "Updating package lists..."
apt update -q

echo "Installing audio stack..."
apt install -y \
    pipewire \
    pipewire-pulse \
    wireplumber \
    alsa-utils

echo ""
echo "Audio stack installed successfully."
