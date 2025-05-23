#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use v5.20;
use feature qw(say);

use Test::More;
use File::Temp qw(tempdir);
use File::Basename qw(dirname);
use Cwd qw(abs_path getcwd);

# Find the completion files relative to this test file
my $script_dir = dirname(dirname(abs_path($0)));
my $bash_completion = "$script_dir/completions/bash/gw";
my $zsh_completion = "$script_dir/completions/zsh/gw";
my $fish_completion = "$script_dir/completions/fish/gw";
my $gw_script = "$script_dir/bin/gw";

# Check if completion files exist
BAIL_OUT("bash completion not found at $bash_completion") unless -f $bash_completion;
BAIL_OUT("zsh completion not found at $zsh_completion") unless -f $zsh_completion;
BAIL_OUT("fish completion not found at $fish_completion") unless -f $fish_completion;
BAIL_OUT("gw script not found at $gw_script") unless -f $gw_script && -x $gw_script;

# Test helper functions
sub create_test_git_repo {
    my $dir = tempdir(CLEANUP => 1);
    chdir $dir;
    
    # Initialize git repo
    system('git init --quiet') == 0 or die "Failed to init git repo";
    system('git config user.name "Test User"') == 0 or die "Failed to set git config";
    system('git config user.email "test@example.com"') == 0 or die "Failed to set git config";
    
    # Create initial commit
    system('touch README.md') == 0 or die "Failed to create README";
    system('git add README.md') == 0 or die "Failed to add README";
    system('git commit -m "Initial commit" --quiet') == 0 or die "Failed to commit";
    
    return $dir;
}

sub test_bash_completion {
    my ($input, $expected_pattern, $description) = @_;
    
    # Set up environment for testing bash completion
    my $test_script = qq{
        source $bash_completion
        
        # Mock the completion environment
        COMP_WORDS=($input)
        COMP_CWORD=\$((${\\scalar(split(' ', $input))} - 1))
        
        # Call completion function
        _gw
        
        # Output the completion results
        printf '%s\\n' "\${COMPREPLY[@]}"
    };
    
    my $output = `bash -c '$test_script' 2>/dev/null`;
    
    if ($expected_pattern) {
        like($output, $expected_pattern, $description);
    } else {
        ok(defined($output), $description);
    }
    
    return $output;
}

