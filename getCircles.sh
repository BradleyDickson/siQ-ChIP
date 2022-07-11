declare -a li
#get a fail
#li=( `awk '{if($5 > 0.7 && $7 >3.25) print $0}' Ldms2a48K18NS | head -$1 |tail -1` )
#general statement
#li=( `awk '{if($5 < 0.25 && $7 <1.5) print $0}' Ldms2a48K18NS | head -$1 |tail -1` )
#this is mismatch
#li=( `awk '{if($5 > 0.55 && $7 <3.5) print $0}' Ldms2a48K18NS | head -$1 |tail -1` )
#li=( `awk '{if($5 > 0.4 && $5 < 0.5 && $7 <3.5) print $0}' Ldms2a48K18NS | head -$1 |tail -1` )
#this is the match: $1=5
li=( `awk '{if($5 > 0.2195 && $5 < 0.225) print $0}' Ldms2a48K18NS | head -$1 |tail -1` )
echo "#" ${li[@]}
chr=`echo ${li[1]}`
a=`echo ${li[2]}`
b=`echo ${li[3]}`
th=`echo ${li[9]}`
tl=`echo ${li[10]}`
df=`echo ${li[4]}`
s=`echo ${li[5]}`

xl=`echo \(-1*\($b-$a\)+$a\)/1 | bc `
xr=`echo \(2*\($b-$a\)+$a\)/1 | bc `
del=`echo $b-$a |bc`
#set terminal svg size 600,400 dynamic enhanced font 'Helvetica Bold,13.333' mousing name \"fillbetween_1\" butt dashlength 1.0
echo "
set terminal svg size 600,1200
set output'frechetEX.svg' "
echo "set multiplot layout 2,1"
#echo "set multiplot layout 3,1"
echo "set key font\"Arial:Bold,20pt\"
set xtic font\"Arial:Bold,20pt\"
set ytic font\"Arial:Bold,20pt\"
set ylabel font \"Arial:Bold,20pt\"
set xlabel font \"Arial:Bold,20pt\" "

echo "set au"
echo "set xr["$xl":"$xr"]"
echo "unset object;unset xtic"
echo "set xtics "$a","$del","$b
echo "set xtic font\"Arial:Bold,20pt\" "
#echo "set xtic font\"Arial:Bold,0pt\""
echo "set xlabel 'chr3:170747675-170756768'
set ylabel 'siQ'"
echo "pack( r, g, b ) = 2**16*r + 2**8*g + b"
#echo "set size 1,1"
#echo "set lmargin 16 
#set rmargin 13"
echo "set style fill solid 0.5"
echo "set xlabel '"$chr":"$xl"-"$xr"'"
echo "set ytics 0,.05,1"
echo "plot'chr1.k18dmso.bed' u (\$2+(\$3-\$2)/2.):(\$4):((\$3-\$2)) title'K18 DMSO'w boxes lc rgb pack(121,121,121),'chr1.k18a485.bed' u (\$2+(\$3-\$2)/2.):(\$4):((\$3-\$2)) title'K18 A485'w boxes lc rgb pack(255,38,0)"

echo "set au;set xtic 0,.5,1;unset xlabel"
echo "set xtic font\"Arial:Bold,20pt\" "
#echo "set bmargin at screen 0.1"
#echo "set bmargin at screen 0.14"
echo "set size ratio -1"
echo "set xr[-0.1:1.1]"
echo "set yr[0:]"
echo "set ylabel 'unitless scales'"
echo "a="$a
echo "b="$b
echo "th="$th
echo "tl="$tl
echo "df="$df
echo "s="$s

l1=`grep -n ' '$a' ' chr1.k18dmso.bed |awk '{print $1}' |sed -e 's/://g'`
l2=`grep -n ' '$b' ' chr1.k18dmso.bed |awk '{print $1}' |sed -e 's/://g'`
ll=`echo $l2-$l1+1 |bc`

for((j=0;j<$((ll+1));j++)); do

cmd=`echo "sed -n "$((l1+j))"p chr1.k18dmso.bed"`

declare -a ln
ln=( `eval $cmd |awk '{print $2,$3,$4}'` )
echo "set object "$i" circle at ("${ln[0]}".-a)/(b-a),("${ln[2]}"/th) size df fc rgb \"#ababab\" fillstyle solid 0.1"
done
echo "set ytics 0,.25,1"
echo "plot'chr1.k18dmso.bed' u ((\$2-a)/(b-a)):(\$4/th) title'' w lp lc rgb pack(121,121,121),'chr1.k18a485.bed' u ((\$2-a)/(b-a)):(s*\$4/tl) title''w lp lc rgb pack(255,38,0)"

echo "unset multiplot"
