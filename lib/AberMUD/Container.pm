#!/usr/bin/env perl
package AberMUD::Container;
use Moose;
use Bread::Board;
use Scalar::Util qw(weaken isweak);

use AberMUD::Storage;
use AberMUD::Controller;
use AberMUD::Universe;
use AberMUD::Player;
use AberMUD::Location;
use AberMUD::Object;
use AberMUD::Mobile;
use AberMUD::Object::Role::Getable;
use AberMUD::Object::Role::Weapon;

use AberMUD::Util ();

use namespace::autoclean;

has container => (
    is         => 'rw',
    isa        => 'Bread::Board::Container',
    lazy_build => 1,
    builder    => '_build_container',
    handles    => [qw(fetch param)],
);

has dsn => (
    is  => 'ro',
    isa => 'Str',
    default => AberMUD::Util::dsn,
);

has controller_block => (
    is      => 'ro',
    isa     => 'Maybe[CodeRef]',
    builder => '_build_controller_block',
    lazy    => 1,
);

sub _build_controller_block { undef }

has universe_block => (
    is  => 'ro',
    isa => 'Maybe[CodeRef]',
    builder => '_build_universe_block',
    lazy    => 1,
);

sub _build_universe_block {
    return sub {
        my ($self, $service) = @_;

        my $config = $service->param('storage')->lookup('config')
            or die "No config found in kdb!";

        my $u = $config->universe;

        $u->storage($service->param('storage'));
        $u->_controller($service->param('controller'));
        $u->players(+{});
        $u->players_in_game(+{});

        weaken(my $weakservice = $service);
        $u->spawn_player_code(
            sub {
                my $self     = shift;
                my $id       = shift;
                my $player   = $self->fetch('player')->get(
                    id          => $id,
                    prompt      => '&*[ &+C%h/%H&* ] &+Y$&* ',
                    location    => $config->location,
                    input_state => [
                        map {
                            $weakservice->param('controller')->get_input_state(
                                "AberMUD::Input::State::$_"
                            )
                        } @{ $config->input_states }
                    ],
                );

                return $player;
            }
        );

        return $u;
    }
}

has player_block => (
    is  => 'ro',
    isa => 'Maybe[CodeRef]',
    builder => '_build_player_block',
);

sub _build_player_block { undef }

sub _build_container {
    my $self = shift;

    weaken(my $weakself = $self);
    my $c = container 'AberMUD' => as {

        my %player_args;
        if ($self->player_block) {
            $player_args{block} = sub {
                $weakself->player_block->($weakself, @_)
            };
        }
        else {
            $player_args{parameters} = {
                id          => { isa => 'Str' },
                prompt      => { isa => 'Str' },
                location    => { isa => 'AberMUD::Location' },
                input_state => { isa => 'ArrayRef' },
            };
        }

        my %controller_args;
        $controller_args{block} = sub {
            $weakself->controller_block->($weakself, @_)
        } if $self->controller_block;

        service storage => (
            class     => 'AberMUD::Storage',
            lifecycle => 'Singleton',
            block     => sub {
                return AberMUD::Storage->new(
                    dsn => $weakself->dsn,
                );
            },
        );

        service universe => (
            class => 'AberMUD::Universe',
            lifecycle => 'Singleton',
            block     => sub { $weakself->universe_block->($weakself, @_) },
            dependencies => [
                depends_on('storage'),
                depends_on('controller'),
            ],
        );

        service player => (
            class => 'AberMUD::Player',
            dependencies => [
                depends_on('storage'),
                depends_on('universe'),
            ],
            %player_args,
        );

        service controller => (
            class     => 'AberMUD::Controller',
            lifecycle => 'Singleton',
            %controller_args,
            dependencies => [
                depends_on('storage'),
                depends_on('universe'),
            ]
        );

        service app => (
            class => 'AberMUD',
            lifecycle => 'Singleton',
            dependencies => [
                depends_on('storage'),
                depends_on('controller'),
                depends_on('universe'),
            ]
        );
    };
}

1;

__END__

=head1 NAME

AberMUD::Container - wires all the AberMUD components together

=head1 SYNOPSIS

  use AberMUD::Container;
  
  my $c = AberMUD::Container->new->container;
  $c->fetch('app')->get->run;

=head1 DESCRIPTION

See L<Bread::Board> for more information.

