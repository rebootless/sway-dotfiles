#!/bin/bash

OMB_THEMES=()
SELECTED_THEME=""

list_omb_themes() {
    OMB_THEMES=()
    while IFS= read -r -d '' f; do
        OMB_THEMES+=("$(basename "$(dirname "$f")")")
    done < <(find "$OSH/themes" -maxdepth 2 -name '*.theme.sh' -print0 | sort -z)
}

# Interactive Tab-cycle / Enter-confirm picker with a chafa preview.
# Sets $SELECTED_THEME.
pick_theme_interactive() {
    list_omb_themes
    if [[ ${#OMB_THEMES[@]} -eq 0 ]]; then
        echo "[!] No themes found in $OSH/themes." >&2
        exit 1
    fi

    local idx=0 theme theme_dir img_file key
    while true; do
        theme="${OMB_THEMES[$idx]}"
        theme_dir="$OSH/themes/$theme"

        img_file=$(find "$theme_dir" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | head -n 1)

        clear
        echo "[Tab] = next theme, [Enter] = confirm selection"
        echo "-----------------------------------------------"
        echo "[$((idx+1))/${#OMB_THEMES[@]}] Theme: $theme"
        echo ""
        echo "Preview:"

        if [[ -n "$img_file" && -f "$img_file" ]]; then
            chafa --size=65x16 "$img_file"
        else
            echo "[No preview image available for this theme]"
        fi
        echo ""

        IFS= read -rsn1 key
        if [[ "$key" == $'\t' ]]; then
            idx=$(((idx + 1) % ${#OMB_THEMES[@]}))
        elif [[ -z "$key" ]]; then
            clear
            break
        fi
    done

    SELECTED_THEME="${OMB_THEMES[$idx]}"
}

# Validates $1 against the themes actually shipped in $OSH/themes.
# Sets $SELECTED_THEME on success, exits 1 with the available list otherwise.
validate_theme() {
    local requested="$1" t
    list_omb_themes

    for t in "${OMB_THEMES[@]}"; do
        if [[ "$t" == "$requested" ]]; then
            SELECTED_THEME="$requested"
            return 0
        fi
    done

    echo "Unknown theme: $requested" >&2
    echo "Available themes: ${OMB_THEMES[*]}" >&2
    exit 1
}

# Prepends the oh-my-bash managed block to the top of ~/.bashrc.
apply_omb_theme() {
    local theme="$1" ts
    ts="$(date +%Y%m%d_%H%M%S)"

    if [[ -f "$BASHRC" ]]; then
        cp "$BASHRC" "${BASHRC}.bak.${ts}"
        echo "~/.bashrc backed up to ${BASHRC}.bak.${ts}"
        if grep -qF "$MARK_START_OMB" "$BASHRC"; then
            sed -i "/${MARK_START_OMB}/,/${MARK_END_OMB}/d" "$BASHRC"
            echo "Removed previous oh-my-bash block."
        fi
    else
        touch "$BASHRC"
        echo "No existing ~/.bashrc found, creating new one."
    fi

    {
        echo "$MARK_START_OMB"
        echo 'export OSH="$HOME/.oh-my-bash"'
        echo "OSH_THEME=\"$theme\""
        echo "source \"\$OSH/oh-my-bash.sh\""
        echo "$MARK_END_OMB"
        echo ""
        cat "$BASHRC"
    } > "${BASHRC}.tmp"
    mv "${BASHRC}.tmp" "$BASHRC"

    echo "oh-my-bash block prepended to the top of ~/.bashrc."
}

# Orchestrates install + theme selection.
#   $1: "true" for the interactive picker, "false" for a direct theme name
#   $2: theme name (used only when $1 is "false")
configure_omb() {
    local interactive="$1" theme="${2:-}"

    echo "==> oh-my-bash"

    if [[ -d "$OSH" ]]; then
        echo "oh-my-bash already installed at $OSH, refreshing theme only."
    else
        echo "Cloning oh-my-bash into $OSH..."
        git clone https://github.com/ohmybash/oh-my-bash.git "$OSH"
        echo "oh-my-bash cloned."
    fi

    echo "==> Theme selection"

    if [[ "$interactive" == "true" ]]; then
        pick_theme_interactive
    else
        validate_theme "$theme"
    fi

    apply_omb_theme "$SELECTED_THEME"
    echo "oh-my-bash theme set to: $SELECTED_THEME"
}
