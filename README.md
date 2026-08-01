# blacky

Minimal Arch install for the blackwell forge.

## Layout

```
install.sh           # ISO only: partition, pacstrap, chroot
packages/packages.txt
host/                # static files → /
home/                # static files → /sachs
scripts/
  chroot.sh          # entry from install.sh
  configure.sh       # packages + host + home + services
  st.sh tinygrad.sh grok.sh wifi.sh
  stm.sh             # optional ST tooling (needs zips in /tmp/stm)
```

Not twenty bash files for `pacman -S chromium`. Packages are data. Config is files. Scripts are only for procedures.

## Install (Arch ISO)

```bash
bash install.sh
```

## Re-configure after boot

```bash
sudo bash /sachs/blacky/scripts/configure.sh
```

## STM stack (optional)

```bash
# three myST zips in /tmp/stm
sudo bash /sachs/blacky/scripts/stm.sh
# CubeMX: /opt/st/cubemx/STM32CubeMX
```
