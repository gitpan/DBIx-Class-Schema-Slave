use strict;
use warnings;

use Test::More;
use lib qw( t/lib );
use DBICTest;

BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 6 );
}

my $schema = DBICTest->init_schema;
my $count_artist = 2;
my $count_cd = 5;
my $count_track = 50;

## master
my $itr_m_artist = $schema->resultset('Artist')->search;
is($itr_m_artist->count,$count_artist,'master artist "count"');

my $itr_m_cd = $schema->resultset('CD')->search;
is($itr_m_cd->count,$count_cd,'master cd "count"');

my $itr_m_track = $schema->resultset('Track')->search;
is($itr_m_track->count,$count_track,'master track "count"');

## slave
my $itr_s_artist = $schema->resultset('Artist::Slave')->search;
is($itr_s_artist->count,$count_artist,'slave artist "count"');

my $itr_s_cd = $schema->resultset('CD::Slave')->search;
is($itr_s_cd->count,$count_cd,'slave cd "count"');

my $itr_s_track = $schema->resultset('Track::Slave')->search;
is($itr_s_track->count,$count_track,'slave track "count"');
