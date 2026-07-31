#!/usr/bin/env bash
set -euo pipefail
S="$(cd "$(dirname "$0")/scripts" && pwd)"

echo 'en_US.UTF-8 UTF-8' >/etc/locale.gen
echo 'LANG=en_US.UTF-8' >/etc/locale.conf
echo blackwell >/etc/hostname
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc && locale-gen
printf 'root:root\n' | chpasswd

mkdir -p /etc/mkinitcpio.d /boot/EFI/BOOT
cat >/etc/mkinitcpio.d/linux.preset <<'EOF'
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"
ALL_cmdline="/etc/kernel/cmdline"
PRESETS=('default')
default_uki="/boot/EFI/BOOT/BOOTX64.EFI"
EOF
echo "root=PARTUUID=$(blkid -s PARTUUID -o value /dev/nvme0n1p2) rw quiet" >/etc/kernel/cmdline
mkinitcpio -P

bash "$S/run-setup.sh"
[[ -d /root/blackwell && ! -e /sachs/blackwell ]] && cp -a /root/blackwell /sachs/blackwell
chown -R sachs:sachs /sachs
