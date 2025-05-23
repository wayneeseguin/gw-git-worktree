# Testing Guide

This document describes the testing framework and methodology for the `gw` Git Worktree Switcher tool.

## Overview

The project includes a comprehensive Perl test suite designed to validate all functionality through black-box testing, ensuring command construction and basic execution paths work correctly across different platforms and use cases.

## Test Structure

```
t/
├── basic.t         # Quick smoke tests for basic functionality
├── gw.t           # Comprehensive test suite for core functionality
└── completions.t   # Shell completion testing
bin/test           # Test runner script
```

## Running Tests

### Quick Tests

Run basic smoke tests for fast validation during development:

```bash
# Run basic smoke tests (fast)
perl t/basic.t

# Or directly with executable permission:
./t/basic.t
```

### Full Test Suite

Run the complete test suite including completion tests:

```bash
# Run comprehensive tests using the test runner
bin/test

# Or run individual test suites:
perl t/gw.t          # Core functionality
perl t/completions.t # Shell completions
```

### Development Workflow

```bash
# Quick validation during development
perl t/basic.t

# Full validation before committing changes
bin/test
```

## Test Coverage

### Core Functionality

#### Basic Commands
- `gw help` - Help message display
- `gw version` - Version information  
- `gw` (no args) - Default help behavior

#### Shell Integration
- `gw shell` - Shell function generation
- Multi-shell support detection (bash/zsh/fish)
- Function delegation logic

#### Git Repository Operations
- `gw list` - Basic listing
- `gw list -v` - Verbose output
- `gw list --porcelain` - Machine-readable format
- `gw list --porcelain -z` - Null-terminated output

### Worktree Management

#### Creation Operations
- `gw add <path>` - Basic worktree creation
- `gw add -b <branch> <path>` - With new branch
- `gw add -B <branch> <path>` - Force branch creation
- `gw add --detach <path>` - Detached HEAD
- `gw add --lock <path>` - Lock on creation
- `gw add --orphan <path>` - Orphan branch

#### Management Operations
- `gw remove <worktree>` - Worktree removal
- `gw rm <worktree>` - Remove alias
- `gw lock <worktree>` - Lock worktree
- `gw unlock <worktree>` - Unlock worktree
- `gw move <old> <new>` - Move worktree
- `gw prune` - Cleanup operations
- `gw repair` - Repair operations

### Shell Completions

#### Bash Completion
- Function definition and registration
- Subcommand and flag completion
- Integration with actual `gw` command

#### Zsh Completion  
- Compdef directive usage
- _describe functionality
- Argument completion patterns

#### Fish Completion
- Complete command syntax
- Helper functions
- Flag definitions

#### Cross-Shell Features
- Consistent command coverage across all shells
- Flag completion uniformity
- Performance optimization (reasonable file sizes)
- Syntax validation

### Error Handling & Edge Cases

#### Input Validation
- Missing required arguments
- Invalid command options
- Helpful error messages

#### Advanced Features
- Complex flag combinations
- Command aliases
- Directory independence
- Worktree switching logic

## Test Implementation

### Framework Architecture

- **Language**: Perl v5.20+ with Test::More
- **Approach**: Black-box testing via command execution
- **Isolation**: Each test uses temporary Git repositories
- **Coverage**: Command construction and basic execution paths

### Test Utilities

The test suite includes several helper functions:

```perl
# Helper function for running gw commands
sub run_gw {
    my @args = @_;
    # Returns: { stdout, stderr, exit_code, success }
}

# Helper function for creating test Git repositories
sub create_test_git_repo {
    # Returns temporary directory with initialized Git repo
}

# Helper functions for testing shell completions
sub test_bash_completion {
    my ($input, $expected_pattern, $description) = @_;
    # Tests bash completion functionality
}

sub test_zsh_completion {
    my ($input, $expected_pattern, $description) = @_;
    # Tests zsh completion functionality
}
```

### Test Categories

- **Smoke Tests**: Basic functionality verification (`t/basic.t`)
- **Integration Tests**: Full command workflows (`t/gw.t`)
- **Completion Tests**: Shell completion functionality (`t/completions.t`)
- **Error Tests**: Invalid input handling
- **Edge Cases**: Boundary conditions
- **Performance Tests**: File sizes and syntax validation

## Testing Philosophy

### What We Test

- **Command Construction**: Verify correct `git worktree` commands are built
- **Argument Parsing**: Ensure flags and options are handled correctly
- **Error Conditions**: Validate appropriate error messages
- **Basic Workflows**: Test common usage patterns
- **Shell Integration**: Verify shell function generation and delegation

### What We Don't Test

- **Git Internals**: We don't test Git worktree functionality itself
- **Shell Execution**: We verify commands are constructed, not executed
- **File System Operations**: Actual worktree creation is Git's responsibility

### Testing Strategy

1. **Unit Level**: Individual command parsing and construction
2. **Integration Level**: Complete command workflows
3. **System Level**: End-to-end functionality verification

## System Requirements

### Required Dependencies

- **Perl 5.20+** (with signatures support)
- **Test::More** (core Perl module)
- **Git** (for repository operations during testing)

### Optional Dependencies

- **File::Temp** (for test isolation)
- **Temporary directory support**

## Adding New Tests

### Test Structure

When adding new functionality, include corresponding tests:

```perl
subtest 'New Feature Tests' => sub {
    my $result = run_gw('new-command', '--flag');
    ok($result->{success}, 'command succeeds');
    like($result->{stdout}, qr/expected pattern/, 'correct output');
};
```

### Best Practices

1. **Isolation**: Each test should be independent
2. **Clarity**: Use descriptive test names and messages
3. **Coverage**: Test both success and failure cases
4. **Efficiency**: Group related tests in subtests
5. **Documentation**: Comment complex test logic

## Debugging Tests

### Verbose Output

```bash
# See detailed test output
perl t/gw.t -v

# Debug specific test with Perl debugger
perl -d t/gw.t
```

### Manual Verification

```bash
# Test command construction manually
bin/gw add --help 2>&1 | head -5

# Verify command output
bin/gw version

# Test shell function generation
bin/gw shell | head -10
```

### Test Data Investigation

```bash
# Examine test repository state
ls -la /tmp/test-git-repo-*

# Check Git repository structure
git -C /tmp/test-repo worktree list
```

## Continuous Integration

### Pre-commit Testing

Always run tests before committing changes:

```bash
# Full test suite
bin/test

# Quick smoke test for minor changes
perl t/basic.t
```

### Release Testing

Before creating releases, ensure all tests pass:

```bash
# Run complete test suite
bin/test

# Verify installation
sudo bin/install
gw version
gw help
```

This comprehensive testing framework ensures the reliability and correctness of the `gw` tool across all supported platforms, shells, and use cases.