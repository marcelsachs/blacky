#!/usr/bin/env bash
set -euo pipefail
id sachs &>/dev/null || useradd -m -d /sachs -G wheel,video,audio,input,uucp,rfkill,users -s /bin/bash sachs
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >/etc/sudoers.d/wheel
chmod 0440 /etc/sudoers.d/wheel
passwd sachs
chown -R sachs:sachs /sachs
