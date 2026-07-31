#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm base-devel git curl ttf-ibm-plex
install -d /sachs
[[ -d /sachs/st/.git ]] || git clone https://git.suckless.org/st /sachs/st
cd /sachs/st
mkdir -p patches
B=https://st.suckless.org/patches/scrollback
for p in st-scrollback-0.9.2.diff st-scrollback-mouse-0.9.2.diff st-scrollback-mouse-altscreen-20200416-5703aa0.diff; do
  [[ -f patches/$p ]] || curl -fLo patches/$p "$B/$p"
  patch -p1 -N <patches/$p || true
done
cp config.def.h config.h
sed -i 's/font = ".*"/font = "IBM Plex Mono:pixelsize=12:antialias=true:autohint=true"/' config.h
make clean && make && make install
id sachs &>/dev/null && chown -R sachs:sachs /sachs/st
