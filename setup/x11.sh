#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm xorg-server xorg-xinit xorg-xrandr xorg-xset xorg-xinput
mkdir -p /etc/X11/xorg.conf.d /sachs
echo 'exec i3' >/sachs/.xinitrc
id sachs &>/dev/null && chown sachs:sachs /sachs/.xinitrc
cat >/etc/X11/xorg.conf.d/10-disable-blanking.conf <<'EOF'
Section "ServerFlags"
	Option "BlankTime" "0"
	Option "StandbyTime" "0"
	Option "SuspendTime" "0"
	Option "OffTime" "0"
EndSection
EOF
