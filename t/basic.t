#!/usr/bin/env perl

# Quick basic functionality tests for gw

use strict;
use warnings;
use utf8;
use v5.20;
use Test::More;

# Find gw script
my $gw = './bin/gw';
BAIL_OUT("gw script not found") unless -f $gw && -x $gw;

# Basic smoke tests
subtest 'Smoke Tests' => sub {
    # Help
    my $output = `$gw help 2>&1`;
    my $exit_code = $? >> 8;
    is($exit_code, 0, 'help command exits successfully');
    like($output, qr/gw lets you switch/, 'help shows description');
    
    # Version
    $output = `$gw version 2>&1`;
    $exit_code = $? >> 8;
    is($exit_code, 0, 'version command exits successfully');
    like($output, qr/Version: \d+\.\d+\.\d+/, 'version shows version number');
    
    # Shell function
    $output = `$gw shell 2>&1`;
    $exit_code = $? >> 8;
    is($exit_code, 0, 'shell command exits successfully');
    like($output, qr/gw\(\)/, 'shell generates function');
    
    # Error handling
    $output = `$gw add 2>&1`;
    $exit_code = $? >> 8;
    isnt($exit_code, 0, 'add without args fails');
    like($output, qr/Error:.*path.*required/, 'add shows error message');
};

done_testing();