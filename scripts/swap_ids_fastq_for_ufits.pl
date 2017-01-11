use strict;
use warnings;

while( <> ) 
{
    my $line1 = $_;
    my $lineseq = <>;
    my $line3 = <>;
    my $lineq = <>;

#    if( $line1 =~ s/^\@(\S+)_(\d+)\s+(\S+)\s+orig_bc\S+\s+new_bc=(\S+)/\@$3;barcodelabel=$1/) {
#    } 
    if( $line1 =~ s/^\@(\S+)_(\d+)\s+(\S+)/\@$3;barcodelabel=$1/ ) {
	print $line1, $lineseq,$line3,$lineq;
    } else {
	warn("off register? line1 = $line1\n");
    }
}
	
