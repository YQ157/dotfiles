#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE=""
HOST_NAME=""
DRY_RUN=false

usage() {
    cat <<'EOF'
Usage:
  ./install.sh --profile arch-desktop --host legion [--dry-run]
  ./install.sh --profile linux-server [--dry-run]
  ./install.sh --profile macos [--dry-run]

Profiles are explicit by design; a graphical workstation is never treated as
a generic Linux server. Windows uses install.ps1.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --profile) PROFILE="${2:-}"; shift 2 ;;
        --host) HOST_NAME="${2:-}"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

case "$PROFILE" in
    arch-desktop)
        [ "$(uname -s)" = Linux ] || {
            echo "arch-desktop requires Linux" >&2
            exit 1
        }
        [ -n "$HOST_NAME" ] || {
            echo "arch-desktop requires --host (currently: legion)" >&2
            exit 1
        }
        [ -d "$DOTFILES_DIR/hosts/$HOST_NAME" ] || {
            echo "Unknown host: $HOST_NAME" >&2
            exit 1
        }
        ;;
    linux-server)
        [ "$(uname -s)" = Linux ] || {
            echo "linux-server requires Linux" >&2
            exit 1
        }
        ;;
    macos)
        [ "$(uname -s)" = Darwin ] || {
            echo "macos requires Darwin" >&2
            exit 1
        }
        ;;
    "") echo "Missing --profile" >&2; usage >&2; exit 2 ;;
    *) echo "Unknown profile: $PROFILE" >&2; usage >&2; exit 2 ;;
esac

backup_path() {
    local target="$1"
    local stamp backup
    stamp="$(date +%Y%m%d-%H%M%S)"
    backup="${target}.backup.${stamp}"
    while [ -e "$backup" ] || [ -L "$backup" ]; do
        backup="${backup}.1"
    done
    printf '%s\n' "$backup"
}

link_file() {
    local source_file="$DOTFILES_DIR/$1"
    local target_file="$HOME/$2"
    local backup

    [ -f "$source_file" ] || {
        echo "[ERROR] Missing source: $1" >&2
        exit 1
    }
    if [ -L "$target_file" ] && [ "$(readlink -f "$target_file")" = "$(readlink -f "$source_file")" ]; then
        echo "[SKIP] $2"
        return
    fi
    echo "[LINK] $2 <- $1"
    $DRY_RUN && return
    mkdir -p "$(dirname "$target_file")"
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        backup="$(backup_path "$target_file")"
        mv "$target_file" "$backup"
        echo "       backup: ${backup#$HOME/}"
    fi
    ln -s "$source_file" "$target_file"
}

inject_source_line() {
    local rc_file="$HOME/$1"
    local source_line='[ -f ~/.dotfiles_functions.sh ] && source ~/.dotfiles_functions.sh'
    if [ -f "$rc_file" ] && grep -qF "$source_line" "$rc_file"; then
        echo "[SKIP] source line in $1"
        return
    fi
    echo "[EDIT] add dotfiles source to $1"
    $DRY_RUN && return
    mkdir -p "$(dirname "$rc_file")"
    touch "$rc_file"
    printf '\n%s\n%s\n' '# Added by dotfiles (source shell functions)' "$source_line" >>"$rc_file"
}

enable_user_unit() {
    local unit="$1"
    local wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
    echo "[ENABLE] $unit for graphical-session.target"
    $DRY_RUN && return
    mkdir -p "$wants_dir"
    ln -sfn "../$unit" "$wants_dir/$unit"
}

echo "Dotfiles profile: $PROFILE${HOST_NAME:+ ($HOST_NAME)}"

case "$PROFILE" in
    arch-desktop)
        link_file "profiles/arch-desktop/vim/vimrc" ".vimrc"
        link_file "profiles/arch-desktop/shell/functions.sh" ".dotfiles_functions.sh"
        link_file "profiles/arch-desktop/shell/proxy.conf" ".config/dotfiles/proxy.conf"
        link_file "profiles/arch-desktop/fish/conf.d/dotfiles.fish" ".config/fish/conf.d/dotfiles.fish"
        link_file "profiles/arch-desktop/foot/foot.ini" ".config/foot/foot.ini"
        link_file "profiles/arch-desktop/caelestia/hypr-vars.lua" ".config/caelestia/hypr-vars.lua"
        link_file "profiles/arch-desktop/caelestia/shell.json" ".config/caelestia/shell.json"
        link_file "profiles/arch-desktop/caelestia/user-config.fish" ".config/caelestia/user-config.fish"
        link_file "hosts/$HOST_NAME/caelestia/hypr-user.lua" ".config/caelestia/hypr-user.lua"
        link_file "profiles/arch-desktop/systemd/user/clash-verge.service" ".config/systemd/user/clash-verge.service"
        link_file "profiles/arch-desktop/systemd/user/fcitx5-hyprland.service" ".config/systemd/user/fcitx5-hyprland.service"
        link_file "profiles/arch-desktop/systemd/user/hyprland-session.target" ".config/systemd/user/hyprland-session.target"
        inject_source_line ".bashrc"
        enable_user_unit "clash-verge.service"
        enable_user_unit "fcitx5-hyprland.service"
        ;;
    linux-server)
        link_file "profiles/linux-server/vim/vimrc" ".vimrc"
        link_file "profiles/linux-server/shell/functions.sh" ".dotfiles_functions.sh"
        inject_source_line ".bashrc"
        ;;
    macos)
        link_file "profiles/macos/vim/vimrc" ".vimrc"
        link_file "profiles/macos/shell/functions.sh" ".dotfiles_functions.sh"
        link_file "profiles/macos/shell/proxy.conf" ".config/dotfiles/proxy.conf"
        inject_source_line ".zshrc"
        ;;
esac

if ! $DRY_RUN; then
    mkdir -p "$HOME/.config/dotfiles"
    printf '%s\n' "$PROFILE${HOST_NAME:+:$HOST_NAME}" >"$HOME/.config/dotfiles/active-profile"
fi

echo "Done."
if [ "$PROFILE" = arch-desktop ]; then
    echo "System-level source files are tracked but not applied automatically."
    echo "Run profiles/arch-desktop/apply-system.sh when they need to be installed."
fi
