package DBIx::DBH;

use 5.006001;
use strict;
use warnings;

use Data::Dumper;

use DBI;
use Params::Validate qw( :all );

our $VERSION = '0.11';

our @attr = qw
  (  
   dbi_connect_method
   Warn

   _Active
   _Executed
   _Kids
   _ActiveKids
   _CachedKids
   _CompatMode

   InactiveDestroy
   PrintWarn
   PrintError
   RaiseError
   HandleError
   HandleSetErr

   _ErrCount

   ShowErrorStatement
   TraceLevel
   FetchHashKeyName
   ChopBlanks
   LongReadLen
   LongTruncOk
   TaintIn
   TaintOut
   Taint
   Profile
   _should-add-support-for-private_your_module_name_*


   AutoCommit

   _Driver
   _Name
   _Statement

   RowCacheSize

   _Username
  );

# Preloaded methods go here.

Params::Validate::validation_options(allow_extra => 1);

sub connect {

  my @connect_data = connect_data(@_);

  my $dbh;
  eval
    {
      $dbh = DBI->connect( @connect_data );
    };

  die $@ if $@;
  die 'Unable to connect to database' unless $dbh;

  return $dbh;

}

sub dbi_attr {
  my ($h, %p) = @_;

  $h = {} unless defined $h;

  for my $attr (@attr) {
    if (exists $p{$attr}) {
#      warn "$attr = $p{$attr};";
      $h->{$attr} = $p{$attr};
    }
  }

  $h;
}

sub connect_data {

  my $class = shift;
  my %p = @_;

  my $subclass = "DBIx::DBH::$p{driver}";
  eval "require $subclass";
  die "unable to require $subclass to support the $p{driver} driver.\n" if $@;

  my ($dsn, $user, $pass, $attr) = $subclass->connect_data(@_);
  $attr = dbi_attr($attr, %p);

  ($dsn, $user, $pass, $attr)

}

sub form_dsn {

  (connect_data(@_))[0];

}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

 DBIx::DBH - Perl extension for simplifying database connections

=head1 SYNOPSIS

 use DBIx::DBH;

 my %opt = (tty => 1) ;
 my %dat = ( 
     driver => 'Pg',
     dbname => 'db_terry',
     user => 'terry',
     password => 'markso'
 );

 my $dbh = DBIx::DBH->connect(%dat, %opt) ;

=head1 ABSTRACT

DBIx::DBH is designed to facilitate and validate the process of creating 
DBI database connections.
It's chief and unique contribution to this set of modules on CPAN is that
it forms the DSN string for you, regardless of database driver. Another thing 
about this module is that
it takes a flat Perl hash 
as input, making it ideal for converting HTTP form data 
and or config file information into DBI database handles. It also can form
DSN strings for both major free databases and is subclassed to support
extension for other databases.

DBIx::DBH provides rigorous validation on the input parameters via
L<Params::Validate>. It does not
allow parameters which are not defined by the DBI or the database driver
driver into the hash.

I provides support for MySQL, Postgres and Sybase (thanks to Rachel Richard 
for the Sybase support). 

=head1 DBIx::DBH API

=head2 $dbh = connect(%params)

C<%params> requires the following as keys:

=over 4

=item * driver : the value matches /\a(mysql|Pg)\Z/ (case-sensitive).

=item * dbname : the value is the name of the database to connect to

=back

C<%params> can have the following optional parameters

=over 4

=item * user

=item * password

=item * host

=item * port

=back

C<%params> can also have parameters specific to a particular database
driver. See
L<DBIx::DBH::Sybase>,
L<DBIx::DBH::mysql> and L<DBIx::DBH::Pg> for additional parameters
acceptable based on database driver.

=head2 ($dsn, $user, $pass, $attr) = connect_data(%params)

C<connect_data> takes the same arguments as C<connect()> but returns
a list of the 4 arguments required by the L<DBI> C<connect()>
function. This is useful for working with modules that have an
alternative connection syntax such as L<DBIx::AnyDBD> or 
L<Alzabo>.

=head2 ($dsn, $user, $pass, $attr) = connect_data(%params)

C<connect_data> takes the same arguments as C<connect()> but returns
a list of the 4 arguments required by the L<DBI> C<connect()>
function. This is useful for working with modules that have an
alternative connection syntax such as L<DBIx::AnyDBD> or 
L<Alzabo>.

=head2 $dsn = form_dsn(%params)

C<form_dsn> takes the same arguments as C<connect()> but returns
only the properly formatted DSN string. This is also 
useful for working with modules that have an
alternative connection syntax such as L<DBIx::AnyDBD> or 
L<Alzabo>.

=head1 ADDING A DRIVER

Simply add a new driver with a name of C<DBIx::DBH::$Driver>, where
C<$Driver> is a valid DBI driver name.

=back

=head1 SEE ALSO

=over

=item * L<Config::DBI>

=item * L<DBIx::Connect>

=item * L<DBIx::Password>

=item * L<Ima::DBI>

=back

=head1 TODO

=over

=item * expose parm validation info:

 > 
 > It would be nice if the parameter validation info was exposed in some 
 > way, so that an interactive piece of software can ask a user which 
 > driver they want, then query your module for a list of supported 
 > parameters, then ask the user to fill them in. (Perhaps move the hash 
 > of validation parameters to a new method named valid_params, and then 
 > have connect_data call that method and pass the return value to 
 > validate?)

=cut

=head1 AUTHOR

Terrence Brannon, E<lt>bauhaus@metaperl.comE<gt>

Sybase support contributed by Rachel Richard.

Mark Stosberg did all of the following:

=over

=item * contributed Sqlite support

=item * fixed a documentation bug

=item * made DBIx::DBH more scaleable

Says Mark: "Just as DBI needs no modifications for a new driver to work,
neither should this module.

I've attached a patch which refactors the code to address this.

Rather than relying on a hardcoded list, it tries to 'require' the
driver, or dies with a related error message.

This could lower your own maintenance effort, as others can publish
additional drivers directly without requiring a new release of
DBIx::DBH for it to work."

L<http://rt.cpan.org/Ticket/Display.html?id=18026>

=back



Substantial suggestions by M. Simon Ryan Cavaletto.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Terrence Brannon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
