package DBIx::DBH;

use Moose;
use Moose::Util::TypeConstraints;
use DBI;

has [ 'username', 'password' ] => (is => 'rw', isa => 'Str');

subtype 'DSNHashRef'  => as 'HashRef'  => where { defined($_->{driver}) };

has 'dsn'  => (is => 'rw', isa => 'DSNHashRef', required => 1);
has 'attr' => (is => 'rw', isa => 'HashRef');


sub dsn_string {
  my($self)=@_;

  my %dsn = % { $self->dsn } ;
  my $driver = delete($dsn{driver});
  my $dsn = "dbi:$driver";

  $dsn .= ";$_=$dsn{$_}"  for ( sort keys %dsn );

  $dsn;
}

sub for_dbi {
  my($self)=@_;
  ($self->dsn_string, $self->username, $self->password, $self->attr);
}

sub for_rose_db {
  my($self)=@_;

  (
   username => $self->username,
   password => $self->password,
   %{$self->dsn}
  )
}

sub dbh {
  my($self)=@_;

  use DBI;

  my $dbh = DBI->connect($self->for_dbi)
}

sub conn {
  my($self)=@_;

  require DBIx::Connector;

  my $dbh = DBIx::Connector->new($self->for_dbi);

}


our $VERSION = '0.3';





1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

 DBIx::DBH - helper for DBI connection( data)?

=head1 SYNOPSIS

 use DBIx::DBH;

 my $config = DBIx::DBH->new
   (
     user => $user,
     pass => $pass,
     dsn  => { driver => 'mysql', port => 3306 },
     attr => { RaiseError => 1 }
   );

 $config->for_rose_db; # outputs data structure for Rose::DB::register_db
 $config->for_dbi;     # outputs data structure for DBI connect()
 $config->dbh;  # makes a database connection with DBI
 $config->conn; # makes a DBIx::Connector instance

=head1 ABSTRACT

L<DBIx::DBH> allows you to specify the DBI dsn ( L<DBI/"connect> )
as a hash ref instead of a string. A hashref is a more viable structure
in a few cases:

=over 4

=item * working with Rose::DB

L<Rose::DB::Tutorial/Registering_data_sources> shows that L<Rose::DB>
expects the dsn information as discrete key-value pairs as opposed to
a string. The C<< ->for_rose_db >> method takes the DBIx::DBH instance
and returns a hash array which can be consumed by L<Rose::DB/register_db>

=item * programmatic connection attempts

It is much easier to manipulate a hash programmatically if you need to 
systematically modify it as part of a series of connection attempts.

=item * high-level structure

Whether you are talking about configuration file utilities or form data,
most data from these modules comes back directly as hashes. So you have
a more direct way of shuttling data into a database connection if you 
use this module:

   my $dbh = DBIx::DBH->(dsn => $cgi->form_data->{dsn})->dbh;

Instead of a bunch of string twiddling.

=back

=head1 METHODS

=head1 Legacy Version

A procedural version of DBIx::DBH is still available as
L<DBIx::DBH::Legacy>.

=head1 SEE ALSO

=over

=item * L<Config::DBI>

=item * L<DBIx::Connect>

=item * L<DBIx::Password>

=item * L<Ima::DBI>

=back

=head2 Links

=head3 "Avoiding compound data in software and system design"

L<http://perlmonks.org/?node_id=835894>



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

=head1 SOURCECODE

L<http://github.com/metaperl/dbix-dbh>

=head1 COPYRIGHT AND LICENSE

Copyright (C) by Terrence Brannon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
