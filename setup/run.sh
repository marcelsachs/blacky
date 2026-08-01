#!/usr/bin/env bash
set -euo pipefail
S="$(cd "$(dirname "$0")" && pwd)"
for x in \
  network \
  wifi \
  bluetooth \
  swap \
  keyboard \
  user \
  shell \
  editor \
  git \
  c \
  x11 \
  wm \
  terminal \
  nvidia \
  chromium \
  obsidian \
  tailscale \
  grok \
  tinygrad
do
  bash "$S/$x.sh"
done
