# gw Development Guide

This guide covers development workflow, architecture, and contribution guidelines for the `gw` project.

## Table of Contents

1. [Development Setup](#development-setup)
2. [Architecture Overview](#architecture-overview)
3. [Code Standards](#code-standards)
4. [Testing](#testing)
5. [Adding Features](#adding-features)
6. [Contributing](#contributing)
7. [Release Process](#release-process)

## Development Setup

### Prerequisites

- **Perl 5.20+** with core modules
- **Git** with worktree support
- **Test::More** (standard Perl testing module)
- **bash/zsh/fish** (for completion testing)

### Clone and Setup

```bash
git clone https://github.com/yankeexe/git-worktree-switcher.git
cd git-worktree-switcher

# Make executable
chmod +x gw

# Run tests to verify setup
./test
```

### Project Structure

```
git-worktree-switcher/
├── gw                    # Main Perl script
├── gw.bash              # Original bash implementation  
├── README.md            # Project overview and quick start
├── CLAUDE.md            # AI development context
├── TESTING.md           # Testing methodology
├── completions/         # Shell completions
│   ├── bash/gw         # Bash completion
│   ├── zsh/gw          # Zsh completion  
│   └── fish/gw         # Fish completion
├── docs/               # Comprehensive documentation
│   ├── api.md         # API reference
│   ├── user-guide.md  # User documentation
│   └── development.md # This file
├── t/                  # Test suite
│   ├── basic.t        # Smoke tests
│   ├── gw.t          # Core functionality tests
│   └── completions.t  # Completion tests
└── test               # Test runner script
```

## Architecture Overview

### Design Principles

1. **Object-Oriented**: Clean class structure with well-defined responsibilities
2. **Modern Perl**: v5.20+ features including signatures and improved OOP
3. **Command Dispatch**: Hash-based routing for extensibility
4. **Error Handling**: Comprehensive validation with meaningful messages
5. **Shell Agnostic**: Multi-shell support with automatic detection
6. **Testable**: Modular design enabling comprehensive testing

### Core Components

#### WorktreeSwitcher Class

```perl
package WorktreeSwitcher {
    # Object construction and configuration
    sub new($class, %args)
    
    # Main entry point and command routing  
    sub run($self, @args)
    
    # Command implementations
    sub cmd_list($self, @args)
    sub cmd_add($self, @args) 
    # ... other commands
    
    # Utility methods
    sub execute_command($self, @cmd)
    sub capture_command($self, @cmd)
    sub detect_shell($self)
    # ... other utilities
}
```

#### Command Dispatch Pattern

Commands are routed through a hash table for easy extension:

```perl
my %commands = (
    'list'    => sub { $self->cmd_list(@args) },
    'add'     => sub { $self->cmd_add(@args) },
    'remove'  => sub { $self->cmd_remove(@args) },
    # ... more commands
);

if (exists $commands{$command}) {
    return $commands{$command}->();
} else {
    return $self->switch_worktree($command);
}
```

#### Option Parsing Strategy

Uses `Getopt::Long` for robust option handling:

```perl
sub cmd_add($self, @args) {
    my %opts = (
        force => 0,
        detach => 0,
        # ... default values
    );
    
    GetOptionsFromArray(\@args,
        'f|force'    => \$opts{force},
        'detach'     => \$opts{detach},
        # ... option specifications
    ) or die "Invalid options\n";
    
    # Command implementation...
}
```

#### Shell Integration Architecture

Multi-shell support through detection and template generation:

```perl
sub detect_shell($self) {
    return 'fish' if $ENV{FISH_VERSION};
    return 'zsh'  if $ENV{ZSH_VERSION};
    return 'bash' if $ENV{BASH_VERSION};
    # ... fallback logic
}

sub emit_bash_function($self) { ... }
sub emit_fish_function($self) { ... }
```

## Code Standards

### Perl Style Guidelines

#### Language Features
```perl
# Use modern Perl features
use strict;
use warnings;  
use utf8;
use v5.20;
use feature qw(signatures say);
no warnings qw(experimental::signatures);
```

#### Subroutine Signatures
```perl
# Good: Use signatures for clarity
sub cmd_add($self, @args) { ... }

# Avoid: Traditional parameter handling
sub cmd_add {
    my ($self, @args) = @_;
    # ...
}
```

#### Variable Declarations
```perl
# Good: Declare variables close to use
sub some_method($self, @args) {
    my ($verbose, $porcelain) = (0, 0);
    
    GetOptionsFromArray(\@args,
        'v|verbose'  => \$verbose,
        'porcelain'  => \$porcelain,
    );
    # ...
}
```

#### Error Handling
```perl
# Good: Descriptive error messages
die "Error: <path> is required for 'gw add'\n" unless @args;

# Good: Check system command results  
my $output = $self->capture_command('git', 'worktree', 'list', '--porcelain')
    or die "Failed to get worktree list\n";
```

### Documentation Standards

#### Method Documentation
```perl
# Purpose: Brief description of what the method does
# Usage: Example command line usage
# Parameters: Description of parameters
# Returns: What the method returns
# Implementation: Reference to underlying method
sub cmd_example($self, @args) {
    # Implementation...
}
```

#### Code Comments
```perl
# Focus on WHY, not WHAT
# Good: Explains the purpose
# Configure Getopt::Long to handle case-sensitive options
local $Getopt::Long::ignorecase = 0;

# Avoid: Describes what code does
# Set ignorecase to 0
local $Getopt::Long::ignorecase = 0;
```

### Naming Conventions

- **Methods**: Snake_case for consistency with Perl conventions
- **Variables**: Descriptive names, snake_case for locals
- **Constants**: UPPER_CASE for package globals
- **Packages**: PascalCase following Perl conventions

## Testing

### Test Architecture

The project uses a comprehensive Perl testing framework with multiple test suites:

#### Test Categories

1. **Smoke Tests** (`t/basic.t`): Quick validation of core functionality
2. **Comprehensive Tests** (`t/gw.t`): Full command testing with Git integration  
3. **Completion Tests** (`t/completions.t`): Shell completion validation

#### Test Execution

```bash
# Run all tests
./test

# Run specific test suite
perl t/basic.t          # Quick smoke tests
perl t/gw.t            # Core functionality
perl t/completions.t   # Completion testing
```

### Writing Tests

#### Test Structure
```perl
use Test::More;

subtest 'Feature Name' => sub {
    # Setup
    my $result = run_gw('command', 'args');
    
    # Assertions
    ok($result->{success}, 'command succeeds');
    like($result->{stdout}, qr/expected pattern/, 'correct output');
    
    # Cleanup if needed
};

done_testing();
```

#### Test Utilities
```perl
# Helper for running gw commands
sub run_gw {
    my @args = @_;
    # Returns: { stdout, stderr, exit_code, success }
}

# Helper for creating test Git repositories  
sub create_test_git_repo {
    # Returns temporary directory with initialized Git repo
}
```

### Test Coverage Requirements

- **All Commands**: Every `cmd_*` method must have tests
- **Error Conditions**: Test invalid arguments and error handling
- **Shell Integration**: Verify shell function generation
- **Completion**: Validate completion file structure and content

## Adding Features

### Adding New Commands

1. **Implement Command Method**
```perl
sub cmd_newcommand($self, @args) {
    # Option parsing
    my %opts = ();
    GetOptionsFromArray(\@args,
        'flag' => \$opts{flag},
    ) or die "Invalid options for newcommand\n";
    
    # Validation
    die "Error: required parameter missing\n" unless @args;
    
    # Implementation
    my @cmd = ('git', 'worktree', 'newcommand');
    # Add options to @cmd based on %opts
    
    return $self->execute_command(@cmd);
}
```

2. **Add to Command Dispatch**
```perl
my %commands = (
    # ... existing commands
    'newcommand' => sub { $self->cmd_newcommand(@args) },
);
```

3. **Update Help Text**
```perl
sub show_help($self) {
    # ... existing help
    say "\tgw newcommand [options] <args>: description of new command.";
}
```

4. **Add Shell Completion Support**

Update completion files in `completions/` directory:
- `bash/gw`: Add to subcommands list and option handling
- `zsh/gw`: Add to commands array and argument completion
- `fish/gw`: Add completion rules

5. **Write Tests**
```perl
subtest 'New Command Tests' => sub {
    my $result = run_gw('newcommand', 'test-arg');
    ok($result->{success}, 'newcommand succeeds');
    like($result->{stdout}, qr/expected output/, 'correct command construction');
};
```

### Extending Shell Integration

1. **Add Shell Detection**
```perl
sub detect_shell($self) {
    return 'newshell' if $ENV{NEWSHELL_VERSION};
    # ... existing detection
}
```

2. **Create Shell Function Template**
```perl
sub emit_newshell_function($self) {
    print <<'EOF';
# New shell function syntax
function gw() {
    # Implementation for new shell
}
EOF
    return 0;
}
```

3. **Update Shell Command**
```perl
sub cmd_shell($self, @args) {
    my $shell_type = $self->detect_shell();
    
    if ($shell_type eq 'newshell') {
        return $self->emit_newshell_function();
    } elsif ($shell_type eq 'fish') {
        return $self->emit_fish_function();
    } else {
        return $self->emit_bash_function();
    }
}
```

## Contributing

### Development Workflow

1. **Fork and Clone**
```bash
git clone https://github.com/your-username/git-worktree-switcher.git
cd git-worktree-switcher
```

2. **Create Feature Branch**
```bash
git checkout -b feature/new-command
```

3. **Development Cycle**
```bash
# Make changes
vim gw

# Test changes
./test

# Test specific functionality  
perl t/basic.t
```

4. **Commit and Push**
```bash
git add gw
git commit -m "Add new command functionality

- Implement cmd_newcommand with full option support
- Add comprehensive test coverage
- Update shell completions
- Update documentation"

git push origin feature/new-command
```

### Code Review Process

1. **Self Review**
   - Run full test suite: `./test`
   - Check code style consistency
   - Verify documentation updates

2. **Pull Request**
   - Clear description of changes
   - Link to relevant issues
   - Include test results

3. **Review Criteria**
   - Code follows style guidelines
   - Comprehensive test coverage
   - Documentation updated
   - No regression in existing functionality

### Commit Message Guidelines

```
type(scope): short description

Detailed explanation of changes made, including:
- What was implemented
- Why it was needed  
- How it works
- Any breaking changes

Closes #issue-number
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `style`

## Release Process

### Version Management

Versions follow Semantic Versioning (SemVer):
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

### Release Checklist

1. **Update Version**
```perl
# In gw script
our $VERSION = '0.3.0';
```

2. **Run Full Test Suite**
```bash
./test
# Ensure all tests pass
```

3. **Update Documentation**
- Update README.md with new features
- Update CHANGELOG.md (if exists)
- Review all documentation for accuracy

4. **Create Release**
```bash
git tag -a v0.3.0 -m "Release version 0.3.0"
git push origin v0.3.0
```

5. **GitHub Release**
- Create release from tag
- Include changelog
- Attach binary if needed

### Backward Compatibility

- Maintain existing command interfaces
- Deprecate features gracefully
- Document breaking changes clearly
- Provide migration path for users

This development guide ensures consistent, high-quality contributions to the `gw` project while maintaining its reliability and usability.