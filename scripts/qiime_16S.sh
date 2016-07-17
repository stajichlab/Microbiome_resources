#PBS -l nodes=1:ppn=32,mem=64gb -j oe -N qiime.16S
#Activate qiime 
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
TAXSUM=taxa_summary_16S
TAXOUT=qiime_16S_taxa_summary
#Pick OTUs against open ref ITS
if [ $CPU ]; then
pick_open_reference_otus.py -i $PWD/$FWD -o $PWD/$OUT -s 0.1 -p $PWD/16S_params.txt --otu_picking_method uclust --parallel --jobs_to_start $CPU
else
pick_open_reference_otus.py -i $PWD/$FWD -o $PWD/$OUT -s 0.1 -p $PWD/16S_params.txt --otu_picking_method uclust 
fi

#Summarize OTUs table
biom summarize-table -i $PWD/$OUT/otu_table_mc2_w_tax.biom

#Summarize Taxa from OTUs table
summarize_taxa_through_plots.py -i $OUT/otu_table_mc2_w_tax.biom -o $TAXSUM

# Plot Taxonomy Summary command 
#plot_taxa_summary.py -i taxa_summary/otu_table_mc2_w_tax.txt
plot_taxa_summary.py -i taxa_summary/otu_table_mc2_w_tax_L2.txt,taxa_summary/otu_table_mc2_w_tax_L3.txt,taxa_summary/otu_table_mc2_w_tax_L4.txt,taxa_summary/otu_table_mc2_w_tax_L5.txt,taxa_summary/otu_table_mc2_w_tax_L6.txt -o taxa_summary/taxa_summary_plots/
