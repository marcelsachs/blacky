#!/usr/bin/env bash
set -euo pipefail
S="$(cd "$(dirname "$0")" && pwd)"
for x in \
  services \
  swap \
  keyboard \
  wifi \
  user \
  dots \
  c \
  x11 \
  wm \
  terminal \
  nvidia \
  apps \
  grok \
  tinygrad
do
  bash "$S/$x.sh"
done
