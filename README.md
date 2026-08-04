<h3 align="center">A reproducible Sway/Wayland desktop for Debian 13 (trixie)</h3>

<p align="center">
  <img src="https://img.shields.io/badge/Debian-13%20(trixie)-5E81AC?style=for-the-badge&labelColor=2E3440&logo=debian&logoColor=ECEFF4">
  <img src="https://img.shields.io/badge/Window%20Manager-Sway-88C0D0?style=for-the-badge&labelColor=2E3440">
  <img src="https://img.shields.io/badge/Shell-Bash-81A1C1?style=for-the-badge&labelColor=2E3440&logo=gnubash&logoColor=ECEFF4">
  <img src="https://img.shields.io/badge/Theme-Nord-5E81AC?style=for-the-badge&labelColor=2E3440">
  <img src="https://img.shields.io/badge/License-GPL--3.0-BF616A?style=for-the-badge&labelColor=2E3440&logo=gnu&logoColor=ECEFF4">
</p>

A single `install.sh` that takes a fresh Debian 13 machine to a fully configured, Nord-themed Sway desktop: packages, fonts, icon themes, shell, and dotfiles, in one non-interactive run.

<table align="center">
<tr>
<td>

<img src="./screenshots/2026-08-04_04-05.png" width="900" alt="Desktop screenshot">

</td>
</tr>
</table>

### ✅ Requirements

* **Debian 13 (trixie)**, nothing else — `install.sh` checks `/etc/os-release` and refuses to run on anything else.
* A **regular user with sudo rights**. Don't run the script as root — it calls `sudo` itself wherever needed.
* **`sudo` and `git` must already be installed**, as they are required to clone the repository and execute the installation process.
* A machine installed with only the **"Standard system utilities"** task selected in the Debian installer (`tasksel`) — i.e. a minimal base system, no desktop environment, no display manager, nothing pre-configured. The package scripts in `scripts/` assume that baseline; running on top of an existing DE or a different package set is untested and may conflict.
* An internet connection — apt, Nerd Fonts, Zafiro icons, and bash-qol all fetch from the network during install.

### 🗒️ What's Included

| Role               | Program |
| ------------------ | -------------------------------------- |
| **Window Manager** | [Sway](https://github.com/swaywm/sway) |
| **Terminal**       | [kitty](https://github.com/kovidgoyal/kitty) |
| **Bar**            | [Waybar](https://github.com/Alexays/Waybar) |
| **Launcher**       | [wofi](https://hg.sr.ht/~scoopta/wofi) |
| **Notifications**  | [SwayNotificationCenter](https://github.com/ErikReider/SwayNotificationCenter) |
| **File manager**   | [ranger](https://github.com/ranger/ranger) (TUI), [Thunar](https://gitlab.xfce.org/xfce/thunar) (GUI) |
| **Text editor**    | [Kate](https://apps.kde.org/kate/) |
| **Browser**        | Firefox ESR |
| **Network**        | NetworkManager + nm-applet |
| **Firewall**       | firewalld, firewall-config |
| **Bluetooth**      | blueman |
| **Audio**          | PipeWire / WirePlumber |
| **Screenshot**     | flameshot, grim + slurp |
| **Clipboard**      | CopyQ, wl-clipboard |
| **Music / media**  | cmus, VLC, cava |
| **Shell**          | Bash |
| **GTK theme**      | [Nordic](https://github.com/EliverLara/Nordic) |
| **Icon theme**     | [Zafiro-icons](https://github.com/zayronxio/Zafiro-icons) |
| **Qt/GTK bridge**  | qt5ct, qt6ct, nwg-look, Breeze style |
| **Fonts**          | [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts): JetBrainsMono, FiraCode, Hack, Meslo, SourceCodePro |

> The exact package list lives in `scripts/install-pkgs-*.sh` (one file per category — core, wayland-core, theming, audio, network, notify, storage, system-helpers, graphics, apps). `kitty`, `kate`, `swaylock`, and `swayidle` are installed directly by `install.sh` instead — see the comment block at the top of `install.sh` for why.

### 🚀 Installation

```bash
git clone https://github.com/rebootless/sway-dotfiles
cd sway-dotfiles
chmod +x install.sh
./install.sh
```

No flags. The script runs straight through:

1. Checks you're on Debian 13 (trixie)
2. Installs packages: `kitty` first (before `sway`, so it doesn't pull in `foot`), `kate` with `--no-install-recommends` (so it doesn't pull in `systemsettings`), then the rest via `scripts/install-pkgs-*.sh`
3. Installs Nerd Fonts
4. Installs `ranger` devicons
5. Installs Zafiro icon themes (Dark + Light, downloaded from the latest GitHub release)
6. Copies `dotfiles/` in `$HOME` — anything it's about to overwrite is backed up first to `~/.dotfiles-backup-<timestamp>/`
7. Runs `bash-qol` non-interactively (oh-my-bash, `agnoster` theme, no demo) on top of the dotfiles it just laid down
8. Runs `xdg-user-dirs-update`
9. Enables NetworkManager, bluetooth, and firewalld

At the end it prints a reminder of the intended Qt/GTK theme settings (Nord / Breeze / Zafiro-Icons-Dark or -Light) in case anything didn't take automatically, and reminds you that a reboot (or at least a fresh login) is needed — it won't reboot the machine for you.

> The script is intentionally **not idempotent** as a full re-provisioning tool — it's meant for a first, clean install. Re-running it is safe (nothing is destroyed without a backup), but it will re-apply and re-overwrite dotfiles every time rather than diffing or merging changes.

### 🩹 Known Gaps

- **The Nordic GTK theme is still bundled as a static copy** in `dotfiles/.local/share/themes/Nordic`
- **`Zafiro-Icons-Dark` is assumed as the exact theme name** in `qt5ct.conf`/`qt6ct.conf`/`gtk-3.0/settings.ini`

### 🙏 Acknowledgements

- [Zafiro Icons](https://github.com/zayronxio/Zafiro-icons) — Icon theme
- [Nordic](https://github.com/EliverLara/Nordic) — GTK theme
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) — Fonts
- [Nordic Wallpapers](https://github.com/linuxdotexe/nordic-wallpapers) — Wallpapers

### 📜 License

This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.
