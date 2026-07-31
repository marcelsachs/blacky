#!/usr/bin/env bash
set -euo pipefail
[[ -f /swapfile ]] || { fallocate -l 32G /swapfile || fallocate -l 8G /swapfile; chmod 600 /swapfile; mkswap /swapfile; }
grep -q '^/swapfile ' /etc/fstab 2>/dev/null || echo '/swapfile none swap defaults 0 0' >>/etc/fstab
