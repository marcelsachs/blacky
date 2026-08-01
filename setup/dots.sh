#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm vim git github-cli
install -d /sachs
cat >/sachs/.bashrc <<'EOF'
[[ $- != *i* ]] && return
export EDITOR=vim
PS1='\u\[\033[1;38;5;81m\]@\h\[\033[0m\]: \w \[\033[1;38;5;226m\]$ \[\033[0m\]'
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
EOF
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
cat >/sachs/.gitconfig <<'EOF'
[user]
	name = Marcel Sachs
	email = sachsmarcel@proton.me
[core]
	editor = vim
[init]
	defaultBranch = master
[credential "https://github.com"]
	helper = !/usr/bin/gh auth git-credential
[credential "https://gist.github.com"]
	helper = !/usr/bin/gh auth git-credential
EOF
chown -R sachs:sachs /sachs
