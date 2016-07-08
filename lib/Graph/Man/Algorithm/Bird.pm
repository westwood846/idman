package Graph::Man::Algorithm::Bird;
use strict;
use warnings;
use feature qw(fc);
use parent 'Graph::Man::Algorithm::Similarity';


sub _make_alternation {
    return join '|', map { quotemeta } @_;
}

our @TERMS = qw(administrator admin. support development
                dev. developer maint. maintainer);

our @SUFFIXES = qw(mr. mrs. miss ms. prof. pr. dr. ir. rev.
                   ing. jr. d.d.s. ph.d. capt. lt.);

our $TERM   = qr/\b${\_make_alternation(@TERMS)}\b/;
our $SUFFIX = qr/${\_make_alternation(@SUFFIXES)}$/;


sub _normalize {
    my ($str) = @_;
    $str =  fc $str;        # case-fold
    $str =~ s/$TERM//g;     # strip terms
    $str =~ s/$SUFFIX//g;   # strip suffixes
    $str =~ s/\pP//g;       # strip punctuation
    $str =~ s/\s+/ /g;      # collapse whitespace
    $str =~ s/^\s+|\s+$//g; # trim whitespace
    return $str;
}

sub _initial_and_rest {
    my ($str, $initial, $rest) = @_;

    my $index = index $str, $rest;
    return if $index == -1;

    substr $str, $index, length($rest), '';
    return index($str, substr $initial, 0, 1) != -1;
}


sub _process_artifact {
    my ($str) = @_;

    if ($str =~ /^(?<first>\S+)\s+(?<last>\S+)$/
    ||  $str =~ /^(?<last>\S+)\s*,\s*(?<first>\S+)$/) {
        return {
            type  => 'name',
            first => _normalize($+{first}),
            last  => _normalize($+{last}),
            full  => _normalize($+{full} // $str),
        };
    }
    else {
        my $alias = _normalize($str =~ /^([^@]+)@/ ? $1 : $str);
        return {
            type  => 'alias',
            alias => $alias,
        };
    }
}

sub preprocess {
    my ($self, $name, $mail) = @_;
    return [_process_artifact($name), _process_artifact($mail)];
}


sub _cmp_name_name {
    my ($self, $a1, $a2) = @_;
    return $self->similar($a1->{first}, $a2->{first})
        && $self->similar($a1->{last }, $a2->{last })
        || $self->similar($a1->{full }, $a2->{full });
}

sub _cmp_alias_alias {
    my ($self, $a1, $a2) = @_;
    return length($a1->{alias}) >= 3
        && length($a2->{alias}) >= 3
        && $self->similar($a1->{alias}, $a2->{alias});
}

sub _cmp_name_alias {
    my ($self, $a1, $a2) = @_;
    my ($first, $last)   = @{$a1}{'first', 'last'};
    my  $alias           = $a2->{alias};

    return length($first) >= 2
        && length($last ) >= 2
        && (_initial_and_rest($alias, $first, $last )
         || _initial_and_rest($alias, $last,  $first)
         || index($alias, $first) != -1 && index($alias, $last) != -1);
}

sub _cmp_alias_name {
    my ($self, $a1, $a2) = @_;
    return $self->_cmp_name_alias($a2, $a1);
}

sub _cmp {
    my ($self, $a1, $a2) = @_;
    my $method = "_cmp_$a1->{type}_$a2->{type}";
    return $self->$method($a1, $a2);
}

sub artifacts_equal {
    my ($self, $p1, $p2) = @_;
    return $self->_cmp($p1->[0], $p2->[0])
        || $self->_cmp($p1->[0], $p2->[1])
        || $self->_cmp($p1->[1], $p2->[0])
        || $self->_cmp($p1->[1], $p2->[1]);
}


1;
__END__

=head1 NAME

Graph::Man::Algorithm::Bird - crazy preprocessed identity merging

=head1 SYNOPSIS

An extension of C<Graph::Man::Algorithm::Similarity> and uses the Levenshtein
similarity measure from that algorithm. Based on the work of Bird et al. in the
paper Mining Email social networks, which is freely available under
L<http://macbeth.cs.ucdavis.edu/msr06.pdf>.

We also treat usernames that can't be split into first and last names as e-mail
prefixes, and because of that we call them aliases instead.

This algorithm adds a whole bunch of stuff to the naive similarity measurement:

=over

=item

Artifacts are L</_normalize>d.

=item

Names in the form C<firstname lastname> or C<lastname, firstname> are treated
as special name artifacts. Other names and prefixes of e-mail addresses are
treated as generic nicknames. E-mail address stuff after the @ is ignored.

=item

Artifacts are considered equal if:

=over

=item

Both are names and both of their first and last names are similar, or if their
entire name is similar.

=item

If both are aliases with at least 3 characters and are similar.

=item

If one artifact is a name and the other is an alias and the first and last
names have at least 2 characters, and if the alias contains both the first and
last name. Alternatively, if the alias contains the initial character of the
first or last name and the entirety of the other, with no overlap.

=back

=back

=head1 METHODS

=head2 preprocess

    $self->preprocess($name, $mail)

Override. Calls L<_process_artifact> on its arguments and returns those
processed artifacts in an arrayref. Each artifact is either a name like:

    {
        type  => 'name',
        first => 'john',
        last  => 'doe',
        full  => 'john doe',
    }

Or an alias like:

    {
        type  => 'alias',
        alias => 'jdoe',
    }

=head2 artifacts_equal

    $self->artifacts_equal($p1, $p2)

Override. Dispatches to L</_cmp> for each element of the tuples and returns
true if either one compares equal.

=head1 INTERNALS

Do not touch.

=head2 _normalize

    _normalize($str)

Normalizes the given string. It case-folds, strips off suffixes, generic terms
and punctuation, collapses all whitespace into a single space and trims it off
both ends.

=head2 _initial_and_rest

    _initial_and_rest($str, $initial, $rest)

Checks if the given C<$str> contains the first character of C<$initial> and the
entirety of C<$rest>, with no overlap. That is, the section of the string that
contains the C<$rest> can't also contain the single character from C<$initial>.

=head2 _process_artifact

    _process_artifact($str)

Twiddles the given C<$str> into a normalized artifact.

If the string looks like C<firstname lastname> or C<lastname, firstname>, it's
considered a name and is saved as a name, with first, last and full names.

Otherwise, if the string contains an @, it's considered an e-mail address and
everything before that is saved as an alias. The stuff after the @ is thrown
away.

Otherwise, the entire string is considered an alias and saved.

All of the saved strings are L</_normalize>d.


=head2 _cmp

    $self->_cmp($a1, $a2)

Dispatches to one of L</_cmp_name_name>, L</_cmp_alias_alias>,
L</_cmp_name_alias> or L</_cmp_alias_name>, depending on the types of the
artifacts.

=head2 _cmp_name_name

=head2 _cmp_alias_alias

=head2 _cmp_name_alias

=head2 _cmp_alias_name

    $self->_cmp_X_Y($a1, $a2)

These methods compare two artifacts of type X and Y if they are considered the
same according to the list of rules in the L</SYNOPSIS>.

=cut
