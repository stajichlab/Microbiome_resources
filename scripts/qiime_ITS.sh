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

UCHIMECHIMERA=/srv/projects/db/UNITE/v7.1/uchime_reference_dataset/ITS1_ITS2_datasets/uchime_sh_refs_dynamic_develop_985_01.01.2016.ITS1.fasta

if [ ! -f $FWDNOCHIMERA ]; then
 vsearch -uchime_ref $FWD -db $UCHIMECHIMERA -strand plus -nonchimeras $FWDNOCHIMERA -threads $CPU
fi

if [ ! -f $REVNOCHIMERA ]; then
 vsearch -uchime_ref $REV -db $UCHIMECHIMERA -strand plus -nonchimeras $REVNOCHIMERA -threads $CPU
fi

# currently this pipeline is only going to process FWD reads

OUT=qiime_ITS_openref_nochimera
TAXOUT=qiime_ITS_taxa_summary_nochimera

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
biom summarize-table -i $OUT/otu_table_mc2_w_tax.biom -f > $PREFIX.FWDNOCHIMERA.biom_summarize.txt

#Summarize Taxa from OTUs table
summarize_taxa_through_plots.py -i $OUT/otu_table_mc2_w_tax.biom -o $TAXOUT -f
