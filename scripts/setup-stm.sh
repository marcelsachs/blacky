#!/usr/bin/env bash
set -euo pipefail
pacman -S --needed --noconfirm arm-none-eabi-binutils arm-none-eabi-gcc arm-none-eabi-gdb \
  arm-none-eabi-newlib openocd stlink dfu-util picocom
id sachs &>/dev/null && usermod -aG uucp sachs
