#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm nvidia-open nvidia-utils
echo 'options nvidia_drm modeset=1' >/etc/modprobe.d/nvidia.conf
[[ -f /etc/mkinitcpio.d/linux.preset ]] && mkinitcpio -P
