use strict;
use warnings;

# useful for post-processing UPARSE/UCHIME pipeline results

my $head = <>;
print $head;

my @rows;
while(<>) {
    chomp;
    push @rows, [ split(/\,/,$_)];
}

@rows = map { $_->[0] }
sort { $a->[1] <=> $b->[1] }
map {
    my $otu = -1;
    if( $_->[0] =~ /OTU_(\d+)/ ) {
	$otu = $1;
    } else {
	warn("trying to match ",$_->[0],"\n");
    }
    [ $_, $otu] }
@rows;

for my $r ( @rows ) {
    print join(",",@$r),"\n";
}
    
