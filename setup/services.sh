#!/usr/bin/env bash
set -euo pipefail
mkdir -p /etc/systemd/network
systemctl enable systemd-networkd systemd-resolved sshd iwd
# Do not touch /etc/resolv.conf here: arch-chroot bind-mounts the host's
# resolv.conf, so rm/ln fails with EBUSY. install.sh sets the stub link on /mnt after chroot.
cat >/etc/systemd/network/20-network.network <<'EOF'
[Match]
Type=ether wlan

[Network]
DHCP=yes
EOF
