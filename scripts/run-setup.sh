#!/usr/bin/env bash
set -euo pipefail
S="$(cd "$(dirname "$0")" && pwd)"
for x in setup-services setup-swap setup-keyboard setup-wifi create-user \
  setup-shell setup-editor setup-git setup-x11 setup-wm setup-terminal \
  setup-nvidia setup-stm setup-tinygrad; do
  bash "$S/$x.sh"
done
