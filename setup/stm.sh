#!/usr/bin/env bash
# Post-install only. Drop ST Linux zips in /tmp/stm, then:
#   sudo bash /sachs/blacky/setup/stm.sh
#
# Zips (myST login):
#   SetupSTM32CubeProgrammer_linux_64.zip  → /opt/st/progr
#   SetupSTM32CubeMX-*-Lin-x86_64.zip      → /opt/st/cubemx
#   stedgeai-lin.zip                       → /opt/st/edgeai  (needs network)
#
# PATH: /etc/profile.d/stm.sh
set -euo pipefail

D=/tmp/stm
P=/opt/st

pacman -S --needed --noconfirm \
  arm-none-eabi-binutils arm-none-eabi-gcc arm-none-eabi-gdb arm-none-eabi-newlib \
  openocd stlink dfu-util picocom jre-openjdk-headless unzip

id sachs &>/dev/null && usermod -aG uucp sachs

[[ -d $D ]] || { echo "stm: put zips in $D" >&2; exit 1; }
install -d "$P"/{progr,cubemx,edgeai}
cd "$D"
shopt -s nullglob
for z in *.zip; do unzip -qo "$z"; done

install_st() {
  local bin=$1 dest=$2
  [[ -f $bin ]] || return 0
  chmod +x "$bin"
  "$bin" --mode unattended --unattendedmodeui none --prefix "$dest"
}

for s in SetupSTM32CubeProgrammer-*.linux; do install_st "$s" "$P/progr"; done
for s in SetupSTM32CubeMX-*; do
  [[ $s == *.zip ]] && continue
  install_st "$s" "$P/cubemx"
done
install_st stedgeai-linux-onlineinstaller "$P/edgeai"

cat >/etc/profile.d/stm.sh <<'EOF'
export PATH="/opt/st/progr/bin:/opt/st/cubemx:$PATH"
for d in /opt/st/edgeai/*/Utilities/linux /opt/st/edgeai/Utilities/linux; do
  [ -d "$d" ] && PATH="$PATH:$d"
done
EOF
