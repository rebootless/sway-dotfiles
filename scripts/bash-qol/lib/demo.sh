#!/bin/bash

run_demo() {
    local c_cyan=$'\e[1;36m' c_green=$'\e[1;32m' c_yellow=$'\e[1;33m' c_mag=$'\e[1;35m' c_reset=$'\e[0m'

    local bat_cmd="bat"
    if command -v batcat >/dev/null 2>&1; then
        bat_cmd="batcat"
    fi

    echo -e "${c_cyan}=====================================================${c_reset}"
    echo -e "${c_cyan}                    BASH-QOL-DEMO                    ${c_reset}"
    echo -e "${c_cyan}=====================================================${c_reset}\n"

    local demo_dir
    demo_dir=$(mktemp -d -t bash-qol-demo-XXXXXX)
    pushd "$demo_dir" > /dev/null

    echo -e "${c_yellow}Creating test files for the demonstration...${c_reset}"
    mkdir -p project/src project/tests project/docs
    echo "print('Hello, Bash Coding Partner!')" > project/src/main.py
    echo "def calculate(a, b): return a + b # TODO: add math logic" > project/src/utils.py
    echo "import pytest" > project/tests/test_main.py
    echo "# Documentation" > project/docs/readme.md
    echo "TODO: Write tests!" > project/TODO.txt

    sleep 1

    echo -e "\n${c_green}>>> 1. EZA (a modern replacement for ls) ${c_reset}"
    echo -e "${c_mag}\$ eza -lah --icons=auto project/${c_reset}"
    eza -lah --icons=auto project/
    echo ""
    echo -e "${c_mag}\$ eza --tree --icons=auto project/${c_reset}"
    eza --tree --icons=auto project/

    read -n 1 -s -r -p "Press any key to continue..."
    echo ""

    echo -e "\n${c_green}>>> 2. BAT (cat clone with syntax highlighting and Git integration) ${c_reset}"
    echo -e "${c_mag}\$ $bat_cmd project/src/utils.py${c_reset}"
    "$bat_cmd" project/src/utils.py

    read -n 1 -s -r -p "Press any key to continue..."
    echo ""

    echo -e "\n${c_green}>>> 3. RIPGREP (ultra-fast recursive text search) ${c_reset}"
    echo -e "${c_mag}\$ rg \"TODO\" project/${c_reset}"
    rg "TODO" project/

    read -n 1 -s -r -p "Press any key to continue..."
    echo ""

    echo -e "\n${c_green}>>> 4. INTERACTIVE FEATURES (try them yourself after the tour!) ${c_reset}"
    cat << EOF
autocd: Just type the directory path without 'cd'.
   ${c_mag}\$ /var/log${c_reset} -> automatically changes directory to /var/log

zoxide (Smart cd): It remembers your most used directories.
   ${c_mag}\$ z pro${c_reset} -> instantly jumps to ~/Documents/project
   ${c_mag}\$ zi${c_reset}    -> opens an interactive directory picker

fzf (History search):
   Press ${c_mag}Ctrl + R${c_reset} and start typing. It finds commands even with typos!
EOF

    echo -e "\n${c_yellow}Cleaning up: removing test files...${c_reset}"
    popd > /dev/null
    rm -rf "$demo_dir"

    echo -e "${c_cyan}Tour completed! Happy coding!${c_reset}"
}
