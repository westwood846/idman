package Graph::Man::Algorithm;
use 5.016;
use warnings;
use List::Util qw(any);


sub new {
    my ($class) = @_;
    bless {}, $class;
}


sub preprocess {
    my ($self, $name, $mail) = @_;
    return [$name, $mail];
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
    return $a1->[0] eq $a2->[0]
        || $a1->[1] eq $a2->[1];
}


1;
__END__

=head1 NAME

Graph::Man::Algorithm - base class for algorithms

=head1 SYNOPSIS

Make your own algorithm in the F<Algorithm> folder, such as
C<Graph/Man/Algorithm/Sample>, and override the necessary methods.

    package Graph::Man::Algorithm::Sample;
    use 5.016;
    use warnings;
    use base 'Graph::Man::Algorithm';

    # override some methods here, see section METHODS

    1;

=head1 METHODS

These are the methods you can override. If you don't override any of  them, you
basically get the C<occurrence> algorithm.

=head2 new

    Graph::Man::Algorithm->new(@args_from_argv)

The constructor here just builds an empty object. If you need attributes in
your algorithm object, override this and C<bless> it yourself. You'll be given
the values from C<@ARGV> as your arguments, so do with those what you want.

=head2 preprocess

    $self->preprocess($name, $mail)

This method gives you a chance to pre-process your artifacts. For example, you
could case-fold them so that you can compare them case-insensitively later. You
can return a list of whatever elements you want from this.

The default is to just return the given name and e-mail address tuple.

=head2 should_merge

    $self->should_merge($id1, $id2)

Decide if the given C<$id1> and C<$id2> should be merged together. They are
array references containing strings. Return something true if you want them
merged and something false if they shouldn't.

The default is to merge them if they share an equal artifact. See
L</artifacts_equal> if you want to override this equality check.

=head2 artifacts_equal

    $self->artifacts_equal($a1, $a2)

Decide if the given artifacts C<$a1> and C<$a2> are equal. Return an
appropriately truthy or falsy value.

The default is to assume that they're C<[name, e-mail address]> tuples, and it
is checked if either pair of those are C<eq>ual.

=cut
