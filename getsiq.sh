echo "We assume your annotations are sorted as 'sort -k1,1 -k2,2n' oterwise this will fail"
echo "Make sure your annotations are linked 'ln -s SORTEDannotations.bed ./Annotations.bed' HERE"
FILE=./Annotations.bed
if [ -f "$FILE" ] ; then
echo "Proceeding..."
#Sanity check for the EXPlayout file
explayout=./EXPlayout
if test -f "$explayout" ; then
z=`grep -n getTracks EXPlayout |sed -e 's/:/ /g' |awk '{print $1}'`;
x=`grep -n getResponse EXPlayout |sed -e 's/:/ /g' |awk '{print $1}'`;
c=`grep -n getFracts EXPlayout |sed -e 's/:/ /g' |awk '{print $1}'`;
v=`grep -n END EXPlayout |sed -e 's/:/ /g' |awk '{print $1}'`;
if [ $z -lt $x ] && [ $x -lt $c ] && [ $c -lt $v ] ; then #everything is good

if [ 2 -gt 1 ] ; then #for debugg
#############
### SIQ PART
#############
#loop all by names construct like: "IPfile-INPUTfile-PARAMSfile-outputNAME"
#you can list these in a single line or not, up to you. but the tic and quote 
# symbols must be correct! ... tic = ` and quote = "

z=`grep -n getTracks EXPlayout |sed -e 's/:/ /g' |awk '{print $1+1}'`;
x=`grep -n getResponse EXPlayout |sed -e 's/:/ /g' |awk '{print $1-1}'`;
if [ $z -le $x ] ; then
cmd=`echo "sed -n "$z","$x"p" EXPlayout`;
pare=`eval $cmd |sed -e 's/ /-/g' |sed -e 's/-$//g'`
echo $pare
for w in $pare ; do
ipfi=`echo $w |sed -e 's/-/ /g'|awk '{print $1}'`
inputfi=`echo $w |sed -e 's/-/ /g'|awk '{print $2}'`
paramfi=`echo $w |sed -e 's/-/ /g'|awk '{print $3}'`
namefi=`echo $w |sed -e 's/-/ /g'|awk '{print $4}'`
./runCrunch.sh $ipfi $inputfi $paramfi $namefi
done
fi #bounce if empty
fi


#pairs is a list of files and names, - is used to separate the names. in an entry ONE-TWO-THREE, the files ONE and TWO are compared and the data is written to a file named THREE
if [ 2 -gt 1 ] ; then # for debugg -toggle on if here --- 0 for off 2 for on
#pairs=`echo "SIQLnormK27dmso.bed-SIQLnormK27cbp.bed-Ldms2cbpK27NS SIQLnormK27dmso.bed-SIQLnormK27a485.bed-Ldms2a48K27NS SIQLnormK18dmso.bed-SIQLnormK18cbp.bed-Ldms2cbpK18NS SIQLnormK18dmso.bed-SIQLnormK18a485.bed-Ldms2a48K18NS"`
#--->dothis SIQLnormK27dmso.bed SIQLnormK27cbp.bed SIQLnormK27a485.bead

z=`grep -n getResponse EXPlayout |sed -e 's/:/ /g' |awk '{print $1+1}'`;
x=`grep -n getFracts EXPlayout |sed -e 's/:/ /g' |awk '{print $1-1}'`;
if [ $z -le $x ] ; then
cmd=`echo "sed -n "$z","$x"p" EXPlayout`;
pairs=`eval $cmd |sed -e 's/ /-/g' |sed -e 's/-$//g'`
echo $pairs
for w in $pairs ; do
hifi=`echo $w |sed -e 's/-/ /g'|awk '{print $1}'`
lofi=`echo $w |sed -e 's/-/ /g'|awk '{print $2}'`
filename=`echo $w |sed -e 's/-/ /g'|awk '{print $3}'`
./WGfrechet.sh $filename $hifi $lofi
nAn=`wc -l Annotations.bed |awk '{print $1}'`
if [ $nAn -gt 0 ] ; then
#something to discuss: +/-50 on center but not what was detected?
awk '{print $2,$12-50,$13+50,$7}' $filename | sort -k1,1 -k2,2n > $filename-preanno
gfortran -O3 -fbounds-check -o readHist.exe binReads.f90
./readHist.exe $filename-preanno ./Annotations.bed
mv matches.coords $filename-anno
awk '{print $2,$12-50,$13+50,$5}' $filename | sort -k1,1 -k2,2n > $filename-frechNS-preanno
gfortran -O3 -fbounds-check -o readHist.exe binReads.f90
./readHist.exe $filename-frechNS-preanno ./Annotations.bed 
#NaN can happen if a peak 'disapear' in the experiment track so we give a 1 to it as this indicates lost info
sed -i 's/NaN/1/g' matches.coords
mv matches.coords $filename-frechNS-anno
fi #only non-empty Annotations
done
fi #bounce if empty
fi

##########
##########
if [ 2 -gt 1 ] ; then #for debugg
#compute fractional composition, the user has to adapt scripts to get siq and mass heatmaps
z=`grep -n getFracts EXPlayout |sed -e 's/:/ /g' |awk '{print $1+1}'`;
x=`grep -n END EXPlayout |sed -e 's/:/ /g' |awk '{print $1-1}'`;
if [ $z -le $x ] ; then
nAn=`wc -l Annotations.bed |awk '{print $1}'`
if [ $nAn -gt 0 ] ; then
cmd=`echo "sed -n "$z","$x"p" EXPlayout`;
spare=`eval $cmd |sed -e 's/ /-/g' |sed -e 's/-$//g'`
#define a name file here like all others, loop over sets.
#the code below will work, but update to catch out last file as output!!!!
for w in $spare ; do 
files=`echo $w | sed -e 's/-/ /g'` 
declare -a list
list=( `echo $files` )
nw=`echo ${#list[@]}`
listed=`for((i=0;i<$nw;i++)); do if [ $i -lt $((nw-1)) ] ; then echo ${list[$i]}; else echo "> "${list[$i]};fi;done`
#echo $listed
cmd=`echo "./makeFracts.sh $listed"`
eval $cmd 
sed -E -i 's/^[0-9][0-9]_|^[0-9]_//g' ${list[$((nw-1))]}
done   ##########How to deal with the naming situation?
fi #bounce if Annotations.bed is empty
fi #bounce if empty
fi #full make fractions


else
echo "Your EXPlayout is out of order.";
fi
else 
echo "You have no EXPlayout file."
fi

## Shoulder plots
#gfortran -O3 -fbounds-check -o shoulder.exe shoulders.f90
else
echo "I don't see your Annotations.bed file here.
 Please link to an empty file if you don't have any annotations. 
 For example, run 'touch Annotations.bed' and try again. Your data will be built without annotations."

fi
