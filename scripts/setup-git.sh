#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm git github-cli
install -d /sachs
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
id sachs &>/dev/null && chown sachs:sachs /sachs/.gitconfig
