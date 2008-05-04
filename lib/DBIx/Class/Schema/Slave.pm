package DBIx::Class::Schema::Slave;

use strict;
use warnings;
use base qw/ DBIx::Class /;
use Clone qw/ clone /;

our $VERSION = '0.02101';

__PACKAGE__->mk_classdata( slave_moniker => '::Slave' );
__PACKAGE__->mk_classdata('slave_connect_info' => [] );
__PACKAGE__->mk_classdata('slave_connection');

=head1 NAME

DBIx::Class::Schema::Slave - L<DBIx::Class::Schema> for slave B<(EXPERIMENTAL)>

=head1 SYNOPSIS

  # In your MyApp::Schema (DBIx::Class::Schema based)
  package MyApp::Schema;

  use base 'DBIx::Class::Schema';

  __PACKAGE__->load_components( qw/ Schema::Slave / );
  __PACKAGE__->slave_moniker('::Slave');
  __PACKAGE__->slave_connect_info( [
      [ 'dbi:mysql:database:hostname=host', 'username', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'username', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'username', 'passsword', { ... } ],
      ...,
  ] );

  # As it is now, DBIx::Class::Schema::Slave works out with DBIx::Class::Schema::Loader.
  # If you use DBIx::Class::Schema::Loader based MyApp::Schema, maybe it is just like below.

  # In your MyApp::Schema (DBIx::Class::Schema::Loader based)
  package MyApp::Schema;

  use base 'DBIx::Class::Schema::Loader';

  __PACKAGE__->load_components( qw/ Schema::Slave / );
  __PACKAGE__->slave_moniker('::Slave');
  __PACKAGE__->slave_connect_info( [
      [ 'dbi:mysql:database:hostname=host', 'username', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'username', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'username', 'passsword', { ... } ],
      ...,
  ] );
  __PACKAGE__->loader_options(
      relationships => 1,
      components    => [ qw/
          ...
          ...
          ...
          Row::Slave # DO NOT forget to specify
          Core
      / ],
  );

  # Somewhere in your code
  use MyApp::Schema;

  # First, connect to master
  my $schema = MyApp::Schema->connect( @master_connect_info );

  # Retrieving from master
  my $master = $schema->resultset('Track')->find( $id );

  # Retrieving from slave
  my $slave = $schema->resultset('Track::Slave')->find( $id );

See L<DBIx::Class::Schema>.

=head1 DESCRIPTION

DBIx::Class::Schema::Slave is L<DBIx::Class::Schema> for slave.
DBIx::Class::Schema::Slave creates C<result_source> classes for slave automatically,
and connects slave datasources as you like (or at rondom).
You can retrieve rows from either master or slave in the same way L<DBIx::Class::Schema> provies
but you can neither add nor remove rows from slave.

=head1 SETTIN UP DBIx::Class::Schema::Slave

=head2 Setting it up manually

First, you should load DBIx::Class::Schema::Slave as component in your MyApp::Schema.

  # In your MyApp::Schema
  package MyApp::Schema;

  use base 'DBIx::Class::Schema';

  __PACKAGE__->load_components( qw/ Schema::Slave / );

Set L</slave_moniker> as you like. If you do not specify, C<::Slave> is set.

  __PACKAGE__->slave_moniker('::Slave');

Set L</slave_connect_info> as C<ARRAYREF> of C<ARRAYREF>.

  __PACKAGE__->slave_connect_info( [
      [ 'dbi:mysql:database:hostname=host', 'user', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'user', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'user', 'passsword', { ... } ],
      ...,
  ] );

Next, you have MyApp::Schema::Artist, MyApp::Schema::Album, MyApp::Schema::Track, load these C<result_source> classes.

  __PACKAGE__->load_classes( qw/ Artist Album Track / );

In running L</register_source>, DBIx::Class::Schema::Slave creates slave C<result_source> classes
MyApp::Schema::Artist::Slave, MyApp::Schema::Album::Slave and MyApp::Schema::Track::Slave automatically.
If you set C<::MySlave> to L</slave_moniker>, it creates
MyApp::Schema::Artist::MySlave, MyApp::Schema::Album::MySlave and MyApp::Schema::Track::MySlave.

  # MyApp::Schema::Artist wouldn't be loaded
  # MyApp::Schema::Artist::Slave wouldn't be created
  __PACKAGE__->load_classes( qw/ Album Track / );