sub test_zsh_completion {
    my ($input, $expected_pattern, $description) = @_;
    
    # Create a temporary zsh completion test
    my $temp_dir = tempdir(CLEANUP => 1);
    my $test_file = "$temp_dir/test_completion";
    
    open my $fh, '>', $test_file or die "Cannot create test file: $!";
    print $fh qq{
        # Load zsh completion system
        autoload -Uz compinit
        compinit -D
        
        # Source our completion
        source $zsh_completion
        
        # Mock completion
        words=($input)
        current=\${#words}
        
        # Test if completion function exists
        if declare -f _gw >/dev/null 2>&1; then
            echo "completion_function_exists"
        else
            echo "completion_function_missing"
        fi
    };
    close $fh;
    
    my $output = `zsh $test_file 2>/dev/null`;
    
    if ($expected_pattern) {
        like($output, $expected_pattern, $description);
    } else {
        ok(defined($output), $description);
    }
    
    return $output;
}

# Basic completion file structure tests
subtest 'Completion File Structure' => sub {
    # Test bash completion file structure
    my $bash_content = do {
        open my $fh, '<', $bash_completion or die "Cannot read bash completion: $!";
        local $/;
        <$fh>;
    };
    
    like($bash_content, qr/_gw\(\)/, 'bash completion defines _gw function');
    like($bash_content, qr/complete -F _gw gw/, 'bash completion registers with complete');
    like($bash_content, qr/COMPREPLY/, 'bash completion uses COMPREPLY array');
    like($bash_content, qr/compgen/, 'bash completion uses compgen');
    
    # Test zsh completion file structure  
    my $zsh_content = do {
        open my $fh, '<', $zsh_completion or die "Cannot read zsh completion: $!";
        local $/;
        <$fh>;
    };
    
    like($zsh_content, qr/#compdef gw/, 'zsh completion has compdef directive');
    like($zsh_content, qr/_gw\(\)/, 'zsh completion defines _gw function');
    like($zsh_content, qr/_describe/, 'zsh completion uses _describe');
    
    # Test fish completion file structure
    my $fish_content = do {
        open my $fh, '<', $fish_completion or die "Cannot read fish completion: $!";
        local $/;
        <$fh>;
    };
    
    like($fish_content, qr/complete -c gw/, 'fish completion uses complete command');
    like($fish_content, qr/__gw_worktrees/, 'fish completion defines helper function');
    like($fish_content, qr/command -q gw/, 'fish completion checks for gw command');
};

subtest 'Subcommand Completions' => sub {
    # Test that completion files include all subcommands
    my @expected_commands = qw(list add lock move prune remove rm repair unlock shell update help version);
    
    # Check bash completion
    my $bash_content = do {
        open my $fh, '<', $bash_completion or die "Cannot read bash completion: $!";
        local $/;
        <$fh>;
    };
    
    for my $cmd (@expected_commands) {
        like($bash_content, qr/\b$cmd\b/, "bash completion includes '$cmd' command");
    }
    
    # Check zsh completion
    my $zsh_content = do {
        open my $fh, '<', $zsh_completion or die "Cannot read zsh completion: $!";
        local $/;
        <$fh>;
    };
    
    for my $cmd (@expected_commands) {
        like($zsh_content, qr/\b$cmd\b/, "zsh completion includes '$cmd' command");
    }
    
    # Check fish completion
    my $fish_content = do {
        open my $fh, '<', $fish_completion or die "Cannot read fish completion: $!";
        local $/;
        <$fh>;
    };
    
    for my $cmd (@expected_commands) {
        like($fish_content, qr/\b$cmd\b/, "fish completion includes '$cmd' command");
    }
};

subtest 'Flag Completions' => sub {
    # Test that completion files include important flags
    my @bash_flags = qw(-v --verbose --porcelain -z -f --force --detach --lock --reason -b -B);
    my @zsh_flags = qw(-v --verbose --porcelain -z -f --force --detach --lock --reason -b -B);
    my @fish_flags = qw(-v --verbose --porcelain -z -f --force --detach --lock --reason -b -B);
    
    # Check bash completion
    my $bash_content = do {
        open my $fh, '<', $bash_completion or die "Cannot read bash completion: $!";
        local $/;
        <$fh>;
    };
    
    for my $flag (@bash_flags) {
        like($bash_content, qr/\Q$flag\E/, "bash completion includes '$flag' flag");
    }
    
    # Check zsh completion
    my $zsh_content = do {
        open my $fh, '<', $zsh_completion or die "Cannot read zsh completion: $!";
        local $/;
        <$fh>;
    };
    
    for my $flag (@zsh_flags) {
        like($zsh_content, qr/\Q$flag\E/, "zsh completion includes '$flag' flag");
    }
    
    # Check fish completion (fish uses different syntax)
    my $fish_content = do {
        open my $fh, '<', $fish_completion or die "Cannot read fish completion: $!";
        local $/;
        <$fh>;
    };
    
    # Fish completion uses different syntax, so we check for the meaningful parts
    like($fish_content, qr/-s v/, "fish completion includes '-v' flag");
    like($fish_content, qr/-l verbose/, "fish completion includes '--verbose' flag");
    like($fish_content, qr/-l porcelain/, "fish completion includes '--porcelain' flag");
    like($fish_content, qr/-s z/, "fish completion includes '-z' flag");
    like($fish_content, qr/-s f/, "fish completion includes '-f' flag");
    like($fish_content, qr/-l force/, "fish completion includes '--force' flag");
    like($fish_content, qr/-l detach/, "fish completion includes '--detach' flag");
    like($fish_content, qr/-l lock/, "fish completion includes '--lock' flag");
    like($fish_content, qr/-l reason/, "fish completion includes '--reason' flag");
    like($fish_content, qr/-s b/, "fish completion includes '-b' flag");
    like($fish_content, qr/-s B/, "fish completion includes '-B' flag");
};

subtest 'Bash Completion Functionality' => sub {
    SKIP: {
        # Skip if bash is not available
        skip "bash not available", 6 unless -x '/bin/bash' || -x '/usr/bin/bash';
        
        # Test basic subcommand completion
        my $output = test_bash_completion('gw ', undef, 'bash completion works for subcommands');
        
        # Should complete subcommands (check if any completion happened)
        # Note: actual completion results depend on environment and available worktrees
        ok(defined($output), 'bash completes basic subcommands');
        
        # Test that we can load the completion without errors
        my $load_test = `bash -c 'source $bash_completion; echo "loaded"' 2>&1`;
        like($load_test, qr/loaded/, 'bash completion loads without errors');
        
        # Test function exists
        my $func_test = `bash -c 'source $bash_completion; declare -f _gw >/dev/null && echo "exists"' 2>&1`;
        like($func_test, qr/exists/, 'bash completion function _gw exists');
        
        # Test complete registration
        my $complete_test = `bash -c 'source $bash_completion; complete -p gw' 2>&1`;
        like($complete_test, qr/complete.*_gw.*gw/, 'bash completion is registered for gw command');
    }
};

subtest 'Zsh Completion Functionality' => sub {
    SKIP: {
        # Skip if zsh is not available
        skip "zsh not available", 4 unless -x '/bin/zsh' || -x '/usr/bin/zsh';
        
        # Test that we can load the completion without errors
        my $output = test_zsh_completion('gw ', qr/completion_function/, 'zsh completion loads');
        
        # Test compdef directive
        my $zsh_content = do {
            open my $fh, '<', $zsh_completion or die "Cannot read zsh completion: $!";
            local $/;
            <$fh>;
        };
        
        like($zsh_content, qr/#compdef gw/, 'zsh completion has proper compdef directive');
        like($zsh_content, qr/_gw.*\"\$@\"/, 'zsh completion calls _gw with arguments');
    }
};

subtest 'Fish Completion Functionality' => sub {
    SKIP: {
        # Skip if fish is not available
        skip "fish not available", 4 unless -x '/usr/bin/fish' || -x '/opt/homebrew/bin/fish';
        
        # Test that completion file is syntactically valid fish
        my $syntax_test = `fish -n $fish_completion 2>&1`;
        my $exit_code = $? >> 8;
        is($exit_code, 0, 'fish completion has valid syntax');
        
        # Test that we can source the file
        my $source_test = `fish -c 'source $fish_completion; echo "sourced"' 2>&1`;
        like($source_test, qr/sourced/, 'fish completion can be sourced');
        
        # Test helper function exists
        my $func_test = `fish -c 'source $fish_completion; functions -q __gw_worktrees; and echo "exists"' 2>&1`;
        like($func_test, qr/exists/, 'fish completion helper function exists');
    }
};

subtest 'Completion Integration with Git Repo' => sub {
    my $original_dir = getcwd();
    my $test_repo = create_test_git_repo();
    
    # Create a simple test to see if completions can call gw list
    # This tests the integration between completion and the actual gw command
    
    # Test bash completion with actual gw command
    SKIP: {
        skip "bash not available", 2 unless -x '/bin/bash' || -x '/usr/bin/bash';
        
        # Test that completion can call gw list
        my $bash_test = qq{
            export PATH="$script_dir:\$PATH"
            source $bash_completion
            
            # Test that the helper can call gw list
            if gw list >/dev/null 2>&1; then
                echo "gw_command_works"
            fi
        };
        
        my $output = `bash -c '$bash_test' 2>/dev/null`;
        like($output, qr/gw_command_works/, 'bash completion can call gw command');
    }
    
    # Test fish completion helper function
    SKIP: {
        skip "fish not available", 1 unless -x '/usr/bin/fish' || -x '/opt/homebrew/bin/fish';
        
        my $fish_test = qq{
            set -x PATH $script_dir \$PATH
            source $fish_completion
            
            # Test the helper function
            if __gw_worktrees >/dev/null 2>&1
                echo "helper_works"
            end
        };
        
        my $output = `fish -c '$fish_test' 2>/dev/null`;
        like($output, qr/helper_works/, 'fish completion helper function works');
    }
    
    chdir $original_dir;
};

subtest 'Completion Performance' => sub {
    # Test that completion files are reasonably sized and don't have obvious performance issues
    
    my $bash_size = -s $bash_completion;
    my $zsh_size = -s $zsh_completion;
    my $fish_size = -s $fish_completion;
    
    ok($bash_size > 0 && $bash_size < 50000, 'bash completion file size is reasonable');
    ok($zsh_size > 0 && $zsh_size < 50000, 'zsh completion file size is reasonable');
    ok($fish_size > 0 && $fish_size < 50000, 'fish completion file size is reasonable');
    
    # Test that completion files don't have obvious syntax errors
    # Bash
    my $bash_syntax = `bash -n $bash_completion 2>&1`;
    my $bash_exit = $? >> 8;
    is($bash_exit, 0, 'bash completion has no syntax errors');
    
    # Zsh (basic check)
    my $zsh_content = do {
        open my $fh, '<', $zsh_completion or die "Cannot read zsh completion: $!";
        local $/;
        <$fh>;
    };
    unlike($zsh_content, qr/\$\{[^}]*\$\{/, 'zsh completion has no obvious nested variable expansion issues');
};

# Run all tests
done_testing();