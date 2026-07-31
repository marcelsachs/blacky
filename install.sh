#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
[[ $(id -u) -eq 0 ]] || { echo "run as root on Arch ISO" >&2; exit 1; }

blkdiscard -f /dev/nvme0n1 2>/dev/null || true
sgdisk -Z /dev/nvme0n1
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:EFI -n 2:0:0 -t 2:8300 -c 2:arch /dev/nvme0n1
partprobe /dev/nvme0n1 && udevadm settle
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 -F /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot

pacman -Sy --noconfirm archlinux-keyring
command -v reflector >/dev/null && reflector --country Germany --latest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist || true
pacstrap -K /mnt base linux linux-firmware-amdgpu linux-firmware-intel linux-firmware-nvidia \
  linux-firmware-realtek linux-firmware-whence wireless-regdb openssh iwd
genfstab -U /mnt >>/mnt/etc/fstab

cp -a "$REPO" /mnt/root/blackwell
arch-chroot /mnt bash /root/blackwell/chroot.sh || echo "chroot failed; base is on disk" >&2
umount -R /mnt || true
