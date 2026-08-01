#!/usr/bin/env bash
# Post-base config. From ISO (arch-chroot) or later:
#   sudo bash /sachs/blacky/scripts/configure.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[[ $(id -u) -eq 0 ]] || { echo "run as root" >&2; exit 1; }

# first install from ISO often has no root password yet
if ! passwd -S root 2>/dev/null | grep -q ' P '; then
  printf 'root:root\n' | chpasswd
fi

# --- packages ---
mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$ROOT/packages/packages.txt")
pacman -S --needed --noconfirm "${pkgs[@]}"

# --- host files ---
# shellcheck disable=SC2044
while IFS= read -r -d '' f; do
  rel=${f#"$ROOT/host/"}
  install -D -m 644 "$f" "/$rel"
done < <(find "$ROOT/host" -type f -print0)
chmod 440 /etc/sudoers.d/wheel 2>/dev/null || true

# dynamic bits that cannot live as static files
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc 2>/dev/null || true
locale-gen
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true

if [[ -b /dev/nvme0n1p2 ]]; then
  install -d /etc/kernel /boot/EFI/BOOT
  uuid=$(blkid -s PARTUUID -o value /dev/nvme0n1p2)
  echo "root=PARTUUID=$uuid rw quiet" >/etc/kernel/cmdline
fi

# --- user ---
id sachs &>/dev/null || useradd -m -d /sachs \
  -G wheel,video,audio,input,uucp,rfkill,users -s /bin/bash sachs
# password once (interactive); re-runs skip
if [[ ! -f /sachs/.blacky-user-ok ]]; then
  if [[ -t 0 ]]; then
    passwd sachs
  else
    echo "configure: no tty — set password later: passwd sachs" >&2
  fi
  touch /sachs/.blacky-user-ok
fi

# --- home tree ---
install -d /sachs
cp -a "$ROOT/home/." /sachs/
chown -R sachs:sachs /sachs

# --- services ---
systemctl enable systemd-networkd systemd-resolved sshd iwd \
  bluetooth tailscaled 2>/dev/null || true

# --- swap ---
if [[ ! -f /swapfile ]]; then
  fallocate -l 32G /swapfile 2>/dev/null || fallocate -l 8G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
fi
grep -q '^/swapfile ' /etc/fstab 2>/dev/null || \
  echo '/swapfile none swap defaults 0 0' >>/etc/fstab

# --- nvidia initramfs if preset exists ---
[[ -f /etc/mkinitcpio.d/linux.preset ]] && mkinitcpio -P

# --- optional interactive wifi (skip if non-tty) ---
if [[ -t 0 && -x $ROOT/scripts/wifi.sh ]]; then
  bash "$ROOT/scripts/wifi.sh" || true
fi

# --- build/extra procedures (real work, not package wrappers) ---
bash "$ROOT/scripts/st.sh"
bash "$ROOT/scripts/tinygrad.sh"
bash "$ROOT/scripts/grok.sh"

# keep a copy of the repo under home
if [[ -d $ROOT && ! -e /sachs/blacky ]]; then
  cp -a "$ROOT" /sachs/blacky
fi
chown -R sachs:sachs /sachs

echo "configure: done"
echo "  desktop: startx"
echo "  STM (optional): put zips in /tmp/stm && sudo bash /sachs/blacky/scripts/stm.sh"
