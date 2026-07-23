# Linux server shell functions.
# The server reaches the desktop proxy through sshr's reverse port.

proxy_on() {
    export http_proxy="http://127.0.0.1:17890"
    export https_proxy="http://127.0.0.1:17890"
    export GIT_SSH_COMMAND='ssh -o ProxyCommand="nc -X connect -x 127.0.0.1:17890 %h %p"'
    echo "🚀 代理已开启 (HTTP + SSH) -> Port: 17890"
}

proxy_off() {
    unset http_proxy https_proxy GIT_SSH_COMMAND
    echo "🛑 代理已关闭"
}

proxy_status() {
    if [ -n "${http_proxy:-}" ]; then
        echo "Server HTTP: $http_proxy"
        echo "Git SSH: ${GIT_SSH_COMMAND:-direct}"
    else
        echo "Server proxy: OFF"
    fi
}
