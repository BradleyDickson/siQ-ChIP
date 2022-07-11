### For plotting response distribution from -anno files
### using 15-state model

#SET YOUR FILE NAME IN paths= FIELD BELOW

set term svg enhanced size 600,480
set output'response.svg'  ### THIS IS THE SVG NAME <-------<------

binwidth=0.1;bin(x,width)=width*floor(x/width); 

set key font'Arial:Bold,12pt'
set tics font'Arial:Bold,12pt'
pack( r, g, b ) = 2**16*r + 2**8*g + b
numk18=1.0
numk27=1.0

set style line 1 lw 2 lc rgb "#a6cee3"
set style line 2 lw 2 lc rgb "#1f78b4"
set style line 3 lw 2 lc rgb "#b2df8a"
set style line 4 lw 2 lc rgb "#33a02c"
set style line 5 lw 2 lc rgb "#fb9a99"
set style line 6 lw 2 lc rgb "#e31a1c"
set style line 7 lw 2 lc rgb "#fdbf6f"
set style line 8 lw 2 lc rgb "#ff7f00"
set style line 9 lw 2 lc rgb "#cab2d6"
set style line 10 lw 2 lc rgb "#6a3d9a"
set style line 11 lw 2 lc rgb "#ffff99"
set style line 12 lw 2 lc rgb "#b15928"
set style line 13 lw 2 lc rgb "#01665e"
set style line 14 lw 2 lc rgb "#8c510a"
set style line 15 lw 2 lc rgb "#c51b7d"

### SET YOUR LABELS HOW YOU LIKE HERE
set xlabel'Ratio of peak areas' font'Arial:Bold,20pt'
set ylabel'Peak count' font'Arial:Bold,20pt'

set xr[0:40] #set your xrange
path="./FILENAME" #your file name here
set title 'TITLE' font'Arial:Bold,20pt' #your title here

plot path using (bin($4,binwidth)):(1.0/numk18) title'Total'smooth freq w l  lc rgb "#000000","< awk '{if($5==\"1_TssA\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'TssA 'smooth freq w l ls 1,"< awk '{if($5==\"2_TssAFlnk\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'TssAFlnk 'smooth freq w l ls 2,"< awk '{if($5==\"3_TxFlnk\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'TxFlnk 'smooth freq w l ls 3,"< awk '{if($5==\"4_Tx\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'Tx'smooth freq w l ls 4,"< awk '{if($5==\"5_TxWk\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'TxWk 'smooth freq w l ls 5,"< awk '{if($5==\"6_EnhG\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'EnhG 'smooth freq w l ls 6,"< awk '{if($5==\"7_Enh\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'Enh 'smooth freq w l ls 7,"< awk '{if($5==\"8_ZNF_Rpts\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'ZNF/Rpts 'smooth freq w l ls 8,"< awk '{if($5==\"9_Het\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'Het 'smooth freq w l ls 9,"< awk '{if($5==\"10_TssBiv\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'TssBiv'smooth freq w l ls 10,"< awk '{if($5==\"11_BivFlnk\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'BivFlnk'smooth freq w l ls 11,"< awk '{if($5==\"12_EnhBiv\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'EnhBiv'smooth freq w l ls 12,"< awk '{if($5==\"13_ReprPC\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'ReprPC'smooth freq w l ls 13,"< awk '{if($5==\"14_ReprPCWk\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'ReprPCWk'smooth freq w l ls 14,"< awk '{if($5==\"15_Quies\") print $0}' ". path using (bin($4,binwidth)):(1.0/numk18) title'Quies 'smooth freq w l ls 15
#,'< echo "2.61410371223814 500"' title'Ratio of \ {/Symbol a}\  'w impulse lw 2 lc rgb "#000000"