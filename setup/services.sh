#!/usr/bin/env bash
set -euo pipefail
mkdir -p /etc/systemd/network
systemctl enable systemd-networkd systemd-resolved sshd iwd
# rm first: ln -sf fails with "same file" if resolv.conf already points at the stub (common in arch-chroot).
rm -f /etc/resolv.conf
ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
cat >/etc/systemd/network/20-network.network <<'EOF'
[Match]
Type=ether wlan

[Network]
DHCP=yes
EOF
