package Graph::Man::Algorithm::Default;
use 5.016;
use warnings;
use parent 'Graph::Man::Algorithm';
use Unicode::Normalize qw(NFKC);


sub preprocess {
    my ($name, $mail) = map { fc NFKC($_) } @_[1, 2];
    $name =~ s/\@.*//;                  # strip e-mail suffix
    $name =~ s/\pP|\s//g;               # strip punctuation and whitespace
    $mail =~ s/\.?\(none\)$//;          # strip random .(none) from the end
    $mail =~ s/^([^@]*@[^@]*)\@.*$/$1/; # strip second e-mail suffix
    return [$name, $mail];
}


1;
__END__

=head1 NAME

Graph::Man::Algorithm::Default - identity merging with minimal pre-processing

=head1 SYNOPSIS

Similar to the occurrence algorithm, but adds some minimal processing:

=over

=item

Artifacts are case-folded and normalized to NFKC.

=item

E-mail suffixes (anything following an C<@>) are stripped from names.

=item

All punctuation is stripped from names.

=item

Random C<.(none)> at the end of e-mail addresses is stripped.

=item

Duplicate e-mail suffixes are stripped after the second C<@>.

=back

=head1 METHODS

=head2 preprocess

    $self->preprocess($name, $mail)

Override. Does the case-folding and stripping.

=cut
