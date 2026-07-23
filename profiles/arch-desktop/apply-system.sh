#!/usr/bin/env bash
set -euo pipefail

profile_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_file="${1:-$HOME/dotfiles-system-install.log}"

exec > >(tee -a "$log_file") 2>&1
echo "[$(date --iso-8601=seconds)] Applying Arch desktop system configuration"

sudo install -Dm644 \
    "$profile_dir/system/logind.conf.d/90-caelestia-no-lid-suspend.conf" \
    /etc/systemd/logind.conf.d/90-caelestia-no-lid-suspend.conf
sudo install -Dm644 \
    "$profile_dir/system/sddm.conf.d/20-caelestia-numlock.conf" \
    /etc/sddm.conf.d/20-caelestia-numlock.conf

echo "Installed:"
echo "  /etc/systemd/logind.conf.d/90-caelestia-no-lid-suspend.conf"
echo "  /etc/sddm.conf.d/20-caelestia-numlock.conf"
echo "A reboot applies both settings safely."
echo "Log: $log_file"
