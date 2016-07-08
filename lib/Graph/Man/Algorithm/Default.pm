package Graph::Man::Algorithm::Default;
use 5.016;
use warnings;
use parent 'Graph::Man::Algorithm';


sub process_artifacts {
    my ($self, $name, $mail) = @_;
    return [fc($name), fc($mail) =~ s/\.?\(none\)$//r];
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

=head2 preprocess

    $self->preprocess($name, $mail)

Override. Casefolds the artifacts and strips off C<.(none)> from the end of
C<$mail>.

=cut
