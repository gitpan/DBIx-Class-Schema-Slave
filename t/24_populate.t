use strict;
use warnings;

use Test::More;
use lib qw( t/lib );
use DBICTest;

BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 25 );
}

my @artist = ({artistid => 3,name => 'AIR'});
my @cd = ({cdid => 6,artist => 3,title => 'Nayuta',year => 2008});
my @track = (
    {trackid => 51,cd => 6,position => 1,title => "Dawning"},
    {trackid => 52,cd => 6,position => 2,title => "Nayuta"},
    {trackid => 53,cd => 6,position => 3,title => "Janaica"},
    {trackid => 54,cd => 6,position => 4,title => "Surfriders"},
    {trackid => 55,cd => 6,position => 5,title => "Holy Sorry"},
    {trackid => 56,cd => 6,position => 6,title => "Kaze (ninoru)"},
    {trackid => 57,cd => 6,position => 7,title => "Only Just"},
    {trackid => 58,cd => 6,position => 8,title => "Have Fun (The Far East mix)"},
    {trackid => 59,cd => 6,position => 9,title => "Microcosm"},
);

## slave
my $schema = DBICTest->init_schema;

my $s_artist_rs = $schema->resultset('Artist::Slave');
eval{my $tmp = $s_artist_rs->populate(\@artist)};
like($@,qr/DBIx::Class::ResultSet::populate()/,'slave artist "populate"');

my $s_cd_rs = $schema->resultset('CD::Slave');
eval{my $tmp = $s_cd_rs->populate(\@cd)};
like($@,qr/DBIx::Class::ResultSet::populate()/,'slave cd "populate"');

my $s_track_rs = $schema->resultset('Track::Slave');
eval{my $tmp = $s_track_rs->populate( \@track )};
like($@,qr/DBIx::Class::ResultSet::populate()/,'slave track "populate"');

## master
my $m_artist_rs = $schema->resultset('Artist');
my ( $m_artist ) = $m_artist_rs->populate(\@artist);
is($m_artist->is_slave,0,'master artist "populate"');
is($m_artist->name,'AIR','master artist "populate"');

my $m_cd_rs = $schema->resultset('CD');
my ( $m_cd ) = $m_cd_rs->populate(\@cd);
is($m_cd->is_slave,0,'master cd "populate"');
is($m_cd->title,'Nayuta','master cd "populate"');

my $m_track_rs = $schema->resultset('Track');
my ( @m_track ) = $m_track_rs->populate( \@track );
my $count = 0;
foreach my $m_track ( @m_track ) {
    is($m_track->is_slave,0,'master track "populate"');    
    is($m_track->title,$track[$count]->{title},'master track "populate"');
    $count++;
}
