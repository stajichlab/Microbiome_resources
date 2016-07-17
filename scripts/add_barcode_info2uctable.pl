
# expects USEARCH usearch -usearch_global results (readmap.uc)

while(<>) {
    chomp;
    my @row = split(/\t/,$_);
    if( $row[0] ne 'N' ) {
	my ($sample) = split(/_/,$row[-2]);	
	$row[-2] .= sprintf(";barcodelabel=%s;",$sample);
    }
    print join("\t",@row),"\n";
}
