#PBS -l nodes=1:ppn=32,mem=64gb -j oe -N qiime.ITS
CPU=$PBS_NP
if [ ! $CPU ]; then
 CPU=2
fi
bash scripts/00_make_combined_ITS.sh
module unload python
module load qiime
module load ncbi-blast/2.2.26
source activate qiime

# setup the input data - this concats the compressed files into a single file for fwd or rev reads
PWD=`pwd`
PREFIX=`basename $PWD`"_ITS"
FWD=$PREFIX.R1.fna
REV=$PREFIX.R2.fna
FWDNOCHIMERA=$PREFIX.R1.nochimeras.fna
REVNOCHIMERA=$PREFIX.R2.nochimeras.fna

# older versions
#UNITEDB=/srv/projects/db/UNITE/v7/UNITEv7_sh_dynamic_s.fasta
#UNITETAX=/srv/projects/db/UNITE/v7/UNITEv7_sh_dynamic_s.tax
#UNITEDB=/srv/projects/db/UNITE/v7/UNITEv7_sh_99_s.fasta

UNITEDB=/srv/projects/db/UNITE/v7.1/sh_refs_qiime_ver7_dynamic_s_22.08.2016.fasta
UNITETAX=/srv/projects/db/UNITE/v7.1/sh_taxonomy_qiime_ver7_dynamic_s_22.08.2016.txt

# currently this pipeline is only going to process FWD reads

OUT=qiime_ITS_otus_uclust_nochimera
TAXOUT=qiime_ITS_taxa_summary_nochimera

if [ ! -d $OUT ]; then 
 parallel_pick_otus_uclust_ref.py -i $FWDNOCHIMERA -o $OUT -r $UNITEDB -s 0.6 -O $CPU
fi

OUT=qiime_ITS_openref_nochimera
#Pick OTUs against open ref ITS, use mutitthreaded where possible
if [ ! -d $OUT ]; then
    if [ $CPU ]; then
	pick_open_reference_otus.py -i $FWDNOCHIMERA -o $OUT -s 0.1 -p $PWD/its_params.txt -r $UNITEDB \
				    --suppress_align_and_tree --otu_picking_method uclust --parallel --jobs_to_start $CPU
    else
	pick_open_reference_otus.py -i $FWDNOCHIMERA -o $OUT -s 0.1 -p $PWD/its_params.txt -r $UNITEDB \
				    --suppress_align_and_tree --otu_picking_method uclust
    fi
fi

#Summarize OTUs table
biom summarize-table -i $OUT/otu_table_mc2_w_tax.biom > $PREFIX.FWDNOCHIMERA.biom_summarize.txt

#Summarize Taxa from OTUs table
#summarize_taxa_through_plots.py -i $OUT/otu_table_mc2_w_tax.biom -o $TAXOUT -f
