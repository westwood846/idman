package Graph::Man::Algorithm::Naive;
use 5.016;
use warnings;
use parent 'Graph::Man::Algorithm';
use Getopt::Long qw(GetOptionsFromArray);
use List::Util qw(all);


sub new {
    my ($class, @args) = @_;

    my $only = $ENV{GRAPHMAN_ONLY};
    GetOptionsFromArray(\@args, 'only|o=s' => \$only)
        or die "$class: error parsing arguments.\n";

    # $self holds the indexes for artifacts_equal
    my $self = [0, 1];

    if (defined $only) {
        if ($only eq 'name') {
            $self = [0];
        }
        elsif ($only eq 'mail') {
            $self = [1];
        }
        else {
            die "$class: expected 'only' argument to be one of ",
                "'name' or 'mail', but got '$only' instead.\n";
        }
    }

    return bless $self, $class;
}


sub artifacts_equal {
    my ($self, $a1, $a2) = @_;
    return all { $a1->[$_] eq $a2->[$_] } @$self;
}


1;
__END__

=head1 NAME

Graph::Man::Algorithm::Naive - the wrong way to merge identities

=head1 SYNOPSIS

This algorithm covers the naive ways of merging identities. It can merge
identities just by name, just by e-mail or by both being equal.

This is only useful for comparisons, you shouldn't use this algorithm for
anything.

=head1 METHODS

=head2 new

    Graph::Man::Algorithm::Naive->new()
    Graph::Man::Algorithm::Naive->new('--only=name')
    Graph::Man::Algorithm::Naive->new('--only=mail')

Constructor. The C<--only> parameter can be used to specify merging only by
name or only by e-mail. Otherwise, artifacts will be merged if both their name
and e-mail are equal.

=head2 artifacts_equal

    $self->artifacts_equal($a1, $a2)

Override. Returns if the artifacts are equal depending on the parameters passed
to L</new>. So either name, e-mail or both have to be equal.

=cut
