#!/usr/bin/env bash
# Clone tinygrad and create a user venv.
set -euo pipefail
install -d /sachs
[[ -d /sachs/tinygrad/.git ]] || \
  git clone https://github.com/tinygrad/tinygrad.git /sachs/tinygrad
chown -R sachs:sachs /sachs/tinygrad
runuser -u sachs -- bash -c \
  'cd /sachs/tinygrad && python -m venv .venv && . .venv/bin/activate &&
   pip install -U pip && pip install -e .'
