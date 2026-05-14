# Dotfiles

自用 dotfiles，跨平台配置管理 (macOS / Linux / Windows)。

## 📂 目录结构

| 文件 / 目录 | 说明 |
| :--- | :--- |
| `vimrc` | 本地 Vim 配置 (macOS)，含剪贴板同步、F5 编译运行、算法模板、竞赛辅助等功能 |
| `vimrc-linux` | 服务器 Vim 配置 (Linux)，精简版，去除了 GUI/平台相关功能 |
| `templates/` | 代码模板 (C++ 算法模板) |
| `install.sh` | **macOS / Linux** 自动安装脚本，自动检测系统选择对应 vimrc |
| `install.ps1` | **Windows** 自动安装脚本 (PowerShell) |
| `.gitignore` | Git 忽略规则 |

## 🚀 安装

### macOS / Linux

```bash
git clone https://github.com/YQ157/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

`install.sh` 会自动检测操作系统：macOS 使用 `vimrc`，Linux 使用 `vimrc-linux`。

### Windows

以管理员身份运行 PowerShell：

```powershell
git clone https://github.com/YQ157/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
.\install.ps1
```

## 📝 使用

### 本地 (vimrc)

* **代码模板**：新建 `.cpp` 文件自动加载 `templates/algorithm.cpp`
* **编译运行**：`<F5>` 一键编译运行 C++/Python
* **竞赛辅助**：`<Leader>n` 在比赛目录下按题号新建文件，`<Leader>t` 切换 `cin>>t;` 注释
* **剪贴板同步**：Vim 与系统剪贴板互通

### 服务器 (vimrc-linux)

精简配置，仅保留基础编辑增强（行号、缩进、搜索高亮、Leader 快捷键、jk 快速 Esc），无平台依赖功能。

## 🔧 扩展

`install.sh` / `install.ps1` 是通用的 dotfiles 部署框架。在 Manifest 区域注册新文件即可自动处理备份和符号链接，例如：

```bash
# .gitconfig、.zshrc、.tmux.conf 等
link_file "gitconfig" ".gitconfig"
```
