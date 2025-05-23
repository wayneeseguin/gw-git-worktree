# gw User Guide

A comprehensive guide to using `gw`, the Git Worktree Switcher.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [Basic Usage](#basic-usage)
4. [Advanced Features](#advanced-features)
5. [Shell Integration](#shell-integration)
6. [Workflow Examples](#workflow-examples)
7. [Troubleshooting](#troubleshooting)

## Quick Start

```bash
# Install gw
curl -L https://github.com/yankeexe/git-worktree-switcher/releases/latest/download/gw -o gw
chmod +x gw
sudo mv gw /usr/local/bin/

# Set up shell integration (recommended)
echo 'eval "$(gw shell)"' >> ~/.bashrc  # or ~/.zshrc
source ~/.bashrc

# Basic usage
gw help                    # Show help
gw list                    # List worktrees
gw add ../feature-branch   # Create new worktree
gw feature                 # Switch to worktree (fuzzy match)
```

## Installation

### Prerequisites

- **Perl 5.20+** (usually pre-installed on Unix systems)
- **Git** with worktree support
- **jq** (optional, for self-updates)

### Installation Methods

#### 1. Download Release Binary

```bash
# Download latest release
curl -L https://github.com/yankeexe/git-worktree-switcher/releases/latest/download/gw -o gw
chmod +x gw
sudo mv gw /usr/local/bin/
```

#### 2. Build from Source

```bash
git clone https://github.com/yankeexe/git-worktree-switcher.git
cd git-worktree-switcher
chmod +x gw
sudo cp gw /usr/local/bin/
```

#### 3. Shell Completions (Optional)

```bash
# Bash
sudo cp completions/bash/gw /etc/bash_completion.d/gw

# Zsh
cp completions/zsh/gw ~/.local/share/zsh/site-functions/_gw

# Fish  
cp completions/fish/gw ~/.config/fish/completions/gw.fish
```

### Verification

```bash
gw version    # Should show version number
gw help       # Should display help information
```

## Basic Usage

### Getting Help

```bash
gw help                    # Complete help
gw <command> --help        # Command-specific help (where supported)
```

### Listing Worktrees

```bash
gw list                    # Basic list
gw list -v                 # Verbose (shows commit info)
gw list --porcelain        # Machine-readable format
```

Example output:
```
/Users/user/project        abc1234 [main]
/Users/user/project-feature def5678 [feature-login]
/Users/user/project-hotfix  ghi9012 [hotfix-bug]
```

### Creating Worktrees

#### Basic Creation
```bash
gw add ../feature-branch              # Create worktree in ../feature-branch
gw add /tmp/hotfix main              # Create from specific branch
```

#### With New Branch
```bash
gw add -b feature-login ../login     # Create new branch
gw add -B hotfix-123 ../hotfix       # Force create/reset branch
```

#### Advanced Options
```bash
gw add --detach ../testing           # Detached HEAD
gw add --lock --reason "WIP" ../work # Lock with reason
gw add --orphan ../docs              # Orphan branch
```

### Switching Between Worktrees

#### By Name/Path Matching
```bash
gw feature                # Fuzzy match "feature" in worktree paths
gw login                  # Switch to worktree containing "login"
gw main                   # Switch to main worktree
```

#### Special Commands
```bash
gw -                      # Switch to main/root worktree
```

### Managing Worktrees

#### Removing Worktrees
```bash
gw remove ../feature-branch          # Remove worktree
gw remove -f ../unclean-worktree    # Force remove (ignore uncommitted changes)
gw rm ../feature-branch             # Alias for remove
```

#### Locking/Unlocking
```bash
gw lock ../important-work                    # Lock worktree
gw lock --reason "In review" ../feature     # Lock with reason
gw unlock ../feature                         # Unlock worktree
```

#### Moving Worktrees
```bash
gw move ../old-location ../new-location     # Move worktree
```

#### Maintenance
```bash
gw prune                  # Clean up stale references
gw prune -n               # Dry run (show what would be cleaned)
gw prune -v               # Verbose output
gw repair                 # Repair administrative files
```

## Advanced Features

### Shell Integration

The most powerful feature of `gw` is shell integration, which enables directory switching within your current shell session.

#### Setup
```bash
# Add to your shell configuration file
echo 'eval "$(gw shell)"' >> ~/.bashrc   # Bash
echo 'eval "$(gw shell)"' >> ~/.zshrc    # Zsh

# For Fish shell
gw shell | source                         # One-time
echo 'gw shell | source' >> ~/.config/fish/config.fish  # Permanent
```

#### How It Works

Without shell integration:
```bash
gw feature    # Spawns new shell in feature worktree
exit          # Must exit to return to original location
```

With shell integration:
```bash
gw feature    # Changes directory in current shell
# Continue working in same shell session
```

#### Function Behavior

The shell function intelligently routes commands:
- **Management commands** → Call real `gw` binary
- **Switching commands** → Use `cd` in current shell

```bash
# These call the gw binary
gw list
gw add ../new-feature
gw remove ../old-feature

# These use cd in current shell  
gw feature-branch
gw -
```

### Self-Updating

```bash
gw update     # Check for and install latest version
```

Requirements:
- `jq` command-line JSON processor
- `sudo` access for installation
- Internet connection

### Machine-Readable Output

For scripting and automation:

```bash
# Porcelain format
gw list --porcelain
# Output: worktree /path/to/worktree
#         HEAD abc1234def
#         branch refs/heads/main

# Null-terminated (safe for filenames with spaces)
gw list --porcelain -z | while IFS= read -r -d '' line; do
    echo "Processing: $line"
done
```

## Workflow Examples

### Feature Development Workflow

```bash
# Start new feature
gw add -b feature-user-auth ../auth-feature
gw auth                                   # Switch to feature worktree

# Work on feature...
git add . && git commit -m "Add user authentication"

# Switch back to main for hotfix
gw -                                      # Go to main worktree
gw add -b hotfix-security ../security    # Create hotfix worktree
gw security                               # Switch to hotfix

# Work on hotfix...
git add . && git commit -m "Fix security issue"

# Clean up when done
gw -                                      # Return to main
gw remove ../auth-feature                 # Remove feature worktree
gw remove ../security                     # Remove hotfix worktree
```

### Code Review Workflow

```bash
# Create review worktree
gw add -B review-pr-123 ../review origin/feature-branch
gw review                                 # Switch to review worktree

# Lock during review
gw lock --reason "Code review in progress" ../review

# Test and review...

# Unlock when done
gw unlock ../review
gw remove ../review                       # Clean up
```

### Multi-Version Testing

```bash
# Test different versions
gw add --detach ../test-v1.0 v1.0.0
gw add --detach ../test-v2.0 v2.0.0
gw add --detach ../test-main main

# Switch between versions for testing
gw test-v1.0    # Test version 1.0
gw test-v2.0    # Test version 2.0
gw test-main    # Test main branch

# Clean up all test worktrees
gw remove ../test-v1.0 ../test-v2.0 ../test-main
```

### Maintenance Workflow

```bash
# Regular maintenance
gw list                   # Check current worktrees
gw prune -n               # See what can be cleaned up
gw prune                  # Actually clean up
gw repair                 # Fix any administrative issues

# Update tool
gw update                 # Get latest version
```

## Troubleshooting

### Common Issues

#### "Command not found: gw"
```bash
# Check installation
which gw                  # Should show path to gw
echo $PATH                # Ensure /usr/local/bin is in PATH

# Reinstall if needed
curl -L https://github.com/yankeexe/git-worktree-switcher/releases/latest/download/gw -o gw
chmod +x gw
sudo mv gw /usr/local/bin/
```

#### "No worktree found matching: ..."
```bash
# Check available worktrees
gw list

# Use exact path or longer search term
gw feature-branch-name    # Instead of just "feature"
```

#### Shell Integration Not Working

```bash
# Check if function is loaded
type gw                   # Should show "gw is a function"

# Reload shell configuration
source ~/.bashrc          # or ~/.zshrc

# Re-run shell integration setup
eval "$(gw shell)"
```

#### Permission Errors During Update

```bash
# Ensure you have sudo access
sudo -v

# Check current binary location
which gw

# Manual update if automatic fails
curl -L https://github.com/yankeexe/git-worktree-switcher/releases/latest/download/gw -o /tmp/gw
chmod +x /tmp/gw
sudo mv /tmp/gw /usr/local/bin/gw
```

### Performance Issues

#### Slow Completion
Shell completion performance depends on the number of worktrees and `gw list` speed.

```bash
# Test completion performance
time gw list              # Should complete quickly

# If slow, check for corrupted worktrees
gw repair
gw prune
```

#### Large Repository Handling
For repositories with many worktrees:

```bash
# Use porcelain format for faster parsing
gw list --porcelain

# Consider using specific worktree paths instead of fuzzy matching
gw /full/path/to/worktree
```

### Error Messages

#### "Error: <path> is required for 'gw add'"
Provide a path argument:
```bash
gw add ../my-feature      # Correct
```

#### "Error: 'gw move' requires <worktree> <new-path>"
Provide both source and destination:
```bash
gw move ../old-path ../new-path    # Correct
```

#### "Failed to get worktree list"
Check that you're in a Git repository:
```bash
git status                # Should show Git repository info
git worktree list         # Should work directly
```

### Getting Support

1. **Check Documentation**: Review this guide and API documentation
2. **Run Tests**: Use `./test` to verify installation
3. **Check Issues**: Visit GitHub issues for known problems
4. **Report Bugs**: Create detailed issue reports with:
   - `gw version` output
   - Operating system and shell
   - Complete error messages
   - Steps to reproduce

### Performance Tips

1. **Use Shell Integration**: Significantly faster than spawning new shells
2. **Enable Completion**: Reduces typing and errors
3. **Regular Maintenance**: Run `gw prune` periodically
4. **Specific Paths**: Use longer search terms for faster matching

This guide covers the most common use cases and workflows. For complete API reference, see [docs/api.md](api.md).