widths=30
narg=`echo $@ | wc |awk '{print $2}'`
if [ $narg -lt 4 ] ; then
echo 'Run this scrtip as:
./runCrunch.sh IPFILE INPUTFILE PARAMfile TAG

The path and name of IPFILE and INPUTFILE must be less than 65 characters
PARAMfile are the siqchip measurements
TAG is the name your final SIQ-ChIP file will have
Currently you are missing one of these arguments. <----
'
else 
ipfile=`echo $1`
infile=`echo $2`
paramfile=`echo $3`
tag=`echo $4`
nip=`wc -l $ipfile |awk '{print $1}'`
nin=`wc -l $infile |awk '{print $1}'`
legs=`awk '{sum+=$4} END {print sum/NR}' $infile`

dep=`echo $nin*$widths/3200000000./\(1-$widths/3200000000\) |bc -l` #average layer on input
echo $dep

#skip bug
gfortran -O3 -fbounds-check tracks.f90
./a.out $ipfile $infile $widths $widths


#get alpha
gfortran -O3 -fbounds-check getalpha.f90
a=`./a.out $paramfile $nin $nip`
echo "i called alpha already" $nin $nip $a
echo $a $nin $nip > $tag.alpha
#skip bug
echo $dep " is dep"
gfortran -O3 -fbounds-check mergetracks.f90
./a.out IP.data IN.data $a $dep 
mv mergedSIQ.data $tag.bed
echo "you created the file: " $tag.bed

nl=`wc -l $ipfile |awk '{print $1}'`
awk -v var=$nl '{print $1,$2,$3,$4/var}' IP.data > NormCovIP-$tag.bed
nl=`wc -l $infile |awk '{print $1}'`
awk -v var=$nl '{print $1,$2,$3,$4/var}' IN.data > NormCovIN-$tag.bed

fi
