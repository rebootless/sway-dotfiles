#!/bin/bash

# ---DOC-START---
# summary: Install graphics/GL libraries and diagnostics tools.
# description: |
#   Installs `libegl1`, `libgl1`, `libgles2`, `mesa-utils` for software
#   rendering support and GL diagnostics.
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

echo "==> Installing graphics/GL libraries"

echo "Updating package lists..."
apt update -q

echo "Installing graphics/GL libraries..."
apt install -y \
    libegl1 \
    libgl1 \
    libgles2 \
    mesa-utils

echo ""
echo "Graphics/GL libraries installed successfully."
