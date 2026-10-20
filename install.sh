#!/bin/bash
# Installs the systemd user units and starts the daily timer.
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p ~/.config/systemd/user
for unit in soju-image.service soju-image.timer; do
  ln -sf "$PWD/systemd/$unit" ~/.config/systemd/user/"$unit"
done

systemctl --user daemon-reload
systemctl --user enable --now soju-image.timer
# A user timer runs only while the user is logged in, unless lingering is on:
#   sudo loginctl enable-linger "$USER"
systemctl --user list-timers soju-image.timer
