#PBS -l nodes=1:ppn=16,mem=48gb -j oe
CPU=$PBS_NP
if [ ! $CPU ]; then 
 CPU=2
fi
module load usearch
module load vsearch
bash scripts/00_make_combined_ITS.sh
PWD=`pwd`
PREFIX=`basename $PWD`"_ITS"
REV=$PREFIX.R2.nochimeras.fna
FWD=$PREFIX.R1.nochimeras.fna
DB=/srv/projects/db/UNITE/v7/utaxref/unite_v7/utax_its1.udb
OUT=UPARSE_ITS

if [ ! -f $FWD ]; then
 echo "run QIIME pipeline first"
 exit
fi

mkdir -p $OUT
if [ ! -f $OUT/${PREFIX}.unique.fas ]; then
vsearch --derep_fulllength $FWD -sizeout --relabel Uniq --output $OUT/${PREFIX}.unique.fas --log $OUT/derep.log --threads $CPU
fi

if [ ! -f $OUT/${PREFIX}.otus.fas ]; then
usearch -cluster_otus $OUT/${PREFIX}.unique.fas  -minsize 2 -otus $OUT/${PREFIX}.otus.fas  -relabel OTU -log $OUT/cluster_otus.log
fi

if [ ! -f $OUT/${PREFIX}.utax.txt ]; then
 usearch -utax $OUT/${PREFIX}.otus.fas -db $DB -strand both -fastaout $OUT/${PREFIX}.utax.fas -utax_cutoff 0.9 -utaxout $OUT/${PREFIX}.utax.txt \
 -log $OUT/utax_assign.log
fi

if [ ! -f $OUT/${PREFIX}.readmap.uc ]; then
 vsearch --usearch_global $FWD --db $OUT/${PREFIX}.utax.fas \
 --strand plus -id 0.96 --uc $OUT/${PREFIX}.readmap.uc --maxaccepts 8 --maxrejects 64 --top_hits_only --threads $CPU
perl -i -p -e 's/(ITS\.(\w+\.\d+\w?)_\d+)/$1;barcodelabel=$2/' $OUT/${PREFIX}.readmap.uc
fi

if [ ! -f $OUT/${PREFIX}.OTU.tab ]; then
python Microbiome_resources/lib/uparse/uc2otutab.py $OUT/${PREFIX}.readmap.uc > $OUT/${PREFIX}.OTU.tab
perl scripts/reorder_rows.pl $OUT/${PREFIX}.OTU.tab > $OUT/${PREFIX}.OTU.ordered.tab
fi
