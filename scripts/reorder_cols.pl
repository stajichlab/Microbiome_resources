use strict;
use warnings;

# useful for processing UCHIME/UPARSE table results sorting by sum counts of columns
#
my $head = <>;
chomp ($head);
my ($idcol,@hdr) = split(/[,\t]/,$head);
warn("idcol is $idcol\n");
my @order = 1..(scalar @hdr);
#print join("\t",@order),"\n";
my $i = 0;
my %cols = map { $_ => $i++ } @hdr;
my @neworder = map { $_->[1] } 
               sort { $a->[0] <=> $b->[0] }
               map { my ($id) = (/[^\.]+\.(\d+)/);
		     [ $id, $_] } @hdr;
print join(",",$idcol, map { $hdr[$cols{$_}] } @neworder),"\n";
while(<>) {
    chomp;
    my ($id,@row) = split(/[,\t]/,$_);

    print join(",",$id, map { $row[$cols{$_}] } @neworder),"\n";
}
