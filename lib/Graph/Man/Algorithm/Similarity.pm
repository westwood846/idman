package Graph::Man::Algorithm::Similarity;
use 5.016;
use warnings;
use parent 'Graph::Man::Algorithm';
use Getopt::Long qw(GetOptionsFromArray);
use List::Util qw(max);
use Memoize;
use Text::Levenshtein::XS qw(distance);


memoize '_normalized_distance';

sub _normalized_distance {
    my ($str1, $str2) = @_;
    return 0 unless length($str1) && length($str2);
    return 1 - distance($str1, $str2) / max(length $str1, length $str2);
}


sub new {
    my ($class, @args) = @_;

    my $threshold = $ENV{GRAPHMAN_THRESHOLD};
    GetOptionsFromArray(\@args, 'threshold|t=f' => \$threshold)
        or die "$class: error parsing arguments.\n";

    unless ($threshold > 0 && $threshold <= 1) {
        my $got = defined($threshold) ? "'$threshold'" : 'nothing';
        die "$class: a threshold > 0 and <= 1 is required, but I got $got.\n",
            "Specify it via `--threshold` on the command line or the ",
            "`GRAPHMAN_THRESHOLD` environment variable.\n",
    }

    return bless {threshold => $threshold}, $class;
}


sub preprocess {
    my ($self, $name, $mail) = @_;
    return [map { fc($_) =~ s/\pP//gr } $name, $mail];
}


sub similar {
    my ($self, $str1, $str2) = @_;
    return _normalized_distance($str1, $str2) >= $self->{threshold};
}


sub artifacts_equal {
    my ($self, $a1, $a2) = @_;
    return $self->similar($a1->[0], $a2->[0])
        || $self->similar($a1->[1], $a2->[1]);
}


1;
__END__

=head1 NAME

Graph::Man::Algorithm::Similarity - identity merging with Levenshtein distance

=head1 SYNOPSIS

Does some basic preprocessing in the form of case-folding and stripping out
punctuation. Compares artifacts using normalized Levenshtein distance and
considers them equal if they are below a given threshold.

Depends on L<Text::Levenshtein::XS>, so you gotta install that module.

=head1 METHODS

=head2 new

    Graph::Man::Algorithm::Similarity->new('--threshold=0.8')

Constructor, requires a threshold, where C<< 0 < threshold <= 1 >>. Specify it
either via C<--threshold=NUMBER> on the command line or via the
C<GRAPHMAN_THRESHOLD> environment variable.

=head2 similar

    $self->similar($str1, $str2)

Returns if the normalized Levenshtein between the given strings exceeds the
threshold passed to L</new>.

=head2 preprocess

    $self->preprocess($name, $mail)

Override. Casefolds the artifacts and strips punctuation from them.

=head2 artifacts_equal

    $self->artifacts_equal($a1, $a2)

Override. Returns if the names or e-mail addresses of the given artifacts are
L</similar>.

=head1 ATTRIBUTES

=head2 threshold

    $self->{threshold}

The threshold given in the constructor.

=head1 INTERNALS

Don't call these from outside.

=head2 _normalized_distance

    _normalized_distance($str1, $str2)

Returns the normalized Levenshtein distance between the given strings. This
function is cached via L<Memoize>.

=cut
