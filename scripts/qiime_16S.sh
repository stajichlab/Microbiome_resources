#PBS -l nodes=1:ppn=32,mem=64gb -j oe -N qiime.16S
#Activate qiime 
hostname
CPU=$PBS_NP
module unload python
module load qiime
source activate qiime
bash scripts/00_make_combined_16S.sh
PWD=`pwd`
PREFIX=`basename $PWD`"_16S"
FWD=$PREFIX.R1.fna
REV=$PREFIX.R2.fna
OUT=qiime_16S_openref
TAXOUT=qiime_16S_taxa_summary
#Pick OTUs against open ref ITS
if [ ! -d $OUT ]; then
if [ $CPU ]; then
pick_open_reference_otus.py -i $PWD/$FWD -o $PWD/$OUT -s 0.1 -p $PWD/16S_params.txt --otu_picking_method uclust --parallel --jobs_to_start $CPU
else
pick_open_reference_otus.py -i $PWD/$FWD -o $PWD/$OUT -s 0.1 -p $PWD/16S_params.txt --otu_picking_method uclust 
fi
fi

#Summarize OTUs table
biom summarize-table -i $PWD/$OUT/otu_table_mc2_w_tax.biom > $PREFIX.FWD.biom_summarize.txt

#Summarize Taxa from OTUs table
summarize_taxa_through_plots.py -i $OUT/otu_table_mc2_w_tax.biom -o $TAXOUT -f

# Plot Taxonomy Summary command 
#plot_taxa_summary.py -i taxa_summary/otu_table_mc2_w_tax.txt
plot_taxa_summary.py -i $TAXOUT/otu_table_mc2_w_tax_L2.txt,$TAXOUT/otu_table_mc2_w_tax_L3.txt,$TAXOUT/otu_table_mc2_w_tax_L4.txt,$TAXOUT/otu_table_mc2_w_tax_L5.txt,$TAXOUT/otu_table_mc2_w_tax_L6.txt -o $TAXOUT/taxa_summary_plots/
