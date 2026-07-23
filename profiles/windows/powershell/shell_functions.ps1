# ============================================================
# Dotfiles Shell Functions (Windows PowerShell)
# ============================================================

# --- 代理开关 ---
function proxy_on {
    $env:http_proxy = "http://127.0.0.1:7897"
    $env:https_proxy = "http://127.0.0.1:7897"
    $env:all_proxy = "socks5://127.0.0.1:7897"
    git config --global http.proxy "http://127.0.0.1:7897"
    git config --global https.proxy "http://127.0.0.1:7897"
    Write-Host "[√] Terminal Proxy is ON (Port: 7897)" -ForegroundColor Green
}

function proxy_off {
    Remove-Item Env:http_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:https_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:all_proxy -ErrorAction SilentlyContinue
    git config --global --unset http.proxy 2>$null
    git config --global --unset https.proxy 2>$null
    Write-Host "[x] Terminal Proxy is OFF" -ForegroundColor Red
}

# --- SSH 反向转发 ---
function sshr {
    param(
        [int]$Port = 22,
        [Parameter(Mandatory=$false, Position=0)]
        [string]$Target
    )

    if (-not $Target) {
        Write-Host "用法: sshr [-Port SSH端口] user@IP"
        return
    }

    ssh -NT -p $Port `
        -o ServerAliveInterval=30 `
        -o ServerAliveCountMax=3 `
        -o ExitOnForwardFailure=yes `
        -R 17890:127.0.0.1:7897 `
        $Target
}
