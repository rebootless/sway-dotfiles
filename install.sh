#!/bin/bash
# install.sh — sets up a sway environment on a clean Debian 13 (trixie).
#
# Usage: run as a regular user, the script calls sudo itself where needed.
#   ./install.sh
#
# No flags.
#
# Stages:
#   1. Distro check (must be Debian 13 / trixie)
#   2. apt install packages (scripts/install-pkgs-*.sh, plus kitty and kate)
#   3. Nerd Fonts (scripts/install-nerd-fonts.sh)
#   4. ranger_devicons (scripts/install-ranger-devicons.sh)
#   5. Zafiro icon themes, Dark + Light (scripts/install-zafiro-icons.sh)
#   6. lay out dotfiles/ over $HOME (backed up first, __HOME__ placeholder
#      substituted with the real path — see the "dotfiles templating" note)
#   7. bash-qol: shell QoL setup, non-interactive, oh-my-bash theme "agnoster"
#      (must run AFTER dotfiles — see the "why bash-qol runs after dotfiles" note)
#   8. xdg-user-dirs-update
#   9. systemctl enable --now for network/system services
#
# The Nordic GTK theme still ships as a static copy in
# dotfiles/.local/share/themes/Nordic and is laid out in stage 6 (see the
# open question about this in the PR discussion — it's the last thing in
# this repo still bundled instead of fetched at install time). Icons are
# NOT bundled anymore: they are downloaded fresh in stage 5.
#
# scripts/install-pkgs-*.sh and scripts/install-{nerd-fonts,ranger-devicons,
# zafiro-icons}.sh are copies of individual scripts from
# https://github.com/rebootless/shell-toolkit — copied in as standalone
# files (not a git-cloned subdirectory) so this repo has no nested .git and
# no unrelated tooling from that toolkit. scripts/bash-qol/ is copied the
# same way from https://github.com/rebootless/bash-qol. If either upstream
# changes, re-copy the relevant file(s) by hand; there's no submodule/sync
# mechanism here.
#
# kitty and kate are intentionally NOT installed via a
# shell-toolkit script:
#   - kitty must install before install-pkgs-wayland-core.sh (which pulls
#     in sway), otherwise sway's Recommends pulls in foot as well.
#   - shell-toolkit's install-kate.sh runs `apt install -y kate` with no
#     --no-install-recommends, which pulls in the systemsettings
#     meta-package. That's explicitly what we don't want here, so kate is
#     installed with its own apt-get call below instead of calling that
#     script.
#
# Dotfiles templating (__HOME__ placeholder):
#   Some config formats (e.g. qt5ct.conf/qt6ct.conf — plain Qt INI files,
#   no environment-variable expansion) need an absolute path to the current
#   user's home baked in (color_scheme_path=.../colors/Nord.conf). Since the
#   dotfiles/ directory is shared and not tied to one username, any such
#   path in dotfiles/ should be written with the literal placeholder
#   "__HOME__" instead of a real path, e.g.:
#     color_scheme_path=__HOME__/.config/qt5ct/colors/Nord.conf
#   Stage 6 replaces __HOME__ with the real $HOME on every text file before
#   copying it into place. Binary files (icons, images) are left untouched.
#
# Why bash-qol runs after dotfiles (stage 7, not stage 6):
#   dotfiles/.bashrc and dotfiles/.inputrc are the plain Debian-skeleton
#   versions (no bash-qol managed block). bash-qol works by appending a
#   marked block to whatever .bashrc/.inputrc it finds and is idempotent
#   about replacing that block on reruns. If it ran BEFORE the dotfiles
#   copy, the dotfiles stage would immediately overwrite ~/.bashrc with the
#   plain version and silently erase bash-qol's block — the QoL setup would
#   look like it worked but do nothing. Running dotfiles first, then
#   bash-qol on top, is the only order that keeps both.

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

echo "==> [2/9] Installing kate" # --no-install-recommends, otherwise it pulls systemsettings
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

echo "==> [9/9] Updating icon theme cache"
as_user gtk-update-icon-theme -f "$REAL_HOME/.local/share/icons/Zafiro-Icons-Dark"

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
echo "A reboot (or at least a new login session) is recommended for all"
echo "system services, user groups, and shell/theme changes to fully apply."
echo "This script will not reboot your system automatically."

echo ""
echo "When convenient:"
echo "  sudo reboot"

echo ""
echo "Or, without rebooting, start Sway manually:"
echo "  sway"