package Graph::Man::Algorithm::Default;
use strict;
use warnings;
use feature qw(fc);
use parent 'Graph::Man::Algorithm';


sub process_artifacts {
    my ($self, @artifacts) = @_;
    for (@artifacts) {
        $_ = fc($_);
        s/\.?\(none\)$//;
    }
    return @artifacts;
}


1;
__END__

=head1 NAME

Graph::Man::Algorithm::Default - identity merging with minimal pre-processing

=head1 SYNOPSIS

Similar to the occurrence algorithm, but fold-cases all artifacts and strips
off C<.(none)> from the end, which git seems to randomly attach if the e-mail
address doesn't contain a dot.

=head1 METHODS

=head2 process_artifacts

    $self->process_artifacts(@artifacts)

Override. Casefolds all C<@artifacts> and strips C<.(none)> from the end.

=cut
