#!/usr/bin/env perl
package AberMUD::Config;
use Moose;
use namespace::autoclean;

use AberMUD::Location;

has location => (
    is  => 'rw',
    isa => 'AberMUD::Location',
);

has input_states => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
);

__PACKAGE__->meta->make_immutable;

1;

