#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm bash tmux
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
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"
EOF
echo 'set -g mouse on' >/sachs/.tmux.conf
id sachs &>/dev/null && chown -R sachs:sachs /sachs
