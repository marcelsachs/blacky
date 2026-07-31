#!/usr/bin/env bash
set -euo pipefail
S="$(cd "$(dirname "$0")" && pwd)"
for x in services swap keyboard wifi user shell editor git x11 wm terminal \
  nvidia cuda chromium obsidian grok tailscale tinygrad; do
  bash "$S/$x.sh"
done
