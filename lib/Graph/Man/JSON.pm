package Graph::Man::JSON;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw(decode_json encode_json);

BEGIN {
    if (eval { require JSON::XS }) {
        JSON::XS->import;
    }
    else {
        require JSON::PP;
        JSON::PP->import;
    }
}

1;
__END__

=head1 NAME

Graph::Man::JSON - stupid conditional JSON module loader

=head1 SYNOPSIS

When you C<use Graph::Man::JSON>, it'll try to load the fast L<JSON::XS>
library.  If that doesn't work, it loads the slow, pure-Perl L<JSON::PP>
instead, which is a core module and should always be available.

Either way, you'll get C<encode_json> and C<decode_json> subroutines exported.

=cut
