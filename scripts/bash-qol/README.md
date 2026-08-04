# Bash-QOL

Shell quality-of-life setup for Bash: history, completion, keybindings,
shopt options, zoxide/fzf integration, and modern CLI tools (ripgrep, bat,
eza). No aliases. Optionally installs [oh-my-bash](https://github.com/ohmybash/oh-my-bash).

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Bash](https://img.shields.io/badge/Bash-5.0%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-Supported-A81D33?logo=debian&logoColor=white)](https://www.debian.org)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-Supported-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)

## Structure

```text
bash-qol/
├── bash-qol             # entry point: flag parsing + orchestration
├── requirements.sh      # apt: bash-completion, fzf, zoxide, ripgrep, bat, eza, chafa, git
├── lib/
│   ├── paths.sh         # shared path/marker constants
│   ├── shell-config.sh  # ~/.bashrc + ~/.inputrc (history, completion, keybindings, shopt)
│   ├── omb.sh           # oh-my-bash: manual install + theme (interactive or by name)
│   └── demo.sh          # showcase of eza, bat, ripgrep, and interactive features
└── README.md
```

## Usage

```text
./bash-qol                                     # packages, ~/.bashrc, and ~/.inputrc
./bash-qol --omb=interactive                   # + oh-my-bash, chafa theme picker
./bash-qol --omb=non-interactive --theme=NAME  # + oh-my-bash, no prompts
./bash-qol --demo                              # + showcase as a final step
./bash-qol --help
```

Flags combine freely, e.g.:

```bash
./bash-qol --omb=non-interactive --theme=agnoster --demo
```

## Quick Start

```bash
git clone https://github.com/rebootless/bash-qol.git && \
cd bash-qol && chmod +x bash-qol &&\
./bash-qol
```

Interactive oh-my-bash setup:

```bash
git clone https://github.com/rebootless/bash-qol.git && \
cd bash-qol && chmod +x bash-qol &&\
./bash-qol --omb=interactive --demo
```

Rules:
- `--theme` is only valid together with `--omb=non-interactive`.
- `--omb=non-interactive` requires `--theme=NAME`.
- Unknown theme names fail with the actual list of themes shipped in
  `~/.oh-my-bash/themes`.

## oh-my-bash Integration

Only the manual integration is supported: [oh-my-bash](https://github.com/ohmybash/oh-my-bash) is git-cloned to
`~/.oh-my-bash`, and a small block is **prepended to the top** of
`~/.bashrc` — nothing else in the file is touched. The official installer
is intentionally not used because it replaces `~/.bashrc` wholesale.

## Idempotency

Re-running is always safe:
- `requirements.sh` — `apt-get install` no-ops on installed packages.
- Managed blocks in `~/.bashrc` (`# >>> bash-qol >>>` / `# >>> oh-my-bash >>>`)
  are replaced, not duplicated. Before each update, the previous file is
  backed up as `~/.bashrc.bak.<timestamp>`.
- `~/.inputrc` is replaced outright, with the same backup pattern.

## License

This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.
