package # hide from PAUSE 
    DBICTest;

use strict;
use warnings;
use DBICTest::Schema;

=head1 NAME

DBICTest - Library to be used by DBIx::Class test scripts.

=head1 SYNOPSIS

  use lib qw(t/lib);
  use DBICTest;
  use Test::More;
  
  my $schema = DBICTest->init_schema();

=head1 DESCRIPTION

This module provides the basic utilities to write tests against 
DBIx::Class.

=head1 METHODS

=head2 init_schema

  my $schema = DBICTest->init_schema(
    no_deploy=>1,
    no_populate=>1,
  );

This method removes the test SQLite database in t/var/DBIxClass.db 
and then creates a new, empty database.

This method will call deploy_schema() by default, unless the 
no_deploy flag is set.

Also, by default, this method will call populate_schema() by 
default, unless the no_deploy or no_populate flags are set.

=cut

sub _database {
    my $self = shift;
    my $db_file = "t/var/DBIxClass.db";

    unlink($db_file) if -e $db_file;
    unlink($db_file . "-journal") if -e $db_file . "-journal";
    mkdir("t/var") unless -d "t/var";

    my $dsn = $ENV{"DBICTEST_DSN"} || "dbi:SQLite:${db_file}";
    my $dbuser = $ENV{"DBICTEST_DBUSER"} || '';
    my $dbpass = $ENV{"DBICTEST_DBPASS"} || '';

    my @connect_info = ($dsn, $dbuser, $dbpass, { AutoCommit => 1 });
    use Data::Dumper;

    return @connect_info;
}

sub init_schema {
    my $self = shift;
    my %args = @_;

    my $schema;

    if ($args{compose_connection}) {
      $schema = DBICTest::Schema->compose_connection(
                  'DBICTest', $self->_database
                );
    } else {
      $schema = DBICTest::Schema->compose_namespace('DBICTest');
    }
    if ( !$args{no_connect} ) {
      $schema = $schema->connect($self->_database);
      $schema->storage->on_connect_do(['PRAGMA synchronous = OFF']);
    }
    if ( !$args{no_deploy} ) {
        __PACKAGE__->deploy_schema( $schema );
        __PACKAGE__->populate_schema( $schema ) if( !$args{no_populate} );
    }
    return $schema;
}

=head2 deploy_schema

  DBICTest->deploy_schema( $schema );

This method does one of two things to the schema.  It can either call 
the experimental $schema->deploy() if the DBICTEST_SQLT_DEPLOY environment 
variable is set, otherwise the default is to read in the t/lib/sqlite.sql 
file and execute the SQL within. Either way you end up with a fresh set 
of tables for testing.

=cut

sub deploy_schema {
    my $self = shift;
    my $schema = shift;

    if ($ENV{"DBICTEST_SQLT_DEPLOY"}) {
        return $schema->deploy();
    } else {
        open IN, "t/lib/sqlite.sql";
        my $sql;
        { local $/ = undef; $sql = <IN>; }
        close IN;
        ($schema->storage->dbh->do($_) || print "Error on SQL: $_\n") for split(/;\n/, $sql);
    }
}

=head2 populate_schema

  DBICTest->populate_schema( $schema );

After you deploy your schema you can use this method to populate 
the tables with test data.

=cut

sub populate_schema {
    my $self = shift;
    my $schema = shift;

    $schema->populate('Artist', [
        [ qw/artistid name/ ],
        [ 1, 'QURULI' ],
        [ 2, 'Spangle call Lilli line' ],
    ]);

    $schema->populate('CD', [
        [ qw/cdid artist title year/ ],
        [ 1, 1, "Tanz Walzer", 2007 ],
        [ 2, 2, "TRACE", 2005 ],
        [ 3, 2, "or", 2003 ],
        [ 4, 2, "Nanae", 2001 ],
        [ 5, 2, "Spangle call Lilli line", 2001 ],
    ]);

    $schema->populate('Track', [
        [ qw/trackid cd  position title/ ],
        [ 1, 1, 1, "HEILIGENSTADT"],
        [ 2, 1, 2, "BREMEN"],
        [ 3, 1, 3, "JUBILEE"],
        [ 4, 1, 4, "MILLION BUBBLES IN MY MIND"],
        [ 5, 1, 5, "ANARCHY IN THE MUSIK"],
        [ 6, 1, 6, "RENNWEG WALTZ"],
        [ 7, 1, 7, "CLOCK"],
        [ 8, 1, 8, "SCHINKEN"],
        [ 9, 1, 9, "SLAV"],
        [ 10, 1, 10, "CONTINENTAL"],
        [ 11, 1, 11, "SLOWDANCE"],
        [ 12, 1, 12, "CAFE' HAWELKACAFE"],
        [ 13, 1, 13, "BLUE LOVER BLUE"],
        [ 14, 2, 1, "tty"],
        [ 15, 2, 2, "mila"],
        [ 16, 2, 3, "U-Lite"],
        [ 17, 2, 4, "corner"],
        [ 18, 2, 5, "canaria"],
        [ 19, 2, 6, "reappearing rig"],
        [ 20, 2, 7, "stereo"],
        [ 21, 2, 8, "R.G.B."],
        [ 22, 2, 9, "sugar"],
        [ 23, 3, 1, "piano" ],
        [ 24, 3, 2, "rrr" ],
        [ 25, 3, 3, "dism" ],
        [ 26, 3, 4, "B" ],
        [ 27, 3, 5, "nano" ],
        [ 28, 3, 6, "ma" ],
        [ 29, 3, 7, "metro" ],
        [ 30, 3, 8, "carb cola" ],
        [ 31, 3, 9, "ice track" ],
        [ 32, 3, 10, "soto" ],
        [ 33, 4, 1, "intro" ],
        [ 34, 4, 2, "E" ],
        [ 35, 4, 3, "Lilli Disco" ],
        [ 36, 4, 4, "Veek" ],
        [ 37, 4, 5, "Circle" ],
        [ 38, 4, 6, "Crawl" ],
        [ 39, 4, 7, "Set Me" ],
        [ 40, 4, 8, "Low Light" ],
        [ 41, 4, 9, "B.P." ],
        [ 42, 4, 10, "Asphalt" ],
        [ 43, 5, 1, "normal star" ],
        [ 44, 5, 2, "IRIE" ],
        [ 45, 5, 3, "new crawl" ],
        [ 46, 5, 4, "under north sour" ],
        [ 47, 5, 5, "error slow" ],
        [ 48, 5, 6, "August (8)" ],
        [ 49, 5, 7, "(untitle)" ],
        [ 50, 5, 8, "U.F." ],
    ]);
}

1;
