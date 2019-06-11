#parse out named-chr and run code on it
i=`echo $1`
fnamein=`echo $2`

grep -P chr$i"\t" $fnamein |sort -n -k2 > in.chr$i 
nl=`wc in.chr$i |awk '{print $1}'`
min=`head -1 in.chr$i |awk '{print $2}'`
max=`tail -1 in.chr$i |awk '{print $2}'`
echo $nl $min $max > flines$i
sum=0

fnameip=`echo $3`
grep -P chr$i"\t" $fnameip |sort -n -k2 > ip.chr$i 
nl=`wc ip.chr$i |awk '{print $1}'`
min=`head -1 ip.chr$i |awk '{print $2}'`
max=`tail -1 ip.chr$i |awk '{print $2}'`
echo $nl $min $max >> flines$i

#prep for target
cp 2Dlow-mem.f tmp$i.f
#name target
cmd=`echo "sed -i 's/LOCN/"$i"/g'" tmp$i.f`
eval $cmd
#compile and then run
gfortran -O3 -fbounds-check -o $i.exe tmp$i.f
./$i.exe

