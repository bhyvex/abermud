#!/usr/bin/env perl
package AberMUD::Controller;
use Moose;
use namespace::autoclean;
use MooseX::POE;
extends 'MUD::Controller';
use AberMUD::Player;
use AberMUD::Universe;
use AberMUD::Util;
use POE::Session;
use POE::Kernel;

has player_data_path => (
    is  => 'rw',
    isa => 'Str',
    default => "$ENV{PWD}/data"
);

#around '_response' => sub {
#    my $orig = shift;
#    my $self = shift;
#    my $id   = shift;
#    my $player = $self->universe->players->{$id};
#
#    my $response = $self->$orig($id, @_);
#    my $output;
#
#    $output = "You are in a void of nothingness...\n"
#        unless $player && @{$player->input_state};
#
#    if ($player && ref $player->input_state->[0] eq 'AberMUD::Input::State::Game') {
#        $player->materialize;
#        my $prompt = $player->prompt;
#        $output = "$response\n$prompt";
#    }
#    else {
#        $output = $response;
#    }
#
#    return AberMUD::Util::colorify($output);
#};

around 'START' => sub {
    my $orig = shift;
    my ($self, $kernel, $session) = @_[0, KERNEL, SESSION];
    $kernel->delay(tick => 1);
};

event 'tick' => sub {
    $_[KERNEL]->delay(tick => 1);
};

__PACKAGE__->meta->make_immutable;

1;
