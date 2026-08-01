#!/usr/bin/env bash
set -euo pipefail
mkdir -p /etc/systemd/network
systemctl enable systemd-networkd systemd-resolved sshd iwd
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true
printf '[Match]\nType=ether wlan\n\n[Network]\nDHCP=yes\n' \
  >/etc/systemd/network/20-network.network
pacman -S --needed --noconfirm tailscale
systemctl enable tailscaled
