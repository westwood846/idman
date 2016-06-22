package Graph::Man;
use strict;
use warnings;
use Graph::Man::Algorithm;
use Graph::Man::JSON;


sub unique {
    my %merge;
    @merge{@_} = ();
    return keys %merge;
}


sub gather_identities {
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
            my @real = grep { length } unique(@{$commit}{@$keys});
            next unless @real;

            my $set = join "\0", @real;

            if (!exists $done{$set}) {
                push @identities, {
                    real      => \@real,
                    processed => [unique($logic->process_artifacts(@real))],
                };
                $done{$set} = 1;
            }
        }
    }

    return \@identities;
}


sub merge {
    my ($identities, $x, $y) = @_;
    my ($id1, $id2) = @{$identities}[$x, $y];

    $identities->[$x] = {
        real      => [unique(@{$id1->{real     }}, @{$id2->{real     }})],
        processed => [unique(@{$id1->{processed}}, @{$id2->{processed}})],
    };

    splice @$identities, $y, 1;
}

sub iterative_merge {
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
                    merge($identities, $x, $y);
                    $again = 1;
                    --$y;
                }
            }
        }
    } while ($again);
}


sub identify {
    my ($fh, $algorithm, @args) = @_;

    require "Graph/Man/Algorithm/$algorithm.pm";
    my $logic = "Graph::Man::Algorithm::$algorithm"->new(@ARGV);

    my $identities = gather_identities($fh, $logic);
    iterative_merge($identities, $logic,                  'processed');
    iterative_merge($identities, 'Graph::Man::Algorithm', 'real'     );

    return encode_json([map { [sort @{$_->{real}}] } @$identities]);
}


1;
