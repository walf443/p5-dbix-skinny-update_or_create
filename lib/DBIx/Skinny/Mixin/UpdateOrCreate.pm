package DBIx::Skinny::Mixin::UpdateOrCreate;
our $VERSION = '0.01';

use strict;
use warnings;

use Carp ( );


sub register_method
{
    return {
        update_or_create => \&update_or_create,
        in_storage       => sub { shift->{in_storage} },
    };
}

sub update_or_create
{
    my $self = shift;
    my ($table, $cond, $args) = @_;

    $self->{in_storage} = 0;

    my $itr = $self->search($table, $cond);
    my $row;

    if ($itr->count > 1) {
        Carp::carp "Could not update; Query returned more than one row";
    }
    elsif ($itr->count == 1) {
        $self->{in_storage} = 1;
        $row   = $itr->first;
        %$args = (%$cond, %$args);
        $row->update($args);
    }
    else {
        %$args = (%$cond, %$args);
        $row   = $self->insert($table, $args);
    }

    return $row;
}

1;
__END__

=head1 NAME

DBIx::Skinny::Mixin::UpdateOrCreate -

=head1 SYNOPSIS

  package Proj::DB;
  use DBIx::Skinny;
  use DBIx::Skinny::Mixin modules => [qw/ UpdateOrCreate /];

  package main;
  use Proj::DB;

  my $cond = { id   => 1 };          # update conditions
  my $args = { name => 'hatyuki' };  # insert or update value
  my $row  = Proj::DB->update_or_create('TableName', $cond, $args);

=head1 DESCRIPTION

DBIx::Skinny::Mixin::UpdateOrCreate is

=head1 AUTHOR

hatyuki

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
