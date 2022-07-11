gfortran -O3 -fbounds-check -o readHist.exe binReads.f90
declare -a files
declare -a lines
i=0
for w in $@ ; do
files[$i]=`basename $w .bed`
lines[$i]=`wc -l $w |awk '{print $1}'`
./readHist.exe $w ./Annotations.sh
#./readHist.exe $w ./robanno.bed
name=`basename $w .bed`
mv fort.90 $name.90
#echo "going"
i=$((i+1))
done 

a=`awk '{print $4}' ./Annotations.bed |sort |uniq`;
#a=`awk '{print $4}' ./robanno.bed |sort |uniq`;
#echo "Anno DMSOK18ac A485K18ac CBPK18ac DMSOK27ac A485K27ac CBPK27ac" > fractionalComp-all
echo "Anno "${files[@]} #> fractionalComp-all #destroyed if it existed

declare -a items
#declare -A mtrx
#j=0
sumt=0
for w in $a;do
#mtrx[$j,0]=`echo $w`
#k=1
for((i=0;i<${#files[@]};i++)) ; do
name=`echo ${files[$i]}`
items[$i]=`grep $w' ' $name.90 |awk '{sum+=$4} END {print sum}'`;
sumt=`echo $sumt+${items[$i]} |bc`
#echo $i ${items[$i]} ${lines[$i]} ${files[$i]} $sumt
items[$i]=`echo ${items[$i]}/${lines[$i]}|bc -l`
#mtrx[$j,$k]=${items[$i]} 
#k=$((k+1))
done
echo $w ${items[@]} #>> fractionalComp-all
#j=$((j+1))
done
#transpose from somewhere in stackoverflow
#but we dont use it typically. can be used to make stacked bar graphs.
#stop general execution of this block
if [ 11 -eq 12 ] ; then
awk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' fractionalComp-all
fi


