package Graph::Man::Algorithm::Similarity;
use strict;
use warnings;
use feature qw(fc);
use base 'Graph::Man::Algorithm';
use Getopt::Long qw(GetOptionsFromArray);
use List::Util qw(max);
use Memoize;
use Text::Levenshtein::XS qw(distance);


memoize 'normalized_distance';

sub normalized_distance {
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


sub _similar {
    my ($self, $str1, $str2) = @_;
    return normalized_distance($str1, $str2) >= $self->{threshold};
}


sub artifacts_equal {
    my ($self, $a1, $a2) = @_;
    return $self->_similar($a1, $a2);
}


1;
