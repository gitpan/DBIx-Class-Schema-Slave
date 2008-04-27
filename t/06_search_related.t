use strict;
use warnings;

use Test::More;
use lib qw( t/lib );
use DBICTest;

BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 10 );
}

my $schema = DBICTest->init_schema;
my $cd_title = 'Tanz Walzer';
my $track_title = 'JUBILEE';

## find from master artist
my $m_artist = $schema->resultset('Artist')->find(1);
is($m_artist->is_slave,0,'master artist "search_related"');

my $m_cd = $m_artist->search_related('cds', {title => $cd_title},{order_by => 'cdid ASC'})->first;
is($m_cd->is_slave,0,'master cd "search_related"');
is($m_cd->title, $cd_title, 'master cd "search_related"');

my $m_track = $m_artist->cds->search_related('tracks', {'tracks.title' => $track_title},{order_by => 'trackid ASC'})->first;
is($m_track->is_slave,0,'master track "search_related"');
is($m_track->title, $track_title, 'master track "search_related"');

## find from slave artist
my $s_artist = $schema->resultset('Artist')->find(1);
is($s_artist->is_slave,0,'slave artist "search_related"');

my $s_cd = $s_artist->search_related('cds', {title => $cd_title},{order_by => 'cdid ASC'})->first;
is($s_cd->is_slave,0,'slave cd "search_related"');
is($s_cd->title, $cd_title, 'slave cd "search_related"');

my $s_track = $s_artist->cds->search_related('tracks', {'tracks.title' => $track_title},{order_by => 'trackid ASC'})->first;
is($s_track->is_slave, 0, 'slave track "search_related"');
is($s_track->title, $track_title, 'slave track "search_related"');
