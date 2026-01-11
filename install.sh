#!/bin/bash

# ==============================================================================
# Dotfiles Installation Script
# 用于自动化部署配置文件到 macOS/Linux 系统
# ==============================================================================

set -e # 遇到错误立即退出

# 获取脚本所在目录的绝对路径 (作为软链接的源路径)
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 定义终端输出颜色
FMT_RED="\033[0;31m"
FMT_GREEN="\033[0;32m"
FMT_YELLOW="\033[0;33m"
FMT_BLUE="\033[0;34m"
FMT_RESET="\033[0m"

echo -e "${FMT_BLUE}[INFO] Dotfiles directory: $DOTFILES_DIR${FMT_RESET}"

# ==============================================================================
# 函数: link_file
# 参数: $1 = 仓库中的源文件名 (相对于仓库根目录)
#       $2 = 系统中的目标路径 (相对于 $HOME)
# ==============================================================================
link_file() {
    local source_file="$DOTFILES_DIR/$1"
    local target_file="$HOME/$2"

    # 1. 检查源文件是否存在
    if [ ! -f "$source_file" ]; then
        echo -e "${FMT_RED}[ERROR] Source file not found: $source_file${FMT_RESET}"
        return
    fi

    # 2. 检查目标是否已经是正确的软链接 (幂等性检查)
    if [ -L "$target_file" ] && [ "$(readlink "$target_file")" == "$source_file" ]; then
        echo -e "${FMT_GREEN}[SKIP] Already linked: $2${FMT_RESET}"
        return
    fi

    # 3. 如果目标存在 (文件或旧链接)，则备份
    if [ -f "$target_file" ] || [ -L "$target_file" ]; then
        echo -e "${FMT_YELLOW}[BACKUP] Backing up existing $2 to $2.backup${FMT_RESET}"
        mv "$target_file" "${target_file}.backup"
    fi

    # 4. 建立软链接
    ln -sf "$source_file" "$target_file"
    echo -e "${FMT_GREEN}[SUCCESS] Linked $1 -> $2${FMT_RESET}"
}

# ==============================================================================
# 配置清单 (Manifest)
#在此处添加需要部署的文件
# ==============================================================================

echo "---------------------------------------------------"
echo "🚀 Starting installation..."
echo "---------------------------------------------------"

# Vim 配置
link_file "vimrc" ".vimrc"

# [示例] Git 配置 (取消注释以启用)
# link_file "gitconfig" ".gitconfig"

# [示例] Zsh 配置
# link_file "zshrc" ".zshrc"

echo "---------------------------------------------------"
echo -e "${FMT_GREEN}✅ Installation complete.${FMT_RESET}"
