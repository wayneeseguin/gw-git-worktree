# Git Worktree Switcher :zap:

A high-performance Git worktree management tool that combines fast switching with complete Git worktree command support. Built in modern Perl with comprehensive shell integration.

Original inspiration was git-worktree-switcher by Yankee Maharjan, but this is a complete ground-up rewrite with a focus on testability, and features.

## Features

- **Fast worktree switching** with fuzzy search
- **Complete Git worktree command support** (add, remove, lock, unlock, move, prune, repair)
- **In-shell directory switching** - no new shell spawning
- **Shell integration** with `eval "$(gw shell)"`
- **Tab autocompletion** for Bash, Zsh, and Fish
- **Self-updating** from GitHub releases
- **Modern Perl implementation** with robust error handling

## Quick Start

1. **Install**: Run `sudo bin/install` for system-wide installation
2. **Integrate**: Shell integration and completions are automatically configured
3. **Switch**: Use `gw <worktree-name>` to switch between worktrees

```bash
# Quick example
gw add -b feature ../feature-branch  # Create new worktree
gw feature                           # Switch to it
gw list -v                          # View all worktrees
gw remove ../feature-branch         # Remove when done
```

## Documentation

Comprehensive documentation is available in the `docs/` directory:

### 📖 User Documentation
- **[Installation Guide](docs/installation.md)** - Multiple installation methods, platform-specific instructions, and shell setup
- **[User Guide](docs/user-guide.md)** - Complete usage examples, workflows, and troubleshooting

### 🔧 Developer Documentation
- **[API Reference](docs/api.md)** - Complete API documentation for the WorktreeSwitcher class and all command methods
- **[Development Guide](docs/development.md)** - Architecture overview, code standards, and contribution guidelines

### ⚡ Quick Reference

#### Essential Commands
```bash
gw <name>                    # Switch to worktree (fuzzy search)
gw -                         # Switch to main worktree
gw list                      # List all worktrees
gw add <path>                # Create new worktree
gw remove <worktree>         # Remove worktree
```

#### Shell Integration
```bash
# Add to .bashrc/.zshrc for in-shell directory switching
eval "$(gw shell)"
```

#### Installation
```bash
# System-wide installation (recommended)
sudo bin/install

# Or manual installation
cp bin/gw /usr/local/bin/
cp completions/bash/gw /usr/local/share/bash-completion/completions/
cp completions/zsh/gw /usr/local/share/zsh/site-functions/_gw
cp completions/fish/gw /usr/local/share/fish/vendor_completions.d/gw.fish
```

## Advanced Features

### Complete Git Worktree Command Support

`gw` provides full compatibility with all `git worktree` commands:

```bash
# Worktree creation with branches
gw add -b new-feature ../feature     # Create with new branch
gw add -B existing-branch ../fix     # Create/reset existing branch
gw add --detach ../detached          # Create detached worktree

# Worktree locking and management
gw lock --reason "In review" <tree>  # Lock with reason
gw unlock <worktree>                 # Unlock worktree
gw move <worktree> <new-path>        # Move worktree

# Maintenance operations
gw prune -v                          # Clean up with verbose output
gw repair                            # Repair admin files
```

### Shell Function Integration

When using `eval "$(gw shell)"`:
- **Directory switching** (`gw <name>`, `gw -`) uses `cd` in current shell
- **Management commands** delegate to the Perl binary
- **No shell spawning** for navigation
- **Full command compatibility** maintained

### Intelligent Completion

The completion system provides:
- **Context-aware suggestions** for commands and flags
- **Worktree name completion** for all operations
- **Path completion** for file arguments
- **Flag descriptions** and validation

## Architecture

`gw` is built with modern Perl v5.20+ featuring:
- **Object-oriented design** with the WorktreeSwitcher class
- **Command dispatch pattern** for extensible architecture
- **Comprehensive error handling** and validation
- **Modular testing** with extensive test coverage
- **Cross-platform compatibility** for Unix-like systems

## Contributing

See the [Development Guide](docs/development.md) for:
- Development environment setup
- Code standards and best practices
- Adding new features and commands
- Running tests and validation

## Support

- **Issues**: Report bugs and request features on [GitHub Issues](https://github.com/yankeexe/git-worktree-switcher/issues)
- **Documentation**: Full documentation available in [docs/](docs/)
- **Updates**: Use `gw update` to get the latest release

## License

MIT License - see LICENSE file for details.
