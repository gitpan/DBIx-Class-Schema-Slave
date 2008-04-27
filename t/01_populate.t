use strict;
use warnings;

use Test::More;
use lib qw( t/lib );
use DBICTest;

BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 1 );
}

my $schema = DBICTest->init_schema;

diag("Create some records.");
my $itr_artist = $schema->resultset('Artist::Slave')->search;
while ( my $artist = $itr_artist->next ) {
    diag(sprintf q{%s is created}, $artist->name);
}

my $itr_cd = $schema->resultset('CD::Slave')->search;
while ( my $cd = $itr_cd->next  ) {
    diag(sprintf q{%s by %s is created}, $cd->title, $cd->artist->name);
}
my $itr_track = $schema->resultset('Track::Slave')->search;
while ( my $track = $itr_track->next  ) {
    diag(sprintf q{%s by %s is created}, $track->title, $track->cd->artist->name);
}

ok(-f "t/var/DBIxClass.db", 'Database created');
