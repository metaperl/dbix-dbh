package DBIx::DBH;

our $VERSION = '0.4';

use Moose;
use Moose::Util::TypeConstraints;
use DBI;

has [ 'username', 'password' ] => (is => 'rw', isa => 'Str');

subtype 'DSNHashRef'  => as 'HashRef'  => where { defined($_->{driver}) };

has 'dsn'  => (is => 'rw', isa => 'DSNHashRef');
has 'attr' => (is => 'rw', isa => 'HashRef');


sub dsn_string {
  my($self)=@_;

  my %dsn = % { $self->dsn } ;
  my $driver = delete($dsn{driver});
  my $dsn = "dbi:$driver";

  my $extra = join ';', map { sprintf "%s=%s", $_, $dsn{$_} } (sort keys %dsn) ;
  length($extra) and $dsn = "$dsn:$extra";

  $dsn;
}

sub for_dbi {
  my($self)=@_;
  ($self->dsn_string, $self->username, $self->password, $self->attr);
}


sub for_skinny_setup {
  my($self)=@_;
  (
   dsn => $self->dsn_string, 
   username => $self->username, 
   password => $self->password
   );
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

   my $dbh = DBIx::DBH->(map { $_ => $cgi->param($_) } 
                 grep(/dsn|user|pass/, keys %{$cgi->Vars})->dbh;

Instead of a bunch of string twiddling.

=back

=head1 METHODS

=head1 Legacy Version

A procedural version of DBIx::DBH is still available as
L<DBIx::DBH::Legacy>.

=head1 An example extension

The file F<DBH.pm> in L<DBIx::Cookbook> is an example of deriving a connection
class from DBIx::DBH -

L<http://github.com/metaperl/dbix-cookbook/blob/master/lib/DBIx/Cookbook/DBH.pm>



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

Terrence Brannon, C<< metaperl@gmail.com >>

thanks to Khisanth, Possum and DrForr on #perl-help

=head2 SOURCE CODE REPO

L<http://github.com/metaperl/dbix-dbh>

=head1 COPYRIGHT AND LICENSE

Copyright (C) by Terrence Brannon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut

