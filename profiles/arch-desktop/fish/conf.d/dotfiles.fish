# Dotfiles integration for Fish on an Arch graphical workstation.
# This file is deployed by install.sh; keep machine-wide shell customisations here.

fish_add_path --global --move $HOME/.local/npm/bin

function __dotfiles_proxy_value --argument-names wanted
    set -l config $HOME/.config/dotfiles/proxy.conf
    test -r $config; or return 1

    while read -l line
        string match -qr '^[A-Z_]+=' -- $line; or continue
        set -l pair (string split -m 1 = -- $line)
        if test "$pair[1]" = "$wanted"
            printf '%s\n' $pair[2]
            return 0
        end
    end <$config
    return 1
end

function proxy_on --description 'Enable terminal and Git HTTP proxy'
    set -l proxy_url (__dotfiles_proxy_value PROXY_HTTP_URL)
    set -l socks_url (__dotfiles_proxy_value PROXY_SOCKS_URL)
    if test -z "$proxy_url" -o -z "$socks_url"
        echo "proxy_on: cannot read ~/.config/dotfiles/proxy.conf" >&2
        return 1
    end

    set -gx http_proxy $proxy_url
    set -gx https_proxy $proxy_url
    set -gx all_proxy $socks_url
    set -gx HTTP_PROXY $proxy_url
    set -gx HTTPS_PROXY $proxy_url
    set -gx ALL_PROXY $socks_url

    command git config --global http.proxy $proxy_url
    command git config --global https.proxy $proxy_url
    if not contains -- --quiet $argv
        echo "🚀 代理已开启 -> "(string replace -r '^.*://' '' $proxy_url)
    end
end

function proxy_off --description 'Disable terminal and Git HTTP proxy'
    set -e http_proxy https_proxy all_proxy
    set -e HTTP_PROXY HTTPS_PROXY ALL_PROXY
    command git config --global --unset-all http.proxy 2>/dev/null; or true
    command git config --global --unset-all https.proxy 2>/dev/null; or true
    echo "🛑 代理已关闭"
end

function proxy_status --description 'Show terminal and Git proxy state'
    if set -q http_proxy
        echo "Terminal HTTP: $http_proxy"
        echo "Terminal SOCKS: $all_proxy"
    else
        echo "Terminal proxy: OFF"
    end
    set -l git_proxy (command git config --global --get-all http.proxy)
    test -n "$git_proxy"; and echo "Git HTTP: $git_proxy"; or echo "Git proxy: OFF"
end

function sshr --description 'Open an SSH reverse proxy: sshr [-p port] user@host'
    set -l port 22
    if test (count $argv) -ge 2; and contains -- $argv[1] -p --port
        set port $argv[2]
        set -e argv[1..2]
    end
    if test (count $argv) -ne 1
        echo "用法: sshr [-p SSH端口] user@IP" >&2
        return 1
    end

    set -l local_port (__dotfiles_proxy_value PROXY_PORT)
    set -l reverse_port (__dotfiles_proxy_value SSH_REVERSE_PORT)
    if test -z "$local_port" -o -z "$reverse_port"
        echo "sshr: cannot read ~/.config/dotfiles/proxy.conf" >&2
        return 1
    end

    command ssh -NT -p $port \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -o ExitOnForwardFailure=yes \
        -R $reverse_port:127.0.0.1:$local_port \
        $argv[1]
end

if status is-interactive
    alias grep='grep --color=auto'
    proxy_on --quiet
end
