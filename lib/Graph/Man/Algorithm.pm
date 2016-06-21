package Graph::Man::Algorithm;
use strict;
use warnings;
use List::Util qw(any);


sub new {
    my ($class) = @_;
    bless {}, $class;
}


sub should_merge {
    my ($self, $id1, $id2) = @_;

    for my $artifact (@$id1) {
        if (any { $self->artifacts_equal($_, $artifact) } @$id2) {
            return 1;
        }
    }
    return 0;
}


sub artifacts_equal {
    my ($self, $a1, $a2) = @_;
    return $a1 eq $a2;
}


1;
