package Graph::Man;
use strict;
use warnings;
use Graph::Man::Algorithm;
use Graph::Man::JSON;


sub _gather_identities {
    my ($fh, $logic) = @_;
    my (@identities, %done);

    while (<$fh>) {
        my $commit = decode_json($_);

        for my $key ('author', 'committer') {
            my $name = $commit->{"${key}_name"} // '';
            my $mail = $commit->{"${key}_mail"} // '';

            if (!length($name) && !length($mail)) {
                next;
            }

            my $done_key = "$name\0$mail";

            if (!exists $done{$done_key}) {
                push @identities, {
                    real      => [[$name, $mail]],
                    processed => [$logic->preprocess($name, $mail)],
                };
                $done{$done_key} = 1;
            }
        }
    }

    return \@identities;
}


sub _merge {
    my ($identities, $x, $y) = @_;
    my ($id1, $id2) = @{$identities}[$x, $y];

    $identities->[$x] = {
        real      => [@{$id1->{real     }}, @{$id2->{real     }}],
        processed => [@{$id1->{processed}}, @{$id2->{processed}}],
    };

    splice @$identities, $y, 1;
}

sub _iterative_merge {
    my ($identities, $logic, $key) = @_;
    my ($again, %done);

    do {
        $again = 0;
        for (my $x = 0; $x < @$identities; ++$x) {
            my $id1 = $identities->[$x]{$key};

            for (my $y = $x + 1; $y < @$identities; ++$y) {
                my $id2 = $identities->[$y]{$key};
                my $done_key = join "\0", @$id1, @$id2;

                if (!exists $done{$done_key}) {
                    if ($logic->should_merge($id1, $id2)) {
                        _merge($identities, $x, $y);
                        $again = 1;
                        --$y;
                    }
                    $done{$done_key} = 1;
                }
            }
        }
    } while ($again);
}


sub _unique {
    my %merge;
    @merge{map { join "\0", @$_ } @_} = @_;
    return sort { "@$a" cmp "@$b" } values %merge;
}

sub identify {
    my ($fh, $algorithm, @args) = @_;

    $algorithm = ucfirst lc $algorithm;
    require "Graph/Man/Algorithm/$algorithm.pm";
    my $logic = "Graph::Man::Algorithm::$algorithm"->new(@ARGV);

    my $identities = _gather_identities($fh, $logic);
    _iterative_merge($identities, $logic, 'processed');

    return encode_json([
        sort { "@{$a->[0]}" cmp "@{$b->[0]}" }
        map  { [_unique(@{$_->{real}})] }
        @$identities
    ]);
}


1;
__END__

=head1 NAME

Graph::Man - master controller of the graph

=head1 SYNOPSIS

Just run C<identify> and it'll give you the identities as a JSON-encoded
string.

=head1 FUNCTIONS

=head2 identify

    identify($fh, $algorithm, @args)

Does identity merging from the input given on the file handle C<$fh>, using the
given C<$algorithm>. The C<@args> are passed directly to the algorithm's
constructor.

Returns single-line JSON-encoded string of the resulting merged identities.

=head1 INTERNALS

Don't meddle with these from the outside.

=head2 _gather_identities

    _gather_identities($fh, $logic)

Collects all identities from the given file handle C<$fh>, using the algorithm
instantiated in C<$logic>. Returns an array reference of the resulting
identities, with each element being a hash reference looking like this:

    {
        real      => ['list', 'of', 'raw', 'artifacts'],
        processed => ['artifacts', 'processed', 'by', 'algorithm'],
    }

=head2 _merge

    _merge(\@identities, $x, $y)

Merges the identity at index C<$y> into the identity at index C<$x> and removes
C<< $identities->[$x] >> from the array. The resulting identity will not
contain duplicates.

=head2 _iterative_merge

    _iterative_merge(\@identities, $logic, $key)

Simulates a graph connecting different nodes by iteratively merging the list of
C<$identities> until it doesn't change anymore. Uses C<< $logic->should_merge
>> to decide if any two identities should be merged.

The C<$key> can be either C<'real'> or C<'processed'>, depending on what set of
identities you want to merge.

=head2 _unique

    unique(@artifacts)

Returns the given list of C<@artifacts> (C<[name, e-mail address]> tuples) with
all duplicates removed. The resulting list is sorted lexically.

=cut
