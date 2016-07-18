#PBS -l nodes=1:ppn=1,mem=4gb -j oe

module load usearch
bash scripts/00_make_combined_ITS.sh
PWD=`pwd`
PREFIX=`basename $PWD`"_ITS"
REV=$PREFIX.R2.fna
FWD=$PREFIX.R1.fna
DB=/srv/projects/db/UNITE/v7/utaxref/unite_v7/utax_its1.udb
OUT=UPARSE_ITS
mkdir -p $OUT
if [ ! -f $OUT/${PREFIX}.unique.fas ]; then
usearch -derep_fulllength $FWD -sizeout -relabel Uniq -fastaout $OUT/${PREFIX}.unique.fas -log $OUT/derep.log
fi

if [ ! -f $OUT/${PREFIX}.otus.fas ]; then
usearch -cluster_otus $OUT/${PREFIX}.unique.fas  -minsize 2 -otus $OUT/${PREFIX}.otus.fas  -relabel OTU -log $OUT/cluster_otus.log
fi

if [ ! -f $OUT/${PREFIX}.utax.txt ]; then
 usearch -utax $OUT/${PREFIX}.otus.fas -db $DB -strand both -fastaout $OUT/${PREFIX}.utax.fas -utax_cutoff 0.9 -utaxout $OUT/${PREFIX}.utax.txt \
 -log $OUT/utax_assign.log
fi

if [ ! -f $OUT/${PREFIX}.readmap.uc ]; then
 usearch -usearch_global $REV -db $OUT/${PREFIX}.utax.fas \
 -strand plus -id 0.97 -uc $OUT/${PREFIX}.readmap.uc \
 -maxaccepts 8 -maxrejects 64 -top_hit_only
perl -i -p -e 's/(ITS\.(\w+\d+)_\d+)/$1;barcodelabel=$2/' $OUT/${PREFIX}.readmap.uc
fi

if [ ! -f $OUT/${PREFIX}.OTU.tab ]; then
python ../../lib/uparse/uc2otutab.py $OUT/${PREFIX}.readmap.uc > $OUT/${PREFIX}.OTU.tab
perl ../../scripts/reorder_rows.pl $OUT/${PREFIX}.OTU.tab > $OUT/${PREFIX}.OTU.ordered.tab
fi
