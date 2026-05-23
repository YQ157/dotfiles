<#
.SYNOPSIS
    Dotfiles Installation Script for Windows
.DESCRIPTION
    自动化创建配置文件的符号链接 (Symbolic Links)。
    注意：此脚本需要以管理员身份运行。
#>

$ErrorActionPreference = "Stop"

# 获取脚本当前所在目录
$DotfilesDir = PSScriptRoot

Write-Host "[INFO] Dotfiles directory: $DotfilesDir" -ForegroundColor Cyan

# ==============================================================================
# 函数: New-SymLink
# 参数: Source = 仓库中的源文件名
#       Dest   = 系统中的目标路径 (相对于用户主目录)
# ==============================================================================
function New-SymLink {
    param (
        [string]$Source,
        [string]$Dest
    )

    $SourcePath = Join-Path $DotfilesDir $Source
    $DestPath = Join-Path $HOME $Dest

    # 1. 检查源文件是否存在
    if (-not (Test-Path $SourcePath)) {
        Write-Host "[ERROR] Source file not found: $Source" -ForegroundColor Red
        return
    }

    # 2. 检查目标是否存在
    if (Test-Path $DestPath) {
        # 简单策略：如果目标存在，先备份 (重命名)
        Write-Host "[BACKUP] Backing up existing $Dest..." -ForegroundColor Yellow
        Move-Item -Path $DestPath -Destination "$DestPath.backup" -Force
    }

    # 3. 创建符号链接
    try {
        New-Item -ItemType SymbolicLink -Path $DestPath -Target $SourcePath | Out-Null
        Write-Host "[SUCCESS] Linked $Source -> $Dest" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to link $Dest. Please run PowerShell as Administrator." -ForegroundColor Red
    }
}

# ==============================================================================
# 函数: Add-ProfileSource
# 向 PowerShell Profile 追加 dot-source 行
# 参数: $SourceLine = 要追加的行
# ==============================================================================
function Add-ProfileSource {
    param (
        [string]$SourceLine
    )

    $ProfileDir = Split-Path $PROFILE -Parent
    $Marker = "# Added by dotfiles (source shell functions)"

    # 确保 Profile 目录存在
    if (-not (Test-Path $ProfileDir)) {
        Write-Host "[INFO] Creating profile directory: $ProfileDir" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    }

    # 确保 Profile 文件存在
    if (-not (Test-Path $PROFILE)) {
        Write-Host "[INFO] Creating profile: $PROFILE" -ForegroundColor Yellow
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }

    # 检查 dot-source 行是否已存在
    if (Select-String -Path $PROFILE -Pattern [regex]::Escape($SourceLine) -SimpleMatch -ErrorAction SilentlyContinue) {
        Write-Host "[SKIP] Dot-source line already in profile" -ForegroundColor Green
        return
    }

    # 追加标记注释 + dot-source 行
    Add-Content -Path $PROFILE -Value "`n$Marker`n$SourceLine"
    Write-Host "[SUCCESS] Added dot-source line to profile" -ForegroundColor Green
}

# ==============================================================================
# 配置清单 (Manifest)
# ==============================================================================

Write-Host "`n🚀 Starting installation...`n"

# Vim 配置 (Windows 下通常为 _vimrc)
New-SymLink "vimrc" "_vimrc"

# Shell 函数
New-SymLink "shell_functions.ps1" ".dotfiles_functions.ps1"
Add-ProfileSource '. "$HOME/.dotfiles_functions.ps1"'

# [示例] Git 配置
# New-SymLink "gitconfig" ".gitconfig"

# [示例] PowerShell Profile
# New-SymLink "Microsoft.PowerShell_profile.ps1" "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

Write-Host "`n✅ Installation complete." -ForegroundColor Green
