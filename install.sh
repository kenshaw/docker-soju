#!/bin/bash
# Installs the systemd user units and starts the daily timer.
set -euo pipefail

SRC="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SRC"

unitdir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$unitdir"
# The service is written with the real directory of this repository (a symlink could not hold it); the timer is the same everywhere.
sed "s|@SRC@|$SRC|g" systemd/soju-image.service > "$unitdir/soju-image.service"
ln -sf "$SRC/systemd/soju-image.timer" "$unitdir/soju-image.timer"

systemctl --user daemon-reload
systemctl --user enable --now soju-image.timer
# A user timer runs only while the user is logged in, unless lingering is on:
#   sudo loginctl enable-linger "$USER"
systemctl --user list-timers soju-image.timer
