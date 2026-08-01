#!/usr/bin/env bash
# Post-install only. Drop ST Linux zips in /tmp/stm, then:
#   sudo bash /sachs/blacky/scripts/stm.sh
#
# Zips (myST login):
#   SetupSTM32CubeProgrammer_linux_64.zip  → /opt/st/progr
#   SetupSTM32CubeMX-*-Lin-x86_64.zip      → /opt/st/cubemx
#   stedgeai-lin.zip                       → /opt/st/edgeai  (needs network)
#
# Notes:
#   - Programmer + CubeMX are IzPack: use -options (not InstallBuilder --mode unattended).
#   - Edge AI is Qt Installer Framework (online): install --root … --accept-licenses …
#   - Each zip is extracted into its own work dir — both ship jre/ (8 vs 21) and must not clobber.
#   - Edge AI has no default packages; we install latest core + STM32 MCU module.
# PATH: /etc/profile.d/stm.sh  (login shells; source it or add to ~/.bashrc for terminals)
set -euo pipefail

D=/tmp/stm
P=/opt/st
export LANG="${LANG:-C.UTF-8}"

pacman -S --needed --noconfirm \
  arm-none-eabi-binutils arm-none-eabi-gcc arm-none-eabi-gdb arm-none-eabi-newlib \
  openocd stlink dfu-util picocom jre-openjdk-headless unzip

id sachs &>/dev/null && usermod -aG uucp sachs

[[ -d $D ]] || { echo "stm: put zips in $D" >&2; exit 1; }
install -d "$P"/{progr,cubemx,edgeai}
cd "$D"
shopt -s nullglob

# Extract zip into a private work dir (keeps each product's bundled JRE isolated).
unpack() {
  local zip=$1 dir=$2
  echo "stm: unzip $zip → $dir"
  rm -rf "$dir"
  mkdir -p "$dir"
  unzip -qo "$zip" -d "$dir"
}

# IzPack silent install: template → set INSTALL_PATH → -options
# Always use absolute path: bare filename is not on PATH (cwd is not searched).
# Run from the product work dir so the wrapper finds ./jre.
izpack_install() {
  local bin=$1 dest=$2
  local opts tpl work
  [[ -f $bin ]] || { echo "stm: skip missing $bin"; return 0; }
  chmod +x "$bin"
  bin=$(readlink -f "$bin")
  work=$(dirname "$bin")
  tpl=$(mktemp /tmp/st-opts.XXXXXX)
  opts=$(mktemp /tmp/st-opts.XXXXXX)
  echo "stm: IzPack install $bin → $dest"
  (
    cd "$work"
    # Template is properties-style (# comments + INSTALL_PATH=); not XML.
    "$bin" -options-template "$tpl" || true
  )
  if [[ -s $tpl ]]; then
    sed "s|^INSTALL_PATH=.*|INSTALL_PATH=$dest|" "$tpl" >"$opts"
    grep -q '^INSTALL_PATH=' "$opts" || echo "INSTALL_PATH=$dest" >>"$opts"
  else
    printf '# auto\nINSTALL_PATH=%s\n' "$dest" >"$opts"
  fi
  (
    cd "$work"
    "$bin" -options "$opts"
  )
  rm -f "$tpl" "$opts"
}

# --- CubeProgrammer (bundled JRE 8) ---
for z in SetupSTM32CubeProgrammer*.zip; do
  unpack "$z" "$D/work-progr"
  for s in "$D"/work-progr/SetupSTM32CubeProgrammer-*.linux; do
    izpack_install "$s" "$P/progr"
  done
done

# --- CubeMX (bundled JRE 21) ---
for z in SetupSTM32CubeMX*.zip; do
  unpack "$z" "$D/work-cubemx"
  for s in "$D"/work-cubemx/SetupSTM32CubeMX-*; do
    [[ -f $s && $s != *.zip ]] || continue
    izpack_install "$s" "$P/cubemx"
  done
done

# --- Edge AI: Qt Installer Framework (online). Headless needs non-xcb platform. ---
edgeai_install() {
  local z bin core
  for z in stedgeai*.zip; do
    unpack "$z" "$D/work-edgeai"
  done
  bin=$D/work-edgeai/stedgeai-linux-onlineinstaller
  [[ -f $bin ]] || bin=$D/stedgeai-linux-onlineinstaller
  [[ -f $bin ]] || { echo "stm: skip edgeai (no installer)"; return 0; }
  chmod +x "$bin"
  bin=$(readlink -f "$bin")
  echo "stm: Edge AI online install → $P/edgeai (needs network)"
  export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-minimal}"
  # Catalogue lists name="stedgeai0NNN" and name="stedgeai0NNN.stm32mcu".
  core=$("$bin" --accept-messages search 2>/dev/null \
    | grep -oE 'name="stedgeai[0-9]+"' \
    | sed 's/name="//;s/"//' \
    | sort -u | tail -1)
  core=${core:-stedgeai0400}
  echo "stm: installing $core ${core}.stm32mcu"
  "$bin" \
    --root "$P/edgeai" \
    --accept-licenses \
    --accept-messages \
    --confirm-command \
    install "$core" "${core}.stm32mcu"
}

edgeai_install

# PATH: progr CLI, CubeMX launcher, any Edge AI Utilities/linux tree
cat >/etc/profile.d/stm.sh <<'EOF'
export PATH="/opt/st/progr/bin:/opt/st/cubemx:$PATH"
for d in /opt/st/edgeai/*/Utilities/linux /opt/st/edgeai/Utilities/linux; do
  [ -d "$d" ] && PATH="$PATH:$d"
done
export PATH
EOF
chmod 644 /etc/profile.d/stm.sh
echo "stm: done — source /etc/profile.d/stm.sh (or re-login) for PATH"
echo "stm: CubeMX GUI: DISPLAY=:0 STM32CubeMX"
