#PBS -l nodes=1:ppn=16,mem=8gb -j oe
module load fastx_toolkit
module load vsearch\
# cutadapt is part of installed python

# merge reads previously split by sample into super file, assume reads can be matched to sample by their ID, eg PREFIX_readnumber - our convention is PROJECT.SAMPLEID
CPU=$PBS_NP
if [ ! $CPU ]; then
 CPU=2
fi
PWD=`pwd`
PREFIX=`basename $PWD`"_ITS"
FWD=$PREFIX.R1.fna
REV=$PREFIX.R2.fna
FWDNOCHIMERA=$PREFIX.R1.nochimeras.fna
REVNOCHIMERA=$PREFIX.R2.nochimeras.fna
UCHIMECHIMERA=/srv/projects/db/UNITE/v7.1/uchime_reference_dataset/ITS1_ITS2_datasets/uchime_sh_refs_dynamic_develop_985_01.01.2016.ITS1.fasta

# per https://docs.google.com/document/d/1b9sUBOhOzlJxvt6Uim3hQXwOghIhEKulREzoSv2nXlE/edit
# trim first 30 bp of read
# whenusing Kabir's primers
if [ ! -f $FWDNOCHIMERA ]; then
 if [ -f $REV.bz2 ]; then
   pbzip -d $REV.bz2
 elif [ ! -f $FWD ]; then
  if [ -f rev_adaptors.fa && -f fwd_adaptors.fa ]; then
    zcat ITS_R1/ITS.*.fa.gz | cutadapt -u 30 -f fasta -a file:rev_adaptors.fa -g file:fwd_adaptors.fa -o $FWD -r $PREFIX.F1.rest.fna - > cutadapt_R1.log
  else
  zcat ITS_R1/ITS.*.fa.gz | fasta_formatter | fastx_trimmer -f 30 | fastx_trimmer -t 29 > $FWD
#    zcat ITS_R1/ITS.*.fa.gz | cutadapt -u 30 -f fasta -o $FWD -r $PREFIX.F1.rest.fna - > cutadapt_R1.log
  fi
 fi
 vsearch -uchime_ref $FWD -db $UCHIMECHIMERA -strand plus -nonchimeras $FWDNOCHIMERA -threads $CPU
 pbzip2 $FWD
fi

# per https://docs.google.com/document/d/1b9sUBOhOzlJxvt6Uim3hQXwOghIhEKulREzoSv2nXlE/edit
# trim last 14 bp of rev read 
if [ ! -f $REVNOCHIMERA ]; then
 if [ -f $REV.bz2 ]; then
  pbzip -d $REV.bz2
 elif [ ! -f $REV ]; then
  if [ -f rev_adaptors.fa && -f fwd_adaptors.fa ]; then
   zcat ITS_R1/ITS.*.fa.gz | cutadapt -u 30 -f fasta -a file:rev_adaptors.fa -g file:fwd_adaptors.fa -o $REV -r $PREFIX.R2.rest.fna - > cutadapt_R2.log
  else
   zcat ITS_R1/ITS.*.fa.gz | fasta_formatter | fastx_trimmer -t 14 > $REV
  fi
 fi
 vsearch -uchime_ref $REV -db $UCHIMECHIMERA -strand plus -nonchimeras $REVNOCHIMERA -threads $CPU
 pbzip2 $REV
fi
