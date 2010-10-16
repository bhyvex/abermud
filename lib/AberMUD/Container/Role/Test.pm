#!/usr/bin/env perl
package AberMUD::Container::Role::Test;
use Moose::Role;
use Scalar::Util qw(weaken);

use Bread::Board;
use AberMUD::Storage;
use AberMUD::Controller;
use AberMUD::Universe;
use AberMUD::Player;
use AberMUD::Location;
use AberMUD::Object;
use List::Util qw(max);

use namespace::autoclean;

requires qw(container);

sub _build_player_block {
    return sub {

        my ($self, $s) = @_;

        my $u      = $s->param('universe');
        my $max_id = max(keys %{ $u->players }) || 0;
        my $player = AberMUD::Player->new_with_traits(
            traits    => ['AberMUD::Player::Role::Test'],
            universe  => $u,
            storage => $s->param('storage'),
        );

        $player->_join_server($max_id + 1);

        return $player;
    }

}

sub _build_controller_block {
    return sub {
        my ($self, $s) = @_;

        return AberMUD::Controller->new_with_traits(
            traits   => ['AberMUD::Controller::Role::Test'],
            storage  => $s->param('storage'),
            universe => $s->param('universe'),
        );
    }
}

sub player_logs_in {
    my $self = shift;
    my $name = shift;
    my %params = @_;

    $params{location} ||= $self->fetch('storage')->get->lookup('config')->location;

    my $p = $self->fetch('player')->get;
    $p->input_state([AberMUD::Input::State::Game->new]);

    $p->name($name);
    $p->location($self->fetch('storage')->get->lookup('location-test1'));
    $p->_join_game;
    $p->location($params{location});

    return $p;
}

1;

