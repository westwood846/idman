package Graph::Man::Algorithm::Python;
use strict;
use warnings;
use autodie;
use File::Basename qw(dirname);
use File::Spec::Functions qw(catfile);
use Inline::Python qw(py_eval);


sub _slurp_algorithm {
    my ($algorithm) = @_;
    my $path = catfile(dirname(__FILE__), 'Python', "$algorithm.py");
    open my $fh, '<:encoding(UTF-8)', $path;
    my $code = do { local $/; <$fh> };
    close $fh;
    return $code;
}


sub new {
    my ($class, undef, $algorithm) = @_;
    $algorithm = ucfirst lc $algorithm;
    py_eval(_slurp_algorithm($algorithm));
    return Inline::Python::Object->new('__main__', $algorithm);
}


use Inline Python => q(
import sys
def python_please_see_my_files_in(path):
    sys.path.append(path)
);

python_please_see_my_files_in(catfile(dirname(__FILE__), 'Python'));


1;
