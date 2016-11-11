#PBS -l nodes=1:ppn=16,mem=8gb -j oe
module load fastx_toolkit
module load vsearch
module load trimmomatic
# cutadapt is part of installed python
MINLEN=125
# merge reads previously split by sample into super file, assume reads can be matched to sample by their ID, eg PREFIX_readnumber - our convention is PROJECT.SAMPLEID
CPU=$PBS_NP
if [ ! $CPU ]; then
 CPU=2
fi
PWD=`pwd`
PREFIX=`basename $PWD`"_ITS"
FWD=$PREFIX.R1.fq
FWDTRIM=$PREFIX.R1_trimmed.fq
FWDFA=$PREFIX.R1.fna
REV=$PREFIX.R2.fq
REVTRIM=$PREFIX.R2_trimmed.fq
REVFA=$PREFIX.R2.fna

FWDNOCHIMERA=$PREFIX.R1.nochimeras.fna
REVNOCHIMERA=$PREFIX.R2.nochimeras.fna
UCHIMECHIMERA=/srv/projects/db/UNITE/v7.1/uchime_reference_dataset/ITS1_ITS2_datasets/uchime_sh_refs_dynamic_develop_985_01.01.2016.ITS1.fasta

# per https://docs.google.com/document/d/1b9sUBOhOzlJxvt6Uim3hQXwOghIhEKulREzoSv2nXlE/edit
# trim first 30 bp of read
# when using Kabir's primers
if [ ! -f $FWDNOCHIMERA ]; then
 if [ -f $REV.bz2 ]; then
   pbzip -d $REV.bz2
 elif [ ! -f $FWD ]; then
   zcat ITS_R1/ITS.*.fq.gz | cutadapt -q 20 -a GATCTCTTGGNTCTNGCATCGATGAAGAACG -e 0.2 -o $FWD --minimum-length $MINLEN - > cutadapt_R1.log
   java -jar $TRIMMOMATIC SE -phred33 $FWD $FWDTRIM LEADING:20 TRAILING:20 MINLEN:125
   fastq_to_fasta -Q33 < $FWDTRIM | fastx_trimmer -m $MINLEN > $FWDFA
 fi
 vsearch -uchime_ref $FWDFA -db $UCHIMECHIMERA -strand plus -nonchimeras $FWDNOCHIMERA -threads $CPU
 pbzip2 $FWDFA
fi

# per https://docs.google.com/document/d/1b9sUBOhOzlJxvt6Uim3hQXwOghIhEKulREzoSv2nXlE/edit
# trim last 14 bp of rev read 
if [ ! -f $REVNOCHIMERA ]; then
 if [ -f $REV.bz2 ]; then
  pbzip -d $REV.bz2
 elif [ ! -f $REV ]; then
   zcat ITS_R2/ITS.*.fq.gz | cutadapt -a GGAAACCTTGTTACGACTTTTACTTCCTCTAAATGACCAA -e 0.3 -q 20 -o $REV - > cutadapt_R2.log
   java -jar $TRIMMOMATIC SE -phred33 $REV $REVTRIM LEADING:20 TRAILING:20 MINLEN:125
   # in khmer / python
   fastq_to_fasta -Q33 < $REVTRIM | fastx_trimmer -m $MINLEN > $REVFA
 fi
 vsearch -uchime_ref $REVFA -db $UCHIMECHIMERA -strand plus -nonchimeras $REVNOCHIMERA -threads $CPU
 pbzip2 $REV
fi
