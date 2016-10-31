#!env perl

use strict;
use warnings;
use Getopt::Long;
my $min_count = 10000;
my $debug = 0;
GetOptions('l|min:s' => \$min_count,
	'debug!'    => \$debug);

my $file = shift || "seqs.fastq";

my $odir = shift || 'by-library-fastq';
my $baddir = shift || $odir . "_BAD";

my %seqs;
foreach my $d ( $odir,$baddir) {
    mkdir($d) unless -d $d;
}
open(my $in => $file) || die $!;
while( <$in> ) {
 my $line1 = $_;
 my $lineseq = <$in>;
 my $line3 = <$in>;
 my $lineq = <$in>;
 if( $line1 =~ /^\@(\S+)/ ) {
   my $id = $1;
   my ($sample) = split(/_/,$id);
   warn"$id $sample\n" if $debug;
   push @{$seqs{$sample}}, join("", $line1,$lineseq,$line3,$lineq);
  } else {
	warn("off register? line1 = $line1\n");
  }
}

while( my ($samp,$sqs) = each %seqs ) {
    my $dir = $odir;
    if( @$sqs < $min_count ) {
	$dir = $baddir;
    }
    open(my $out => ">$dir/$samp.fq") || die $!;
    print $out join("", @$sqs);
}
