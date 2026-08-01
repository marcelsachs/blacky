#!/usr/bin/env bash
# Runs inside arch-chroot after pacstrap. Minimal base + full configure.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

printf 'root:root\n' | chpasswd
bash "$ROOT/scripts/configure.sh"
