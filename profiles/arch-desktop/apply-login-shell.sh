#!/usr/bin/env bash
set -euo pipefail

target_user="${1:-$(id -un)}"
fish_path="$(command -v fish)"
log_file="$HOME/dotfiles-login-shell.log"

exec > >(tee "$log_file") 2>&1

echo "Target user: $target_user"
echo "Fish path: $fish_path"
echo "Current entry:"
getent passwd "$target_user" | cut -d: -f1,7

grep -qxF "$fish_path" /etc/shells || {
    echo "ERROR: $fish_path is not registered in /etc/shells" >&2
    exit 1
}

sudo usermod --shell "$fish_path" "$target_user"

actual_shell="$(getent passwd "$target_user" | cut -d: -f7)"
if [ "$actual_shell" != "$fish_path" ]; then
    echo "ERROR: expected $fish_path, got $actual_shell" >&2
    exit 1
fi

echo "Updated entry:"
getent passwd "$target_user" | cut -d: -f1,7
echo "SUCCESS: log out and back in to refresh the login environment."
echo "Log: $log_file"
