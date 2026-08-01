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
  dots \
  c \
  x11 \
  wm \
  terminal \
  nvidia \
  apps \
  tailscale \
  grok \
  tinygrad
do
  bash "$S/$x.sh"
done
