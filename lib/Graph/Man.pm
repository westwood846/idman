package Graph::Man;
use strict;
use warnings;
use Graph::Man::Algorithm;
use Graph::Man::JSON;


sub _unique {
    my %merge;
    @merge{@_} = ();
    return keys %merge;
}


sub _gather_identities {
    my ($fh, $logic) = @_;
    my (@identities, %done);

    while (<$fh>) {
        my $commit = decode_json($_);

        use constant ARTIFACT_SETS => (
            ['author_name',    'author_mail'   ],
            ['committer_name', 'committer_mail'],
            ['signer',         'signer_key'    ],
        );

        for my $keys (ARTIFACT_SETS) {
            my @real = grep { length } _unique(@{$commit}{@$keys});
            next unless @real;

            my $set = join "\0", @real;

            if (!exists $done{$set}) {
                push @identities, {
                    real      => \@real,
                    processed => [_unique($logic->process_artifacts(@real))],
                };
                $done{$set} = 1;
            }
        }
    }

    return \@identities;
}


sub _merge {
    my ($identities, $x, $y) = @_;
    my ($id1, $id2) = @{$identities}[$x, $y];

    $identities->[$x] = {
        real      => [_unique(@{$id1->{real     }}, @{$id2->{real     }})],
        processed => [_unique(@{$id1->{processed}}, @{$id2->{processed}})],
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
                my $set = join "\0", @$id1, @$id2;

                next if exists $done{$set};
                $done{$set} = 1;

                if ($logic->should_merge($id1, $id2)) {
                    _merge($identities, $x, $y);
                    $again = 1;
                    --$y;
                }
            }
        }
    } while ($again);
}


sub identify {
    my ($fh, $algorithm, @args) = @_;

    $algorithm = ucfirst lc $algorithm;
    require "Graph/Man/Algorithm/$algorithm.pm";
    my $logic = "Graph::Man::Algorithm::$algorithm"->new(@ARGV);

    my $identities = _gather_identities($fh, $logic);
    _iterative_merge($identities, $logic,                  'processed');
    _iterative_merge($identities, 'Graph::Man::Algorithm', 'real'     );

    return encode_json([map { [sort @{$_->{real}}] } @$identities]);
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

=head2 _unique

    unique(@strings)

Returns the given list of C<@strings> with all duplicates removed. The
resulting list is in no particular order.

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

=cut
