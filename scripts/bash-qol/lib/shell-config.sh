#!/bin/bash

configure_shell() {
    local ts
    ts="$(date +%Y%m%d_%H%M%S)"

    echo "==> Configuring ~/.bashrc"

    if [[ -f "$BASHRC" ]]; then
        cp "$BASHRC" "${BASHRC}.bak.${ts}"
        echo "~/.bashrc backed up to ${BASHRC}.bak.${ts}"
        if grep -qF "$MARK_START_QOL" "$BASHRC"; then
            sed -i "/${MARK_START_QOL}/,/${MARK_END_QOL}/d" "$BASHRC"
            echo "Removed previous managed block."
        fi
    else
        touch "$BASHRC"
        echo "No existing ~/.bashrc found, creating new one."
    fi

    {
        echo ""
        echo "$MARK_START_QOL"
        cat <<EOF
# History
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoredups:erasedups
HISTIGNORE="ls:l:ll:pwd:clear:history"
shopt -s histappend
PROMPT_COMMAND="history -a; history -n\${PROMPT_COMMAND:+; \$PROMPT_COMMAND}"

# Completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Improved tab behavior
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'TAB:menu-complete'

# History search with arrow keys
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Useful shell options
shopt -s autocd
shopt -s cdspell
shopt -s checkwinsize
shopt -s dirspell
shopt -s globstar
EOF
        cat <<'EOF'

# zoxide (smart cd)
eval "$(zoxide init bash)"

# fzf (Ctrl+R history search)
if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
else
    [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
    [ -f /usr/share/doc/fzf/examples/completion.bash ]   && . /usr/share/doc/fzf/examples/completion.bash
fi
EOF
        echo "$MARK_END_QOL"
    } >> "$BASHRC"

    echo "~/.bashrc updated."

    echo "==> Configuring ~/.inputrc"

    if [[ -f "$INPUTRC" ]]; then
        cp "$INPUTRC" "${INPUTRC}.bak.${ts}"
        echo "~/.inputrc backed up to ${INPUTRC}.bak.${ts}"
    fi

    cat > "$INPUTRC" <<'EOF'
set editing-mode emacs

set colored-stats On
set colored-completion-prefix On

set completion-ignore-case On
set show-all-if-ambiguous On
set menu-complete-display-prefix On

set mark-symlinked-directories On
set visible-stats On

"\e[A": history-search-backward
"\e[B": history-search-forward
EOF

    echo "~/.inputrc written."

    echo ""
    echo "==> Keybindings"
    printf "  %-12s %s\n" "Tab"     "cycle through completions (menu-complete)"
    printf "  %-12s %s\n" "Up/Down" "search history by text already on the line"
    printf "  %-12s %s\n" "Ctrl+R"  "fuzzy search through command history (fzf)"
    echo "  completion is case-insensitive, colored, shows all matches"

    echo ""
    echo "==> Shell behavior"
    printf "  %-14s %s\n" "autocd"       "bare directory path -> cd into it"
    printf "  %-14s %s\n" "cdspell"      "autocorrects minor 'cd' typos"
    printf "  %-14s %s\n" "dirspell"     "autocorrects typos in path completion"
    printf "  %-14s %s\n" "globstar"     "'**' matches files recursively"
    printf "  %-14s %s\n" "checkwinsize" "terminal size updates after each command"

    echo ""
    echo "==> History"
    echo "  100000 commands in memory / 200000 in ~/.bash_history"
    echo "  duplicates are not stored (ignoredups:erasedups)"
    echo "  ls, l, ll, pwd, clear, history are never stored"
    echo "  history is shared live between open terminal sessions"

    echo ""
    echo "==> New tools"
    printf "  %-12s %s\n" "z <name>"   "zoxide: jump to a frequent directory"
    printf "  %-12s %s\n" "zi"         "zoxide: interactive directory picker"
    printf "  %-12s %s\n" "rg <text>"  "ripgrep: fast recursive text search"
    printf "  %-12s %s\n" "bat <file>" "syntax-highlighted 'cat'"
    printf "  %-12s %s\n" "eza"        "modern 'ls' (icons, git status, tree)"
    printf "  %-12s %s\n" "eza -T"     "tree view of a directory"
}
