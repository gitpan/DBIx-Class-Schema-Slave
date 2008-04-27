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
my @artist = ("QURULI","Spangle call Lilli line");
my @cd = ("Tanz Walzer","TRACE","or","Nanae","Spangle call Lilli line");
my @track = (
    "HEILIGENSTADT",
    "BREMEN",
    "JUBILEE",
    "MILLION BUBBLES IN MY MIND",
    "ANARCHY IN THE MUSIK",
    "RENNWEG WALTZ",
    "CLOCK",
    "SCHINKEN",
    "SLAV",
    "CONTINENTAL",
    "SLOWDANCE",
    "CAFE' HAWELKACAFE",
    "BLUE LOVER BLUE",
    "tty",
    "mila",
    "U-Lite",
    "corner",
    "canaria",
    "reappearing rig",
    "stereo",
    "R.G.B.",
    "sugar",
    "piano",
    "rrr",
    "dism",
    "B",
    "nano",
    "ma",
    "metro",
    "carb cola",
    "ice track",
    "soto",
    "intro",
    "E",
    "Lilli Disco",
    "Veek",
    "Circle",
    "Crawl",
    "Set Me",
    "Low Light",
    "B.P.",
    "Asphalt",
    "normal star",
    "IRIE",
    "new crawl",
    "under north sour",
    "error slow",
    "August (8)",
    "(untitle)",
    "U.F.",
);

## find from master artist
my @m_artist = $schema->resultset('Artist')->search({},{order_by => 'artistid ASC'})->get_column('name')->all;
is(@m_artist,@artist,'master artist "get_column"');

my @m_cd = $schema->resultset('CD')->search({},{order_by => 'cdid ASC'})->get_column('title')->all;
is(@m_cd,@cd,'master cd "get_columb"');

my @m_track = $schema->resultset('Track')->search({},{order_by => 'trackid ASC'})->get_column('title')->all;
is(@m_track,@track,'master track "get_column"');

## find from slave artist
my @s_artist = $schema->resultset('Artist::Slave')->search({},{order_by => 'artistid ASC'})->get_column('name')->all;
is(@s_artist,@artist,'slave artist "get_column"');

my @s_cd = $schema->resultset('CD::Slave')->search({},{order_by => 'cdid ASC'})->get_column('title')->all;
is(@s_cd,@cd,'slave cd "get_column"');

my @s_track = $schema->resultset('Track::Slave')->search({},{order_by => 'trackid ASC'})->get_column('title')->all;
is(@s_track,@track,'slave track "get_column"');