I recommend every C<result_source> classes to be loaded.

  # Every result_source classes are loaded
  __PACKAGE__->load_classes;

Next, load L<DBIx::Class::Row::Slave> as component in your C<result_source> classes.

  # In your MyApp::Schema::Artist;
  package MyApp::Schema::Artist;

  use base 'DBIx::Class';

  __PACKEAGE__->load_components( qw/ ... Row::Slave Core / );

=head2 Using L<DBIx::Class::Schema::Loader>

As it is now, DBIx::Class::Schema::Slave B<WORKS OUT> with L<DBIx::Class::Schema::Loader>.
First, you should load DBIx::Class::Schema::Slave as component in your MyApp::Schema.

  # In your MyApp::Schema
  package MyApp::Schema;

  use base 'DBIx::Class::Schema::Loader';

  __PACKAGE__->load_components( qw/ Schema::Slave / );

Set L</slave_moniker> as you like. If you do not specify, C<::Slave> is set.

  __PACKAGE__->slave_moniker('::Slave');

Set L</slave_connect_info> as C<ARRAYREF> of C<ARRAYREF>.

  __PACKAGE__->slave_connect_info( [
      [ 'dbi:mysql:database:hostname=host', 'user', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'user', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'user', 'passsword', { ... } ],
      ...,
  ] );

Call L<DBIx::Class::Schema::Loader/loader_options>. B<DO NOT> forget to specify L<DBIx::Class::Row::Slave> as component.

  __PACKAGE__->loader_options(
      relationships => 1,
      components    => [ qw/
          ...
          ...
          ...
          Row::Slave # DO NOT forget to load
          Core
      / ],
  );

=head2 Connecting (Create Schema instance)

To connect your Schema, you provive C<connect_info> not for slave but for master.

  my $schema = MyApp::Schema->connect( @master_connect_info );

=head2 Retrieving

Retrieving from master, you don't have to care about anything.

  my $album_master     = $schema->resultset('Album')->find( $id );
  my $itr_album_master = $schema->resultset('Album')->search( { ... }, { ... } );

Retrieving from slave, you should set slave moniker to L</resultset>.

  my $track_slave     = $schema->resultset('Album::Slave')->find( $id );
  my $itr_track_slave = $schema->resultset('Album::Slave')->search( { ... }, { ... } );

=head2 Adding and removing rows

You can either create a new row or remove some rows from master. But you can neither create a new row nor remove some rows from slave.

  # These complete normally
  my $track = $schema->resultset('Track')->create( {
      created_on  => $dt->now || undef,
      modified_on => $dt->now || undef,
      album_id    => $album->id || undef,
      title       => $title || undef,
      time        => $time || undef,
  } );
  $track->title('WORLD\'S END SUPERNOVA');
  $track->update;
  $track->delete;

  # You got an error!
  # DBIx::Class::ResultSet::create(): Can't insert via result source "Track::Slave". This is slave connection.
  my $track = $schema->resultset('Track::Slave')->create( {
      created_on  => $dt->now || undef,
      modified_on => $dt->now || undef,
      album_id    => $album->id || undef,
      title       => $title || undef,
      time        => $time || undef,
  } );

  $track->title('TEAM ROCK');
  # You got an error!
  # DBIx::Class::Row::Slave::update(): Can't update via result source "Track::Slave". This is slave connection.
  $track->update;

  # And, you got an error!
  # DBIx::Class::Row::Slave::delete(): Can't delete via result source "Track::Slave". This is slave connection.
  $track->delete;

B<DO NOT> call L<DBIx::Class::ResultSet/"update_all">, L<DBIx::Class::ResultSet/"delete_all">, L<DBIx::Class::ResultSet/"populate"> and L<DBIx::Class::ResultSet/"update_or_create"> via slave C<result_source>s.
Also you B<SHOULD NOT> call L<DBIx::Class::ResultSet/"find_or_new">, L<DBIx::Class::ResultSet/"find_or_create"> via slave C<result_source>s.

=head1 CLASS DATA

=head2 slave_moniker

Moniker suffix for slave. C<::Slave> default.

  # In your MyApp::Schema
  __PACKAGE__->slave_moniker('::Slave');

