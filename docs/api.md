# gw API Documentation

This document provides comprehensive API documentation for the `gw` (Git Worktree Switcher) tool.

## Overview

`gw` is a Git worktree management tool implemented in modern Perl (v5.20+) with an object-oriented architecture. It provides a complete interface to Git's worktree functionality with enhanced usability and shell integration.

## Architecture

### Main Class: WorktreeSwitcher

The core functionality is implemented in the `WorktreeSwitcher` class, which follows these design principles:

- **Object-Oriented Design**: Clean separation of concerns with well-defined methods
- **Command Dispatch**: Hash-based routing for efficient command handling
- **Error Handling**: Comprehensive error checking with meaningful messages
- **Shell Integration**: Multi-shell support with automatic detection

### Class Structure

```perl
package WorktreeSwitcher {
    # Constructor
    sub new($class, %args)
    
    # Main execution entry point
    sub run($self, @args)
    
    # Command methods
    sub cmd_*($self, @args)    # Individual command handlers
    
    # Utility methods
    sub execute_command($self, @cmd)
    sub capture_command($self, @cmd)
    sub detect_shell($self)
    # ... more utilities
}
```

## Command Reference

### Core Commands

#### `gw help`
**Purpose**: Display comprehensive help information
**Usage**: `gw help`
**Returns**: Exit code 0 with help text to stdout

#### `gw version`
**Purpose**: Show version information
**Usage**: `gw version`
**Returns**: Exit code 0 with version string

#### `gw list [options]`
**Purpose**: List Git worktrees with optional formatting
**Usage**: 
```bash
gw list                 # Basic list
gw list -v             # Verbose output
gw list --porcelain    # Machine-readable format
gw list --porcelain -z # Null-terminated output
```

**Options**:
- `-v, --verbose`: Show detailed information
- `--porcelain`: Machine-readable output format
- `-z`: Null-terminate output lines (requires --porcelain)

**Implementation**: `cmd_list($self, @args)`

### Worktree Management

#### `gw add [options] <path> [<commit-ish>]`
**Purpose**: Create a new worktree
**Usage**:
```bash
gw add <path>                           # Basic worktree creation
gw add -b <branch> <path>              # Create with new branch
gw add -B <branch> <path>              # Force create/reset branch
gw add --detach <path>                 # Create detached HEAD worktree
gw add --lock --reason "msg" <path>    # Create and lock with reason
```

**Options**:
- `-f, --force`: Force creation even if path exists
- `--detach`: Create detached HEAD worktree
- `--checkout/--no-checkout`: Control automatic checkout
- `--lock`: Lock the worktree on creation
- `--reason <string>`: Specify lock reason (requires --lock)
- `--orphan`: Create orphan branch
- `-b <branch>`: Create new branch
- `-B <branch>`: Create or reset branch

**Parameters**:
- `<path>`: Directory path for new worktree (required)
- `<commit-ish>`: Git commit, branch, or tag to checkout (optional)

**Implementation**: `cmd_add($self, @args)`

#### `gw remove [options] <worktree>`
**Purpose**: Remove an existing worktree
**Usage**:
```bash
gw remove <worktree>     # Remove worktree
gw remove -f <worktree>  # Force removal
gw rm <worktree>         # Alias for remove
```

**Options**:
- `-f, --force`: Force removal even with uncommitted changes

**Implementation**: `cmd_remove($self, @args)`

#### `gw lock [options] <worktree>`
**Purpose**: Lock a worktree to prevent modification
**Usage**:
```bash
gw lock <worktree>                    # Lock worktree
gw lock --reason "In use" <worktree>  # Lock with reason
```

**Options**:
- `--reason <string>`: Specify reason for locking

**Implementation**: `cmd_lock($self, @args)`

#### `gw unlock <worktree>`
**Purpose**: Unlock a previously locked worktree
**Usage**: `gw unlock <worktree>`
**Implementation**: `cmd_unlock($self, @args)`

#### `gw move <worktree> <new-path>`
**Purpose**: Move worktree to new location
**Usage**: `gw move <old-path> <new-path>`
**Implementation**: `cmd_move($self, @args)`

#### `gw prune [options]`
**Purpose**: Clean up worktree administrative files
**Usage**:
```bash
gw prune                    # Basic cleanup
gw prune -n                 # Dry run
gw prune -v                 # Verbose output
gw prune --expire <time>    # Set expiration time
```

**Options**:
- `-n, --dry-run`: Show what would be pruned without doing it
- `-v, --verbose`: Show detailed information
- `--expire <time>`: Set expiration time for cleanup

