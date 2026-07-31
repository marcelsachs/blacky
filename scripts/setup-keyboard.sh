#!/usr/bin/env bash
set -euo pipefail
echo 'KEYMAP=neoqwertz' >/etc/vconsole.conf
mkdir -p /etc/X11/xorg.conf.d
cat >/etc/X11/xorg.conf.d/00-keyboard.conf <<'EOF'
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "de"
    Option "XkbVariant" "neo_qwertz"
EndSection
EOF
