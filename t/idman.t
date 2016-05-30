use strict;
use warnings;
use Encode qw(decode);
use Test::More;


sub run_idman {
    my $command = join ' ', './idman', @_, '2>&1';
    return decode('UTF-8', `$command`);
}


for my $args ([], ['arg']) {
    my $output = run_idman(@$args);
    my $count  = @$args;
    like $output, qr/usage/i, "idman with $count arguments prints usage";
    cmp_ok $?, '!=', 0, 'and exits with non-zero';
}


{
    my $output = run_idman('.', 'nonexistent');
    like $output, qr/no such algorithm/i,
         'nonexistent algorithm prints appropriate message';
    cmp_ok $?, '!=', 0, 'and exits with non-zero';
}


done_testing;
