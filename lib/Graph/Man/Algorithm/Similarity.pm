package Graph::Man::Algorithm::Similarity;
use strict;
use warnings;
use feature qw(fc);
use base 'Graph::Man::Algorithm';
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


sub process_artifacts {
    my ($self, @artifacts) = @_;
    for (@artifacts) {
        $_ = fc $_;
        s/\pP//g;
    }
    return @artifacts;
}


sub similar {
    my ($self, $str1, $str2) = @_;
    return _normalized_distance($str1, $str2) >= $self->{threshold};
}


sub artifacts_equal {
    my ($self, $a1, $a2) = @_;
    return $self->_similar($a1, $a2);
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

=head2 process_artifacts

    $self->process_artifacts(@artifacts)

Override. Casefolds all C<@artifacts> and strips punctuation from them.

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
