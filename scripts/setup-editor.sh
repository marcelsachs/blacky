#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm vim
install -d /sachs
cat >/sachs/.vimrc <<'EOF'
colorscheme lunaperche
set background=dark
set expandtab
set hlsearch
set ignorecase
set incsearch
set shiftwidth=4
set tabstop=4
syntax on
EOF
id sachs &>/dev/null && chown sachs:sachs /sachs/.vimrc
