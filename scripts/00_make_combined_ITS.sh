#PBS -l nodes=1:ppn=1,mem=1gb -j oe
PWD=`pwd`
PREFIX=`basename $PWD`"_ITS"
if [ ! -f $PREFIX.R1.fna ]; then
 zcat ITS_R1/ITS.*.fa.gz > $PREFIX.R1.fna
fi
if [ ! -f $PREFIX.R2.fna ]; then
 zcat ITS_R1/ITS.*.fa.gz > $PREFIX.R2.fna
fi
