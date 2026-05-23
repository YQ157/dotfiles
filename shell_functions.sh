# ============================================================
# Dotfiles Shell Functions (bash / zsh)
# ============================================================

# --- 代理开关 (根据 OS 选择不同实现) ---
case "$(uname -s)" in
    Darwin*)
        proxy_on() {
            export http_proxy="http://127.0.0.1:7897"
            export https_proxy="http://127.0.0.1:7897"
            export all_proxy="socks5://127.0.0.1:7897"
            git config --global http.proxy "http://127.0.0.1:7897"
            git config --global https.proxy "http://127.0.0.1:7897"
            echo -e "\033[32m[√] Terminal Proxy is ON (Port: 7897)\033[0m"
        }

        proxy_off() {
            unset http_proxy
            unset https_proxy
            unset all_proxy
            git config --global --unset http.proxy 2>/dev/null
            git config --global --unset https.proxy 2>/dev/null
            echo -e "\033[31m[x] Terminal Proxy is OFF\033[0m"
        }
        ;;
    Linux*)
        proxy_on() {
            export http_proxy=http://127.0.0.1:17890
            export https_proxy=http://127.0.0.1:17890
            export GIT_SSH_COMMAND='ssh -o ProxyCommand="nc -X connect -x 127.0.0.1:17890 %h %p"'
            echo "🚀 代理已开启 (HTTP + SSH) -> Port: 17890"
        }

        proxy_off() {
            unset http_proxy
            unset https_proxy
            unset GIT_SSH_COMMAND
            echo "🛑 代理已关闭"
        }
        ;;
esac

# --- SSH 反向转发 ---
sshr() {
    local port=22

    if [[ "$1" == "-p" || "$1" == "--port" ]]; then
        port="$2"
        shift 2
    fi

    local target="$1"

    if [[ -z "$target" ]]; then
        echo "用法: sshr [-p SSH端口] user@IP"
        return 1
    fi

    ssh -NT -p "$port" \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -o ExitOnForwardFailure=yes \
        -R 17890:127.0.0.1:7897 \
        "$target"
}
