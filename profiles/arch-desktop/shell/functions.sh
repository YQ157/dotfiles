# ============================================================
# Dotfiles Shell Functions (Arch desktop bash / zsh)
# ============================================================

# --- 共享代理配置 ---
_dotfiles_proxy_config="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/proxy.conf"
if [ -r "$_dotfiles_proxy_config" ]; then
    # shellcheck disable=SC1090
    . "$_dotfiles_proxy_config"
fi
: "${PROXY_HTTP_URL:=http://127.0.0.1:7897}"
: "${PROXY_SOCKS_URL:=socks5h://127.0.0.1:7897}"
: "${PROXY_PORT:=7897}"
: "${SSH_REVERSE_PORT:=17890}"
unset _dotfiles_proxy_config

# --- Clash Verge 代理开关 ---
proxy_on() {
    export http_proxy="$PROXY_HTTP_URL"
    export https_proxy="$PROXY_HTTP_URL"
    export all_proxy="$PROXY_SOCKS_URL"
    export HTTP_PROXY="$PROXY_HTTP_URL"
    export HTTPS_PROXY="$PROXY_HTTP_URL"
    export ALL_PROXY="$PROXY_SOCKS_URL"

    git config --global http.proxy "$PROXY_HTTP_URL"
    git config --global https.proxy "$PROXY_HTTP_URL"
    [ "${1:-}" = "--quiet" ] || echo "🚀 代理已开启 -> ${PROXY_HTTP_URL#*://}"
}

proxy_off() {
    unset http_proxy https_proxy all_proxy
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
    git config --global --unset-all http.proxy 2>/dev/null || true
    git config --global --unset-all https.proxy 2>/dev/null || true
    echo "🛑 代理已关闭"
}

proxy_status() {
    if [ -n "${http_proxy:-}" ]; then
        echo "Terminal HTTP: $http_proxy"
        echo "Terminal SOCKS: ${all_proxy:-}"
    else
        echo "Terminal proxy: OFF"
    fi
    local git_proxy
    git_proxy="$(git config --global --get-all http.proxy 2>/dev/null || true)"
    [ -n "$git_proxy" ] && echo "Git HTTP: $git_proxy" || echo "Git proxy: OFF"
}

# --- SSH 反向转发 ---
sshr() {
    local port=22

    if [[ "${1:-}" == "-p" || "${1:-}" == "--port" ]]; then
        [ -n "${2:-}" ] || {
            echo "用法: sshr [-p SSH端口] user@IP"
            return 1
        }
        port="$2"
        shift 2
    fi

    local target="${1:-}"

    if [[ -z "$target" ]]; then
        echo "用法: sshr [-p SSH端口] user@IP"
        return 1
    fi

    ssh -NT -p "$port" \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -o ExitOnForwardFailure=yes \
        -R "$SSH_REVERSE_PORT:127.0.0.1:$PROXY_PORT" \
        "$target"
}

proxy_on --quiet
