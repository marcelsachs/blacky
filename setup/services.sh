#!/usr/bin/env bash
set -euo pipefail
mkdir -p /etc/systemd/network
systemctl enable systemd-networkd systemd-resolved sshd iwd

# Install systemd-resolved stub link for the booted system.
# arch-chroot bind-mounts the host resolv.conf over /etc/resolv.conf (EBUSY on rm/ln).
# Unmount it, write the permanent symlink, and seed the stub path so DNS still
# works for the rest of this chroot (resolved is not running here; /run is tmpfs).
mkdir -p /run/systemd/resolve
if [[ -e /etc/resolv.conf || -L /etc/resolv.conf ]]; then
  cat /etc/resolv.conf >/run/systemd/resolve/stub-resolv.conf 2>/dev/null || true
fi
if mountpoint -q /etc/resolv.conf; then
  umount /etc/resolv.conf
fi
if [[ ! -s /run/systemd/resolve/stub-resolv.conf ]]; then
  printf 'nameserver 1.1.1.1\nnameserver 9.9.9.9\n' >/run/systemd/resolve/stub-resolv.conf
fi
rm -f /etc/resolv.conf
ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

cat >/etc/systemd/network/20-network.network <<'EOF'
[Match]
Type=ether wlan

[Network]
DHCP=yes
EOF