**Implementation**: `cmd_prune($self, @args)`

#### `gw repair [<path>...]`
**Purpose**: Repair worktree administrative files
**Usage**:
```bash
gw repair           # Repair all worktrees
gw repair <path>    # Repair specific worktree
```

**Implementation**: `cmd_repair($self, @args)`

### Worktree Switching

#### `gw <worktree-name>`
**Purpose**: Switch to a worktree by fuzzy name matching
**Usage**: `gw <search-term>`
**Behavior**: 
- Searches worktree paths for the given term
- Switches to first matching worktree
- Uses `exec $SHELL` to replace current shell

**Implementation**: `switch_worktree($self, $search_term)`

#### `gw -`
**Purpose**: Switch to main/root worktree
**Usage**: `gw -`
**Implementation**: `goto_main_worktree($self)`

### Shell Integration

#### `gw shell`
**Purpose**: Generate shell function for in-shell directory switching
**Usage**: `eval "$(gw shell)"`
**Behavior**:
- Detects current shell (bash/zsh/fish)
- Emits appropriate shell function
- Enables directory switching without spawning new shells

**Shell Detection Order**:
1. Environment variables (`$BASH_VERSION`, `$ZSH_VERSION`, `$FISH_VERSION`)
2. Parent process name inspection
3. Fallback to bash syntax

**Generated Function Behavior**:
- Intercepts worktree switching commands
- Delegates management commands to real `gw` binary
- Uses `cd` instead of `exec $SHELL`

**Implementation**: `cmd_shell($self, @args)`

### Update System

#### `gw update`
**Purpose**: Self-update to latest release from GitHub
**Usage**: `gw update`
**Requirements**: `jq` command-line JSON processor
**Behavior**:
- Fetches latest release information from GitHub API
- Downloads and installs new version if available
- Requires `sudo` for installation

**Implementation**: `cmd_update($self, @args)`

## Internal Architecture

### Command Dispatch

Commands are routed through a hash-based dispatch table:

```perl
my %commands = (
    'list'    => sub { $self->cmd_list(@args) },
    'add'     => sub { $self->cmd_add(@args) },
    # ... more commands
);
```

### Option Parsing

Uses `Getopt::Long::GetOptionsFromArray` for robust option parsing:
- Supports both short (`-f`) and long (`--force`) options
- Handles flag negation (`--checkout` / `--no-checkout`)
- Validates required parameters

### Command Execution

Two execution modes:
1. **Direct Execution**: `execute_command()` - runs and shows output
2. **Capture Execution**: `capture_command()` - captures output for processing

### Error Handling

- Parameter validation with descriptive error messages
- Proper exit codes (0 for success, non-zero for errors)
- Command construction verification before execution

### Shell Function Generation

Multi-shell support with syntax adaptation:

```perl
sub emit_fish_function() { ... }    # Fish shell syntax
sub emit_bash_function() { ... }    # Bash/Zsh compatible syntax
```

## Configuration

### Instance Variables

```perl
{
    version         => $VERSION,                    # Tool version
    binary_path     => abs_path($0),              # Executable location
    release_api_url => 'https://api.github.com/repos/yankeexe/git-worktree-switcher/releases/latest',
    jq_url          => 'https://stedolan.github.io/jq/download',
    args            => [],                          # Command arguments
}
```

### Dependencies

**Core Perl Modules** (all standard):
- `Cwd` - Directory operations
- `File::Basename` - Path manipulation
- `File::Spec::Functions` - Cross-platform path handling
- `Getopt::Long` - Command-line option parsing
- `List::Util` - List processing utilities
- `POSIX` - System interface

**External Dependencies**:
- `git` - Git version control system
- `jq` - JSON processor (for updates only)

### Version Requirements

- **Perl**: v5.20 or later
- **Features**: Signatures, `say` function
- **Pragmas**: `strict`, `warnings`, `utf8`

## Extension Points

### Adding New Commands

1. Create new `cmd_<name>` method
2. Add entry to command dispatch table
3. Update help text
4. Add shell completion support

### Modifying Shell Integration

1. Extend `detect_shell()` for new shells
2. Create `emit_<shell>_function()` method
3. Update shell function templates

### Enhancing Option Parsing

1. Extend option specification in relevant `cmd_*` methods
2. Add validation logic
3. Update help documentation

This API provides a stable foundation for Git worktree management with room for future enhancements while maintaining backward compatibility.