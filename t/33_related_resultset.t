use strict;
use warnings;

use Test::More;
use lib qw( t/lib );
use DBICTest;

BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 8 );
}

my $schema = DBICTest->init_schema;

# master
my $m_cd = $schema->resultset('Artist')->related_resultset('cds')->find(1);
is($m_cd->is_slave,0,'master artist "related_resultset"');
is($m_cd->cdid,1,'master artist "related_result_set"');

my $m_track = $schema->resultset('CD')->related_resultset('tracks')->find(1);
is($m_track->is_slave,0,'master cd "related_resultset"');
is($m_track->trackid,1,'master artist "related_result_set"');

# slave
my $s_cd = $schema->resultset('Artist::Slave')->related_resultset('cds')->find(1);
is($s_cd->is_slave,1,'slave artist "related_resultset"');
is($s_cd->cdid,1,'slave artist "related_result_set"');

my $s_track = $schema->resultset('CD::Slave')->related_resultset('tracks')->find(1);
is($s_track->is_slave,1,'slave cd "related_resultset"');
is($s_track->trackid,1,'slave artist "related_result_set"');