B<IMPORTANT:>
If you have already MyApp::Schema::Artist::Slave, B<DO NOT> set C<::Slave> to C<slave_moniker>.
Set C<::SlaveFor> or something else.

=head2 slave_connect_info

C<connect_info>s C<ARRAYREF> of C<ARRAYREF> for slave.

  # In your MyApp::Schema
  __PACKAGE__->slave_connect_info( [
      [ 'dbi:mysql:database:hostname=host', 'username', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'username', 'passsword', { ... } ],
      [ 'dbi:mysql:database:hostname=host', 'username', 'passsword', { ... } ],
      ...,
  ] );

=head2 slave_connection

Connection for slave stored. You can get this by L</slave>.

=head1 METHODS

=head2 register_source

=over 4

=item Arguments: $moniker, $result_source

=item Return Value: none

=back

Registers the L<DBIx::Class::ResultSource> in the schema with the given moniker
and re-maps C<class_mappings> and C<source_registrations>.

  # Re-mapped class_mappings
  class_mappings => {
      MyApp::Schema::Artist        => 'Artist',
      MyApp::Schema::Artist::Slave => 'Artist::Slave',
      MyApp::Schema::Album         => 'Album',
      MyApp::Schema::Album::Slave  => 'Album::Slave',
      MyApp::Schema::Track         => 'Track',
      MyApp::Schema::Track::Slave  => 'Track::Slave',
  }

  # Re-mapped source_registrations
  source_registrations => {
      MyApp::Schema::Artist => {
          bless( {
              ...,
              ...,
              ...,
          }, DBIx::Class::ResultSource::Table )
      },
      MyApp::Schema::Artist::Slave => {
          bless( {
              ...,
              ...,
              ...,
          }, DBIx::Class::ResultSource::Table )
      },
      ...,
      ...,
      ...,
      MyApp::Schema::Track::Slave => {
          bless( {
              ...,
              ...,
              ...,
          }, DBIx::Class::ResultSource::Table )
      },
  }

See L<DBIx::Class::Schema/"register_source">.

=cut

sub register_source {
    my ( $self, $moniker, $source ) = @_;

    $self->next::method( $moniker, $source );
    unless ( $self->is_slave( $moniker ) ) {
        my $class = ref $self || $self;
        my $slave_moniker = $moniker . $self->slave_moniker;
        my $clone_source  = $self->_clone_source( $source );
        my $slave_source  = $source->new( $clone_source );
        $slave_source->source_name( $slave_moniker );
        $self->next::method( $slave_moniker, $slave_source );
        $self->class_mappings->{$class . '::' . $moniker} =
            $moniker;
        $self->class_mappings->{$class . '::' . $slave_moniker} =
            $slave_moniker;
    }
}

sub _clone_source {
    my ( $self, $source ) = @_;

    my $clone_source = clone( $source );
    foreach my $rel ( keys %{$clone_source->{_relationships}} ) {
        my $rel_hash = $clone_source->{_relationships}->{$rel};
        $rel_hash->{source} = $rel_hash->{source} . $self->slave_moniker
            unless $self->is_slave( $rel_hash->{source} );
        $rel_hash->{class} = $rel_hash->{class} . $self->slave_moniker
            unless $self->is_slave( $rel_hash->{class} );
    }

    return $clone_source;
}

=head2 resultset

=over 4

=item Arguments: $moniker

=item Return Value: $result_set

=back

If C<$moniker> is slave moniker, this method returns C<$result_set> for slave.
See L<DBIx::Class::Schema/"resultset">.

  my $master_rs = $schema->resultset('Artist');
  my $slave_rs  = $schema->resultset('Artist::Slave');

=cut

sub resultset {
    my ( $self, $moniker ) = @_;

    if ( $self->is_slave( $moniker ) ) {
        ## connect slave
        if ( $self->slave ) {
            ## TODO re-select per not ->resultset('Foo::Slave'), but request.
            $self->slave->storage->connect_info( $self->_select_connect_info );
        } else {
            $self->connect_slave( @{$self->_select_connect_info} );
        }
        ## TODO more tidily
        $self->slave->storage->debug( $self->storage->debug );
        $self->slave->storage->debugobj( $self->storage->debugobj );
        $self->slave->next::method( $moniker );
    } else {
        ## connect master
        $self->next::method( $moniker );
    }
}

=head2 sources

=over 4

=item Argunemts: none

