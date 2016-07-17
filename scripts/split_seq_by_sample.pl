#!env perl

use strict;
use warnings;
use Getopt::Long;
use Bio::SeqIO;
my $min_count = 10000;

GetOptions('l|min:s' => \$min_count);

my $file = shift || "seqs.fna";
my $in = Bio::SeqIO->new(-format => 'fasta',
			 -file   => $file);

my $odir = shift || 'by-library';
my $baddir = shift || $odir . "_BAD";

my %seqs;
foreach my $d ( $odir,$baddir) {
    mkdir($d) unless -d $d;
}

while( my $seq = $in->next_seq ) {
    my ($id) = $seq->display_id;
    my ($sample) = split(/_/,$id);
    push @{$seqs{$sample}}, $seq;
}

while( my ($samp,$seqs) = each %seqs ) {
    my $dir = $odir;
    if( @$seqs < $min_count ) {
	$dir = $baddir;
    }
    my $out = Bio::SeqIO->new(-format => 'fasta',
			      -file   => ">$dir/$samp.fa");
    $out->write_seq(@$seqs);
}
