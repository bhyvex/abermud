#!/usr/bin/env perl
package AberMUD::Input::Command::Up;
use Moose;
extends 'AberMUD::Input::Command';

my $command_name = lc __PACKAGE__;
$command_name =~ s/.+:://; $command_name =~ s/\.pm//;
has '+name' => ( default => $command_name );

sub run {
    my $you  = shift;
    my $direction = $command_name;
    return "You are somehow nowhere." unless defined $you->location;
    return $you->${\"go_$direction"};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
