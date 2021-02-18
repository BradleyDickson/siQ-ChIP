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

#get ip and input tracks
#the 100 100 here is the resolution in bp for the IP and input respectively
#you can change it but we wonder what it means to go lower than about a nucleosome in size
gfortran -O3 -fbounds-check tracks.f90
#the 100 100 is the resolution. you can change this but do change both numbers
./a.out $ipfile $infile 100 100
#get alpha
gfortran -O3 -fbounds-check getalpha.f90
a=`./a.out $paramfile`
#merge
gfortran -O3 -fbounds-check mergetracks.f90
./a.out IP.data IN.data $a
#./a.out IP.data INave.data $a
#mv to a name
mv mergedSIQ.data SIQ$tag.bed
echo "you created the file: " SIQ$tag.bed
fi
