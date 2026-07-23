# macOS shell functions (zsh/bash).

_dotfiles_proxy_config="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/proxy.conf"
if [ -r "$_dotfiles_proxy_config" ]; then
    # shellcheck disable=SC1090
    . "$_dotfiles_proxy_config"
fi
: "${PROXY_HTTP_URL:=http://127.0.0.1:7897}"
: "${PROXY_SOCKS_URL:=socks5://127.0.0.1:7897}"
: "${PROXY_PORT:=7897}"
: "${SSH_REVERSE_PORT:=17890}"
unset _dotfiles_proxy_config

proxy_on() {
    export http_proxy="$PROXY_HTTP_URL"
    export https_proxy="$PROXY_HTTP_URL"
    export all_proxy="$PROXY_SOCKS_URL"
    git config --global http.proxy "$PROXY_HTTP_URL"
    git config --global https.proxy "$PROXY_HTTP_URL"
    [ "${1:-}" = "--quiet" ] || printf '\033[32m[√] Terminal Proxy is ON (%s)\033[0m\n' "${PROXY_HTTP_URL#*://}"
}

proxy_off() {
    unset http_proxy https_proxy all_proxy
    git config --global --unset-all http.proxy 2>/dev/null || true
    git config --global --unset-all https.proxy 2>/dev/null || true
    printf '\033[31m[x] Terminal Proxy is OFF\033[0m\n'
}

proxy_status() {
    [ -n "${http_proxy:-}" ] && echo "Terminal HTTP: $http_proxy" || echo "Terminal proxy: OFF"
}

sshr() {
    local port=22
    if [ "${1:-}" = "-p" ] || [ "${1:-}" = "--port" ]; then
        [ -n "${2:-}" ] || {
            echo "用法: sshr [-p SSH端口] user@IP"
            return 1
        }
        port="$2"
        shift 2
    fi
    if [ -z "${1:-}" ]; then
        echo "用法: sshr [-p SSH端口] user@IP"
        return 1
    fi
    ssh -NT -p "$port" \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -o ExitOnForwardFailure=yes \
        -R "$SSH_REVERSE_PORT:127.0.0.1:$PROXY_PORT" \
        "$1"
}
