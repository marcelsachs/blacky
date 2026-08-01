#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm bluez bluez-utils
systemctl enable bluetooth