=item Return Value: @sources

=back

This method returns the sorted alphabetically source monikers of all source registrations on this schema.
See L<DBIx::Class::Schema/"sources">.

  # Returns all sources including slave sources
  my @all_sources = $schema->sources;

=cut

sub sources {
    my $self = shift;

    $self->next::method( @_ );
    return sort( { $b cmp $a } keys( %{$self->source_registrations} ) );
}

=head2 master_sources

=over 4

=item Argunemts: none

=item Return Value: @sources

=back

This method returns the sorted alphabetically master source monikers of all source registrations on this schema.

  my @master_sources = $schema->master_sources;

=cut

sub master_sources {
    my $self = shift;

    my $slave_moniker = $self->slave_moniker;
    return grep { $_ !~ m/$slave_moniker$/o } $self->sources;
}

=head2 slave_sources

=over 4

=item Argunemts: none

=item Return Value: @sources

=back

This method returns the sorted alphabetically slave source monikers of all source registrations on this schema.

  my @slave_sources = $schema->slave_sources;

=cut

sub slave_sources {
    my $self = shift;

    my $slave_moniker = $self->slave_moniker;
    return grep { $_ =~ m/$slave_moniker$/o } $self->sources;
}

=head2 connect_slave

=over 4

=item Arguments: @info

=item Return Value: $slave_schema

=back

This method creates slave connection, and store it in C<slave_connection>. You can get this by L</slave>.
Usualy, you don't have to call it directry.

=cut

sub connect_slave { $_[0]->slave_connection( shift->connect( @_ ) ) }

=head2 slave

Getter for L</slave_connection>. You can get schema for slave if it stored in L</slave_connection>.

  my $slave_schema = $schema->slave;

=cut

#*slave = \&DBIx::Class::Slave::slave_connection;
sub slave { shift->slave_connection }

=head2 select_connect_info

=over 4

=item Argunemts: none

=item Return Value: $connect_info

=back

You can define this method in your schema class as you like. This method has to return C<$connect_info> as C<ARRAYREF>.
If L</select_connect_info> returns C<undef> or undef value or not C<ARRAYREF>, L</_select_connect_info> will be called,
and return C<$connect_info> at random from L</slave_connect_info>.

  # In your MyApp::Schame
  sub select_connect_info {
      my $self = shift;

      my @connect_info = @{$self->slave_connect_info};
      my $connect_info;
      # Some algorithm to select connect_info here

      return $connect_info;
  }

=cut

sub select_connect_info {}

=head2 is_slave

=over 4

=item Arguments: $string

=item Return Value: 1 or 0

=back

This method returns 1 if C<$string> (moniker, class name and so on) is slave stuff, otherwise returns 0.

  __PACKAGE__->slave_moniker('::Slave');

  # Returns 0
  $self->is_slave('Artist');

  # Returns 1
  $self->is_slave('Artist::Slave');

  # Returns 1
  $self->is_slave('MyApp::Model::DBIC::MyApp::Artist::Slave');

  __PACKAGE__->slave_moniker('::SlaveFor');

  # Returns 0
  $self->is_slave('Artist');

  # Returns 1
  $self->is_slave('Artist::SlaveFor');

  # Returns 1
  $self->is_slave('MyApp::Model::DBIC::MyApp::Artist::SlaveFor');

=cut

sub is_slave {
    my ( $self, $string ) = @_;

    my $match = $self->slave_moniker;
    return $string =~ m/$match$/o ? 1 : 0;
}

=head1 INTERNAL METHOD

=head2 _select_connect_info

=over 4

=item Return Value: $connect_info

=back

Internal method. This method returns C<$connect_info> for slave as C<ARRAYREF>.
Usually, you don't have to call it directry.
If you select C<$connect_info> as you like, define L</select_connect_info> in your schema class.
See L</select_connect_info> for more information.

=cut

sub _select_connect_info {
    my $self = shift;

     my $info = $self->can('select_connect_info')
             && $self->select_connect_info
             && ref $self->select_connect_info eq 'ARRAY'
          ? $self->select_connect_info
          : $self->slave_connect_info->[ rand @{$self->slave_connect_info} ];
           
#      warn "Select slave_connect_info @{$info}\n";
      return $info;
}

=head1 AUTHOR

travail C<travail@cabane.no-ip.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
