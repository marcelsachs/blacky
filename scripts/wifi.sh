#!/usr/bin/env bash
# Optional interactive iwd profile.
set -euo pipefail
[[ -t 0 ]] || exit 0
read -r -p "Wi-Fi auto-connect after reboot? [y/N] " a
[[ $a =~ ^[Yy]$ ]] || exit 0
read -r -p "SSID: " s
read -r -s -p "Password (empty if open): " p; echo
mkdir -p /var/lib/iwd
chmod 700 /var/lib/iwd
if [[ -z $p ]]; then
  printf '[Settings]\nAutoConnect=true\n' >"/var/lib/iwd/$s.open"
  chmod 600 "/var/lib/iwd/$s.open"
  exit 0
fi
printf '[Security]\nPassphrase=%s\n\n[Settings]\nAutoConnect=true\n' \
  "$p" >"/var/lib/iwd/$s.psk"
chmod 600 "/var/lib/iwd/$s.psk"
