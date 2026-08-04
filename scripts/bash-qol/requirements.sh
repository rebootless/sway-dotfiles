#!/bin/bash

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "==> Updating package lists"
sudo apt-get update -y

echo "==> Installing bash-completion, fzf, zoxide, ripgrep, bat, chafa, git"
sudo apt-get install -y bash-completion fzf zoxide ripgrep bat chafa git

echo "==> Installing eza"

if command -v eza &>/dev/null; then
    echo "eza already installed, skipping repo setup."
else
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -y
    sudo apt-get install -y eza
    echo "eza installed."
fi

echo "Packages installed: bash-completion, fzf, zoxide, ripgrep, bat, eza, chafa, git"
