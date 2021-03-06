#PBS -l nodes=1:ppn=1,mem=1gb -j oe

# merge reads previously split by sample into super file, assume reads can be matched to sample by their ID, eg PREFIX_readnumber - our convention is PROJECT.SAMPLEID

PWD=`pwd`
PREFIX=`basename $PWD`"_16S"
if [ ! -f $PREFIX.R1.fna ]; then
 zcat 16S_R1/*.fa.gz > $PREFIX.R1.fna
fi
if [ ! -f $PREFIX.R2.fna ]; then
 zcat 16S_R2/*.fa.gz > $PREFIX.R2.fna
fi
