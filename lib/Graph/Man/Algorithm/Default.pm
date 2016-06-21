package Graph::Man::Algorithm::Default;
use strict;
use warnings;
use feature qw(fc);
use base 'Graph::Man::Algorithm';


sub handle_artifacts {
    my ($self, @artifacts) = @_;
    for (@artifacts) {
        $_ = fc($_);
        s/\.\(none\)$//;
    }
    return @artifacts;
}


1;
