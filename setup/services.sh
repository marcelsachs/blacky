#!/usr/bin/env bash
set -euo pipefail
mkdir -p /etc/systemd/network
systemctl enable systemd-networkd systemd-resolved sshd iwd
# Ignore failure if already linked / bind-mounted by arch-chroot (set -e would abort).
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true
cat >/etc/systemd/network/20-network.network <<'EOF'
[Match]
Type=ether wlan

[Network]
DHCP=yes
EOF
