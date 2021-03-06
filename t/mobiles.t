#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use AberMUD::Test::Sugar qw(build_preset_game);
use AberMUD::Util;

my $c = build_preset_game(
    'two_wide',
    extra => [
        {
            locations => {
                room1 => {
                    has_mobiles => {
                        knight => {
                            description => 'A knight is standing here.',
                            pname => 'Knight',
                            examine => 'very metallic',
                            basestrength => 100,
                        },
                    },
                },
            },
        },
    ],
);

my $u = $c->universe;
my $b = $c->controller->backend;

ok(my @m = $u->get_mobiles, 'mobiles loaded');

my %mobiles                       = map { $_->name => $_ } @m;
my ($one, $conn_one)              = $b->new_player('playerone');

ok($mobiles{knight});
ok($mobiles{knight}->description);

is($one->location, $mobiles{knight}->location);

like($b->inject_input($conn_one, 'look'),           qr{knight is standing here});
like($b->inject_input($conn_one, 'examine knight'), qr{very metallic});

done_testing();
