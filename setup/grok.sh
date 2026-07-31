#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm curl
runuser -u sachs -- bash -c 'curl -fsSL https://x.ai/cli/install.sh | bash'
