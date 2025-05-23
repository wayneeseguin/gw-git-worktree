# gw Installation Guide

Complete installation instructions for `gw` (Git Worktree Switcher) across different platforms and environments.

## Table of Contents

1. [Quick Install](#quick-install)
2. [System Requirements](#system-requirements)
3. [Installation Methods](#installation-methods)
4. [Shell Integration Setup](#shell-integration-setup)
5. [Completion Setup](#completion-setup)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)
8. [Uninstallation](#uninstallation)

## Quick Install

For most users, the automated installer will handle everything:

```bash
# Clone repository and run installer
git clone https://github.com/yankeexe/git-worktree-switcher.git
cd git-worktree-switcher
sudo bin/install
```

This will:
- Install `gw` to `/usr/local/bin/`
- Install shell completions for bash, zsh, and fish
- Update shell RC files with completion configuration

## System Requirements

### Required
- **Perl 5.20+** (pre-installed on most Unix systems)
- **Git 2.5+** with worktree support
- **Unix-like OS** (Linux, macOS, WSL)

### Optional
- **jq** - For self-updating functionality
- **bash/zsh/fish** - For shell completion

### Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Linux | ✅ Fully Supported | All distributions |
| macOS | ✅ Fully Supported | Intel and Apple Silicon |
| Windows WSL | ✅ Fully Supported | WSL 1 and WSL 2 |
| Windows (native) | ❌ Not Supported | Use WSL instead |
| FreeBSD | ✅ Should Work | Community tested |

## Installation Methods

### Method 1: Automated Installer (Recommended)

```bash
# Clone repository
git clone https://github.com/yankeexe/git-worktree-switcher.git
cd git-worktree-switcher

# Run automated installer
sudo bin/install

# Restart shell or source configuration
source ~/.bashrc  # or ~/.zshrc
```

The installer will:
- Copy `bin/gw` to `/usr/local/bin/gw`
- Install shell completions to system directories
- Configure shell RC files automatically

### Method 2: Manual Installation from Source

```bash
# Clone repository
git clone https://github.com/yankeexe/git-worktree-switcher.git
cd git-worktree-switcher

# Install binary manually
sudo cp bin/gw /usr/local/bin/

# Install completions manually
sudo cp completions/bash/gw /usr/local/share/bash-completion/completions/
sudo cp completions/zsh/gw /usr/local/share/zsh/site-functions/_gw
sudo cp completions/fish/gw /usr/local/share/fish/vendor_completions.d/gw.fish

# Or create symlink for development
sudo ln -sf "$(pwd)/bin/gw" /usr/local/bin/gw
```

### Method 3: Package Managers

#### Homebrew (macOS/Linux)
```bash
# Coming soon
brew install gw
```

#### Package Manager Installation Scripts

Create custom installation for your package manager:

**Debian/Ubuntu (.deb)**
```bash
# Create package structure
mkdir -p gw-package/usr/local/bin
cp gw gw-package/usr/local/bin/
# Create .deb package (advanced)
```

### Method 4: Download Binary Only

1. Download the `gw` script from the repository
2. Place it in your PATH
3. Make it executable

```bash
# Download from repository
wget https://raw.githubusercontent.com/yankeexe/git-worktree-switcher/main/bin/gw

# Or with curl
curl -O https://raw.githubusercontent.com/yankeexe/git-worktree-switcher/main/bin/gw

# Install
chmod +x gw
sudo mv gw /usr/local/bin/
```

## Shell Integration Setup

Shell integration is **highly recommended** for the best experience. It enables directory switching within your current shell session.

### Automatic Setup

```bash
# For bash
echo 'eval "$(gw shell)"' >> ~/.bashrc
source ~/.bashrc

# For zsh  
echo 'eval "$(gw shell)"' >> ~/.zshrc
source ~/.zshrc

# For fish
echo 'gw shell | source' >> ~/.config/fish/config.fish
```

### Manual Setup

If you prefer to add it manually to your shell configuration:

**~/.bashrc or ~/.zshrc**
```bash
# Git Worktree Switcher integration
if command -v gw >/dev/null 2>&1; then
    eval "$(gw shell)"
fi
```

**~/.config/fish/config.fish**
```fish
# Git Worktree Switcher integration  
if command -q gw
    gw shell | source
end
```

### Verification

```bash
# Check if shell function is loaded
type gw
# Should output: "gw is a function" (not "gw is /usr/local/bin/gw")

# Test switching (in a git repo with worktrees)
gw list                    # Should call the binary
gw some-worktree-name     # Should use cd (if worktree exists)
```

## Completion Setup

Shell completion provides tab completion for commands, flags, and worktree names.

### Bash Completion

#### System-wide Installation
```bash
sudo cp completions/bash/gw /etc/bash_completion.d/gw
```

#### User Installation
```bash
mkdir -p ~/.local/share/bash-completion/completions
cp completions/bash/gw ~/.local/share/bash-completion/completions/gw
```

#### Manual Loading
```bash
# Add to ~/.bashrc
source /path/to/completions/bash/gw
```

### Zsh Completion

#### Find Completion Directory
```bash
# Show completion directories
print -rl -- $fpath
```

#### Installation
```bash
# Copy to a directory in $fpath
sudo cp completions/zsh/gw /usr/local/share/zsh/site-functions/_gw

# Or for user only
mkdir -p ~/.local/share/zsh/site-functions  
cp completions/zsh/gw ~/.local/share/zsh/site-functions/_gw

# Add to fpath in ~/.zshrc if using user directory
fpath=(~/.local/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit
```

### Fish Completion

```bash
# Copy to fish completions directory
cp completions/fish/gw ~/.config/fish/completions/gw.fish
```

### Verification

```bash
# Test completion (type command + TAB)
gw <TAB>           # Should show subcommands
gw list <TAB>      # Should show flags
gw add <TAB>       # Should show file paths
```

## Verification

After installation, verify everything works correctly:

### Basic Functionality
```bash
# Check installation
which gw
# Should output: /usr/local/bin/gw (or your install path)

# Check version
gw version
# Should output: Version: X.Y.Z

# Check help
gw help
# Should display comprehensive help
```

### Shell Integration
```bash
# Check shell function
type gw  
# Should output: "gw is a function"

# Test in a git repository
cd /path/to/git/repo
gw list
# Should show worktrees if any exist
```

### Completion
```bash
# Test tab completion (if installed)
gw <TAB><TAB>      # Should show available commands
```

### Advanced Features
```bash
# Test shell detection
gw shell | head -5
# Should generate appropriate shell function

# Test update capability (requires jq)
gw update
# Should check for updates or show jq requirement
```

## Troubleshooting

### Common Installation Issues

#### "gw: command not found"
```bash
# Check if gw is in PATH
echo $PATH | grep -o '/usr/local/bin'

# If not found, add to PATH
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Or reinstall to a directory in PATH
which git  # Example of a command that works
sudo cp gw "$(dirname "$(which git)")"
```

#### "Permission denied"
```bash
# Make sure gw is executable
ls -l /usr/local/bin/gw
# Should show: -rwxr-xr-x

# Fix permissions if needed
sudo chmod +x /usr/local/bin/gw
```

#### "Bad interpreter: perl: no such file or directory"
```bash
# Check Perl installation
which perl
perl --version

# Install Perl if missing (Ubuntu/Debian)
sudo apt-get update && sudo apt-get install perl

# Install Perl if missing (macOS)
brew install perl
```

### Shell Integration Issues

#### Function Not Loading
```bash
# Check if shell integration is in config file
grep -n "gw shell" ~/.bashrc ~/.zshrc ~/.config/fish/config.fish

# Manually reload configuration
source ~/.bashrc  # or ~/.zshrc

# Test shell function generation
gw shell | head -10
```

#### Wrong Shell Detected
```bash
# Check current shell
echo $0
echo $SHELL

# Force specific shell function
gw shell | grep -A5 -B5 "function gw"
```

### Completion Issues

#### Completions Not Working
```bash
# For bash, check if completion is enabled
shopt | grep progcomp
# Should show: progcomp on

# Check if completion file is sourced
complete -p gw
# Should show completion function

# Reload completions
source /etc/bash_completion.d/gw  # or your completion file path
```

#### Slow Completions
```bash
# Test completion performance
time gw list >/dev/null
# Should complete in under 1 second

# If slow, check repository health
git worktree list  # Should be fast
git status        # Should be responsive
```

### Platform-Specific Issues

#### macOS: "Developer Tools" prompt
```bash
# Install Xcode Command Line Tools
xcode-select --install
```

#### WSL: Git worktree issues
```bash
# Ensure Git version supports worktrees
git --version
# Should be 2.5 or later

# Check WSL Git configuration
git config --global core.autocrlf false
```

### Getting Help

If you encounter issues not covered here:

1. **Check existing documentation**
   - [User Guide](user-guide.md)
   - [API Documentation](api.md)
   - [Development Guide](development.md)

2. **Run diagnostics**
   ```bash
   # System information
   uname -a
   perl --version
   git --version
   echo $SHELL
   
   # gw specific
   gw version
   gw help
   which gw
   ```

3. **Search GitHub Issues**
   - Check for similar problems
   - Create new issue with diagnostic information

## Uninstallation

### Remove Binary
```bash
sudo rm /usr/local/bin/gw
# Or: rm ~/bin/gw (if installed in user directory)
```

### Remove Shell Integration
```bash
# Remove from shell configuration files
sed -i '/gw shell/d' ~/.bashrc ~/.zshrc ~/.config/fish/config.fish
```

### Remove Completions
```bash
# Remove completion files
sudo rm /etc/bash_completion.d/gw
rm ~/.local/share/zsh/site-functions/_gw
rm ~/.config/fish/completions/gw.fish
```

### Verify Removal
```bash
# Should not find gw
which gw
type gw

# Should not show completion
complete -p gw 2>/dev/null
```

This installation guide should cover all common scenarios and platforms. For specific environments or edge cases, consult the development team or community resources.