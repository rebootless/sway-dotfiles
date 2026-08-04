#!/bin/bash

# Usage: run as a regular user, the script calls sudo itself where needed.
#   ./install.sh
#
# No flags.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

if [[ $EUID -eq 0 ]]; then
    echo "Don't run install.sh as root directly — run it as a regular user," >&2
    echo "the script will call sudo itself where needed." >&2
    exit 1
fi

if [[ $# -gt 0 ]]; then
    echo "install.sh takes no arguments (got: $*)." >&2
    exit 1
fi

REAL_USER="$(id -un)"
REAL_HOME="$HOME"

as_root() { sudo "$@"; }
as_user() { "$@"; }

check_distro() {
    if [[ ! -r /etc/os-release ]]; then
        echo "Cannot read /etc/os-release — unable to verify the distro. Aborting." >&2
        exit 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    if [[ "${ID:-}" != "debian" || "${VERSION_CODENAME:-}" != "trixie" ]]; then
        echo "This installer supports Debian 13 (trixie) only." >&2
        echo "Detected: ${PRETTY_NAME:-unknown} (ID=${ID:-?}, VERSION_CODENAME=${VERSION_CODENAME:-?})" >&2
        exit 1
    fi

    echo "Detected: ${PRETTY_NAME}"
}

echo "==> [1/9] Checking distro"
check_distro

echo "==> [2/9] apt update"
as_root apt-get update -q

echo "==> [2/9] Installing kitty"
as_root apt-get install -y kitty

echo "==> [2/9] Installing kate" # --no-install-recommends, otherwise it pulls in systemsettings)
as_root apt-get install -y --no-install-recommends kate

echo "==> [2/9] Installing package groups"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-core.sh"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-wayland-core.sh"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-theming.sh"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-audio.sh"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-network.sh"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-notify.sh"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-storage.sh"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-system-helpers.sh"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-graphics.sh"
as_root bash "$SCRIPT_DIR/scripts/install-pkgs-apps.sh"

echo "==> [3/9] Installing Nerd Fonts"
as_root bash "$SCRIPT_DIR/scripts/install-nerd-fonts.sh"

echo "==> [4/9] Installing ranger_devicons"
as_user bash "$SCRIPT_DIR/scripts/install-ranger-devicons.sh"

echo "==> [5/9] Installing Zafiro icon themes"
as_user bash "$SCRIPT_DIR/scripts/install-zafiro-icons.sh"

echo "==> [6/9] Copying dotfiles in $REAL_HOME"
if [[ -d "$DOTFILES_DIR" ]]; then
    TS="$(date +%Y%m%d_%H%M%S)"
    BACKUP_DIR="$REAL_HOME/.dotfiles-backup-$TS"
    STAGE_DIR="$(mktemp -d)"
    trap '[[ -n "${STAGE_DIR:-}" ]] && rm -rf "$STAGE_DIR"' EXIT

    cp -a "$DOTFILES_DIR/." "$STAGE_DIR/"

    # Back up whatever this run is about to overwrite.
    backed_up_any=false
    while IFS= read -r -d '' f; do
        rel="${f#"$STAGE_DIR"/}"
        target="$REAL_HOME/$rel"
        if [[ -e "$target" ]]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
            cp -a "$target" "$BACKUP_DIR/$rel"
            backed_up_any=true
        fi
    done < <(find "$STAGE_DIR" -type f -print0)

    if [[ "$backed_up_any" == true ]]; then
        echo "Existing files that are about to be overwritten were backed up to $BACKUP_DIR"
    else
        rmdir "$BACKUP_DIR" 2>/dev/null || true
    fi

    # Substitute the __HOME__ placeholder with the real path, text files only
    # (grep -Iq skips binaries like icon/theme assets).
    while IFS= read -r -d '' f; do
        if grep -Iq . "$f" 2>/dev/null && grep -qF '__HOME__' "$f" 2>/dev/null; then
            sed -i "s|__HOME__|$REAL_HOME|g" "$f"
        fi
    done < <(find "$STAGE_DIR" -type f -print0)

    cp -rf "$STAGE_DIR/." "$REAL_HOME/"
    echo "Dotfiles laid out (__HOME__ placeholders substituted with $REAL_HOME)."
else
    echo "No dotfiles/ directory next to install.sh — skipping this stage."
fi

echo "==> [7/9] bash-qol (shell QoL setup, oh-my-bash theme: agnoster)"
as_user bash "$SCRIPT_DIR/scripts/bash-qol/bash-qol" --omb=non-interactive --theme=agnoster

echo "==> [8/9] xdg-user-dirs-update"
as_user xdg-user-dirs-update

echo "==> [9/9] Enabling system services"
as_root systemctl enable --now NetworkManager
as_root systemctl enable --now bluetooth
as_root systemctl enable --now firewalld

echo "==> [9/9] Cleaning up"
as_root apt purge -y foot
as_root apt autoremove -y

echo ""
echo "==> Summary"

echo ""
echo "Installation complete. Log in to sway as usual, manually from a TTY (exec sway is already in .profile)."

echo ""
echo "==================================================================="
echo "REMINDER: theming is applied via dotfiles automatically, but if"
echo "something didn't take (e.g. a fresh login is needed, or you edited"
echo "these by hand before), you can set it manually:"

echo ""
echo "  qt6ct (Qt6 Settings):"
echo "    style:           Nord"
echo "    color scheme:    Breeze"
echo "    icon theme (choose one, exact name comes from the installed"
echo "    theme's index.theme — verify after first install):"
echo "      Zafiro-Icons-Dark"
echo "      Zafiro-Icons-Light"

echo ""
echo "  qt5ct (Qt5 Settings):"
echo "    style:           Nord"
echo "    color scheme:    Breeze"
echo "    icon theme (choose one, exact name comes from the installed"
echo "    theme's index.theme — verify after first install):"
echo "      Zafiro-Icons-Dark"
echo "      Zafiro-Icons-Light"

echo ""
echo "  nwg-look (GTK Settings):"
echo "    widgets (theme): Nordic"
echo "    icon theme (choose one, exact name comes from the installed"
echo "    theme's index.theme — verify after first install):"
echo "      Zafiro-Icons-Dark"
echo "      Zafiro-Icons-Light"
echo "==================================================================="

echo ""
echo "A reboot (or at least a fresh login) is needed for all system"
echo "services, user groups, and shell/theme changes to fully apply."
echo "This script does not reboot the machine for you — do it yourself"

echo ""
echo "whenever it's convenient:"
echo "  sudo reboot"
