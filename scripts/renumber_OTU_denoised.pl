#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $label = 'OTU_';

GetOptions('label:s' => \$label);

my $n = 1;
    
while(<>){
    if(/^>(\S+);(size=\S+)/) {
	printf ">%s%d;%s\n",$label,$n++,$2;
    } else {
	print;
    }
}
