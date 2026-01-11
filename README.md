# Dotfiles

Cross-platform configuration files and development environment setup (macOS, Linux, Windows).

## 📂 Repository Structure

| File / Directory | Description |
| :--- | :--- |
| `vimrc` | Core Vim configuration (Cross-platform compatible). |
| `templates/` | Source code templates (e.g., C++ algorithm templates). |
| `install.sh` | **macOS / Linux** automated bootstrap script. |
| `install.ps1` | **Windows** automated bootstrap script (PowerShell). |
| `.gitignore` | Git ignore rules |

## 🚀 Installation

### macOS / Linux

Execute the following commands in your terminal. This will clone the repository to `~/dotfiles` and create symbolic links.

```bash
# 1. Clone repository to a fixed location (~/dotfiles)
git clone https://github.com/YQ157/dotfiles.git ~/dotfiles

# 2. Run the bootstrap script
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

### Windows

Run PowerShell as Administrator and execute:

```Powershell
# 1. Clone repository to a fixed location ($HOME\dotfiles)
git clone https://github.com/YQ157/dotfiles.git $HOME\dotfiles

# 2. Run the bootstrap script
cd $HOME\dotfiles
.\install.ps1
```

## 📝 Usage

* Vim Templates: Creating a new `.cpp` file will automatically load the algorithm template from `templates/algorithm.cpp`.
* Compile & Run: Press `<F5>` in Vim to compile and run C++/Python files.

## 🔧 Extensibility
The bootstrap scripts are designed as a generic dotfiles framework. To manage additional configuration files (e.g., `.gitconfig`, `.zshrc`, `.tmux.conf`), simply register them in the Manifest section of `install.sh` (or `install.ps1`). The scripts will automatically handle backup and symlinking.
