#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Moose;
use AberMUD::Test::Sugar ();

can_ok('AberMUD::Test::Sugar', 'build_game');

my ($c, $locations) = AberMUD::Test::Sugar::build_game(
    zone => 'test',
    default_location => 'myloc',
    locations => {
        myloc => {
            title => 'foo',
            description => 'bar',
            has_objects => {
                myobj => {
                    description => 'myobj desc',
                },
            },
            has_mobiles => {
                mobz => {
                    description => 'mobz desc',
                },
                moby => {
                    description => 'moby desc',
                    carrying => {
                        withmoby => {
                            description => 'obj with moby',
                        }
                    },
                },
                mobx => {
                    description => 'mobx desc',
                    wielding => {
                        withmobx => {
                            description => 'obj with mobx',
                            damage      => 5,
                        }
                    },
                },
                mobw => {
                    description => 'mobw desc',
                    wearing => {
                        withmobw => {
                            description => 'obj with mobx',
                            covers      => ['head'],
                        }
                    },
                },
            },
        },
    }
);

ok(my $u = $c->resolve(service => 'universe'));
ok($u->get_mobiles);

my %mobs = map { $_->name => $_ } $u->get_mobiles;
my %objs = map { $_->name => $_ } $u->get_objects;

ok($locations->{myloc});
is($locations->{myloc}->title,       'foo');
is($locations->{myloc}->description, 'bar');
ok($mobs{$_}) for qw(mobz moby mobx mobw);

ok($objs{$_}) for qw(myobj withmoby withmobx withmobw);

does_ok($objs{withmoby}, 'AberMUD::Object::Role::Getable');

does_ok($objs{withmobx}, 'AberMUD::Object::Role::Weapon');
does_ok($objs{withmobx}, 'AberMUD::Object::Role::Getable');

does_ok($objs{withmobw}, 'AberMUD::Object::Role::Wearable');
does_ok($objs{withmobw}, 'AberMUD::Object::Role::Getable');

done_testing();