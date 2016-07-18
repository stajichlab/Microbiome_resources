#PBS -l nodes=1:ppn=32,mem=64gb -j oe -N qiime.ITS
CPU=$PBS_NP
module unload python
module load qiime
module load ncbi-blast/2.2.26
source activate qiime

# setup the input data - this concats the compressed files into a single file for fwd or rev reads
bash scripts/00_make_combined_ITS.sh
PWD=`pwd`
PREFIX=`basename $PWD`"_ITS"
REV=$PREFIX.R2.fna
FWD=$PREFIX.R1.fna
UNITEDB=/srv/projects/db/UNITE/v7/UNITEv7_sh_dynamic_s.fasta
UNITETAX=/srv/projects/db/UNITE/v7/UNITEv7_sh_dynamic_s.tax
#UNITEDB=/srv/projects/db/UNITE/v7/UNITEv7_sh_99_s.fasta

# currently this pipeline is only going to process FWD reads

OUT=qiime_ITS_openref
TAXOUT=qiime_ITS_taxa_summary

#Pick OTUs against open ref ITS, use mutitthreaded where possible
if [ ! -d $OUT ]; then
if [ $CPU ]; then
pick_open_reference_otus.py -i $FWD -o $OUT -s 0.1 -p $PWD/its_params.txt -r $UNITEDB \
 --suppress_align_and_tree --otu_picking_method uclust --parallel --jobs_to_start $CPU
else
pick_open_reference_otus.py -i $FWD -o $OUT -s 0.1 -p $PWD/its_params.txt -r $UNITEDB \
 --suppress_align_and_tree --otu_picking_method uclust
fi
fi

#Summarize OTUs table
biom summarize-table -i $OUT/otu_table_mc2_w_tax.biom > $PREFIX.FWD.biom_summarize.txt

#Summarize Taxa from OTUs table
summarize_taxa_through_plots.py -i $OUT/otu_table_mc2_w_tax.biom -o $TAXOUT -f

# Plot Taxonomy Summary command 
plot_taxa_summary.py -i $TAXOUT/otu_table_mc2_w_tax_L2.txt,$TAXOUT/otu_table_mc2_w_tax_L3.txt,$TAXOUT/otu_table_mc2_w_tax_L4.txt,$TAXOUT/otu_table_mc2_w_tax_L5.txt,$TAXOUT/otu_table_mc2_w_tax_L6.txt -o $TAXOUT/taxa_summary_plots/
