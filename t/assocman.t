use strict;
use warnings;
use autodie;
use Encode qw(decode);
use JSON::PP;
use Test::More;

my $DIR = 't/output/';


for my $repo ('idman') {
    my $identities = "$DIR/backend/$repo.json";
    my $commits    = "$DIR/parseman/$repo";
    my $output     = decode('UTF-8', `./assocman '$identities' < '$commits'`);

    open my $fh, '<:encoding(UTF-8)', "$DIR/assocman/$repo.json";
    my $expected = do { local $/; <$fh> };
    close $fh;

    is_deeply(decode_json($output), decode_json($expected),
              "correct assocman output for $repo");
}


done_testing;
