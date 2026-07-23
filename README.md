# Personal dotfiles

这不是某一台机器的快照，而是一套按设备角色组织的个人使用习惯。

## 结构

```text
common/                       跨平台共享资源
  templates/                  代码模板
  vim/                        跨平台 Vim 使用习惯
profiles/
  arch-desktop/               Arch 图形工作站
    caelestia/                 Caelestia 用户覆盖
    fish/                     Fish 函数与 PATH
    foot/                     Foot
    shell/                    Bash 与代理配置
    systemd/user/             用户会话服务
    system/                   需要管理员安装的系统配置源
    packages.txt              文档用途的软件清单
  linux-server/               SSH Linux 服务器
  macos/                      macOS
  windows/                    Windows PowerShell
hosts/
  legion/                     当前笔记本的硬件相关覆盖
install.sh                    Linux/macOS Profile 安装器
install.ps1                   Windows 安装器
```

### 分层原则

- `common`：真正跨平台且语义一致的资源。
- `profiles`：某类设备需要的配置。Arch 桌面与 Linux 服务器严格分开。
- `hosts`：显示器名称、分辨率等硬件绑定信息。
- 天气定位、缓存、登录状态、密钥和令牌不进入仓库。
- 壁纸图片不进入仓库；放在 `~/Pictures/Wallpapers`，由 Caelestia 索引。
- 配置以软链接部署，仓库是唯一维护源。

## 安装

安装器必须显式选择 Profile，避免把桌面配置部署到服务器。

### 当前 Arch 桌面

```bash
./install.sh --profile arch-desktop --host legion
```

首次部署时，将桌面用户的登录 Shell 正式设为 Fish：

```bash
./profiles/arch-desktop/apply-login-shell.sh
```

脚本验证 `/etc/shells` 后通过 sudo 修改账户记录，并将结果写入
`~/dotfiles-login-shell.log`。root 与 Linux Server Profile 不受影响。

预览而不修改：

```bash
./install.sh --profile arch-desktop --host legion --dry-run
```

系统级配置不会被普通安装器隐式修改。需要安装合盖策略和 SDDM
Num Lock 时，单独运行：

```bash
./profiles/arch-desktop/apply-system.sh
```

脚本会通过 `sudo install` 写入 `/etc`，并在
`~/dotfiles-system-install.log` 留下可读日志。

### Linux SSH 服务器

```bash
./install.sh --profile linux-server
```

服务器 Profile 保留反向代理语义：桌面运行 `sshr user@server` 后，
服务器上的 `proxy_on` 使用 `127.0.0.1:17890`。

### macOS

```bash
./install.sh --profile macos
```

macOS 使用完整 Vim 配置、Zsh/Bash Shell 函数及本机 `7897` 代理。

### Windows

在 PowerShell 中运行：

```powershell
.\install.ps1
```

## Arch 桌面维护边界

仓库当前维护：

- Caelestia 的应用选择、锁屏通知、空闲策略、24 小时制和摄氏度；
- Vim 的共享快捷键、模板、便携 F5 编译，以及 Arch/Foot 平台适配；
- 当前 `legion` 的显示器布局、Fcitx 环境、Num Lock、手势和合盖显示行为；
- Foot、Fish、`codex` PATH、代理函数与 `sshr`；
- `graphical-session.target` 下的 Clash Verge 和 Fcitx5；
- Hyprland session target；
- `/etc` 中合盖不休眠与 SDDM Num Lock 的配置源。

仓库不维护：

- Caelestia 上游生成的默认文件；
- 天气位置（使用自动 IP 定位）；
- Clash 配置、浏览器账户、VS Code 登录状态；
- 锁屏贡献图实验和已停用的 Walker/Elephant/SwayOSD；
- 缓存、历史、令牌、密钥及其他运行时状态。

## 常用 Shell 命令

Arch 桌面和 macOS：

```text
proxy_on       开启当前终端和 Git HTTP 代理
proxy_off      关闭当前终端和 Git HTTP 代理
proxy_status   显示代理状态
sshr           建立到 Linux 服务器的反向代理
```

代理端口只在各 Profile 的 `shell/proxy.conf` 中维护。

Arch 桌面 Profile 以 Fish 作为用户登录 Shell；root 和 Linux Server
Profile 仍使用 Bash。使用 `su` 后应通过 `exit`/`Ctrl+D` 逐层返回，
不要用再次 `su xun` 代替返回。

## 修改流程

1. 修改仓库内对应的 Profile 或 Host 文件。
2. 执行安装器；已正确链接的文件会显示 `[SKIP]`。
3. 用新终端或重新登录验证。
4. 检查 `git diff`，确认没有账户、密钥或运行时状态后再提交。

替换已有配置时，安装器会创建带时间戳的备份，不会静默覆盖普通文件。
