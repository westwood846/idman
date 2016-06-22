package Graph::Man::Algorithm::Bird;
use strict;
use warnings;
use feature qw(fc);
use base 'Graph::Man::Algorithm::Similarity';


sub _make_alternation {
    return join '|', map { quotemeta } @_;
}

our @TERMS = qw(administrator admin. support development
                dev. developer maint. maintainer);

our @SUFFIXES = qw(mr. mrs. miss ms. prof. pr. dr. ir. rev.
                   ing. jr. d.d.s. ph.d. capt. lt.);

our $TERM   = qr/\b${\_make_alternation(@TERMS)}\b/;
our $SUFFIX = qr/${\_make_alternation(@SUFFIXES)}$/;


sub _normalize {
    my ($str) = @_;
    $str =  fc $str;
    $str =~ s/$TERM//g;
    $str =~ s/$SUFFIX//g;
    $str =~ s/\pP//g;
    $str =~ s/\s+/ /g;
    return $str;
}

sub _initial_and_rest {
    my ($str, $initial, $rest) = @_;

    my $index = index $str, $rest;
    return if $index == -1;

    substr $str, $index, length($rest), '';
    return index($str, substr $initial, 0, 1) != -1;
}


sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    $self->{artifacts} = {};
    return $self;
}


sub _save_artifact {
    my ($self, $str) = @_;

    if (!$self->{artifacts}{$str}) {
        my %artifact;

        if ($str =~ /^(?<first>\S+)\s+(?<last>\S+)$/
        ||  $str =~ /^(?<last>\S+)\s*,\s*(?<first>\S+)$/) {
            %artifact = (
                type  => 'name',
                first => _normalize($+{first}),
                last  => _normalize($+{last}),
                full  => _normalize($+{full} // $str),
            );
        }
        else {
            my $alias = _normalize($str =~ /^([^@]+)@/ ? $1 : $str);
            return unless length $alias;
            %artifact = (
                type  => 'alias',
                alias => $alias,
            );
        }

        $self->{artifacts}{$str} = \%artifact;
    }
}


sub process_artifacts {
    my ($self, @artifacts) = @_;
    $self->_save_artifact($_) for @artifacts;
    return @artifacts;
}


sub _cmp_name_name {
    my ($self, $a1, $a2) = @_;
    return $self->similar($a1->{first}, $a2->{first})
        && $self->similar($a1->{last }, $a2->{last })
        || $self->similar($a1->{full }, $a2->{full });
}

sub _cmp_alias_alias {
    my ($self, $a1, $a2) = @_;
    return length($a1->{alias}) >= 3
        && length($a2->{alias}) >= 3
        && $self->similar($a1->{alias}, $a2->{alias});
}

sub _cmp_name_alias {
    my ($self, $a1, $a2) = @_;
    my ($first, $last)   = @{$a1}{'first', 'last'};
    my  $alias            = $a2->{alias};

    return length($first) >= 2
        && length($last ) >= 2
        && (_initial_and_rest($alias, $first, $last )
         || _initial_and_rest($alias, $last,  $first)
         || index($alias, $first) != -1 && index($alias, $last) != -1);
}

sub _cmp_alias_name {
    my ($self, $a1, $a2) = @_;
    return $self->_cmp_name_alias($a2, $a1);
}


sub artifacts_equal {
    my $self      = shift;
    my ($a1, $a2) = @{$self->{artifacts}}{@_};
    return unless $a1 && $a2;

    my $method = "_cmp_$a1->{type}_$a2->{type}";
    return $self->$method($a1, $a2);
}


1;
