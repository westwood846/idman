use strict;
use warnings;
use autodie;
use Encode qw(decode);
use JSON::PP;
use Test::More;

my $DIR = 't/output';


sub run_assocman {
    my ($repo) = @_;
    my $identities = "$DIR/backend/$repo.json";
    my $commits    = "$DIR/parseman/$repo";
    my $output     = decode('UTF-8', `./assocman '$identities' < '$commits'`);
    return decode_json($output);
}

sub get_expected {
    my ($repo) = @_;
    open my $fh, '<:encoding(UTF-8)', "$DIR/assocman/$repo.json";
    my $content = do { local $/; <$fh> };
    close $fh;
    return decode_json($content);
}


for my $repo ('idman') {
    is_deeply(run_assocman($repo), get_expected($repo),
              "correct assocman output for $repo");
}


note q(It's an error if two different people have the same identifier.);
note q(Check that assocman detects that error properly:);
{
    my $identities = "$DIR/backend/duplicate_identifier.json";
    my $commits    = "$DIR/parseman/empty";
    my $output = decode('UTF-8', `./assocman '$identities' < '$commits' 2>&1`);
    cmp_ok $?, '!=', 0, 'duplicate identitifiers make assocman die';
    like $output, qr/duplicate identifier/i,
         'and show an error about a duplicate identifier';
}


note q(Similarly, if a single commit has an author or a committer that maps);
note q(to two different people, it's also an error:);
{
    my $identities = "$DIR/backend/idman.json";
    my $commits    = "$DIR/parseman/multiple_identities";
    my $output = decode('UTF-8', `./assocman '$identities' < '$commits' 2>&1`);
    cmp_ok $?, '!=', 0, 'split personalities make assocman die';
    like $output, qr/multiple different identities/i,
         'and show an error about multiple identities';
}


done_testing;
