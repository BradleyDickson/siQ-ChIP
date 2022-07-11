echo "RUN AS:
WGfrechet.sh filename HIGHsiq LOWsiq"
#WGfrechet.sh filename HIGHsiq LOWsiq lowparam highparam"
#alphal=`echo $7`
#alphah=`echo $6`

filename=`echo $1`
rm $filename 
sigmas=3.0 #1.414 #3.0 #1.414  
#ldesc=`echo 500`
#for desc in $ldesc; do
for((i=1;i<23;i++)); do #WG for visuals, sort later for BW conversion
rm *.outs #in case
rm tmphigh.bed tmplow.bed
grep 'chr'$i' ' $2 > tmphigh.bed
grep 'chr'$i' ' $3 > tmplow.bed
gfortran -O3 -fbounds-check -o frechet.exe frechet.f90
./frechet.exe tmphigh.bed tmplow.bed H$desc L$desc $sigmas
cat H$desc-L$desc.outs >> $filename
#awk '{if($5 < 10.99) print $0}' H$desc-L$desc.outs >> $filename
done
#get X and Y here
rm *.outs #in case
rm tmphigh.bed tmplow.bed
grep 'chrX ' $2 > tmphigh.bed
grep 'chrX ' $3 > tmplow.bed
./frechet.exe tmphigh.bed tmplow.bed H$desc L$desc $sigmas
cat H$desc-L$desc.outs >> $filename
rm *.outs #in case
rm tmphigh.bed tmplow.bed
grep 'chrY ' $2 > tmphigh.bed
grep 'chrY ' $3 > tmplow.bed
./frechet.exe tmphigh.bed tmplow.bed H$desc L$desc $sigmas
cat H$desc-L$desc.outs >> $filename

#done
gfortran -O3 -fbounds-check Bins.f90
./a.out $filename

if [ 1 -eq 0 ] ; then
gfortran -O3 -fbounds-check getalpha.f90
al=`./a.out $4 | sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g'`
at=`./a.out $5 | sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g'`
alpha=`echo $at/$al |bc -l` #ratio of alpha actually
echo $alpha 
##mean=`echo $params |awk '{print $1}'| sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g'`
##sig=`echo $params |awk '{print $2}'| sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g'`
##larg=`echo $mean+$sigmas*$sig |bc -l`
cmd=`echo "awk '{if(\\$5<0.5 && \\$7 <"$alpha"*1.25 ) print \\$2,\\$3,\\$4,1}' " $filename`
eval $cmd > $filename-1.25.trust
fi
