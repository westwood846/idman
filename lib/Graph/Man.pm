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
