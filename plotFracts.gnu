reset
##set term svg size 900,480
set term svg size 600,600
set output 'fractionalheats.svg'
set title'YOURTITLE'
set cblabel'Fractional composition'
unset arrow
set lmargin 15.5

set style fill solid 1                                        
set xtic offset 0,-3 rotate 15                                
set boxwidth 0.1
set xtics rotate by 90 offset 0,-5.75
set key font"Arial:Bold,20pt"
set xtic font"Arial:Bold,20pt"
set ytic font"Arial:Bold,20pt"
set cbtic font"Arial:Bold,18pt"
set ylabel font "Arial:Bold,20pt"
set xlabel font "Arial:Bold,20pt"
set cblabel font "Arial:Bold,20pt"
set title font "Arial:Bold,20pt"
set bmargin 6.5

pack( r, g, b ) = 2**16*r + 2**8*g + b
set au
set key left
#set palette defined ( 0 "#2c7bb6", 0.15 "#abd9e9",  .25 "#fdae61", .4 "#d7191c")
set palette defined ( 0 "#2b83ba", 0.2 "#abdda4", 0.4 "#ffffbf", 0.6 "#fdae61", 0.8 "#d7191c")

unset grid
path="./FILENAME" #you file name here
#filename below too
!tail -n +2 FILENAME |awk '{print $2,$3,$4,$5,$6,$7}' > text-heatmap-frac 

dx=0.5;do for [i=1:5] {set arrow from dx+(i-1),-.5 to dx+(i-1),14.5 nohead linecolor "white" front}

plot path matrix rowheaders columnheaders with image,for [i=1:14] i-.5 title'' w l lc rgb 'white','text-heatmap-frac' matrix using 1:2:(sprintf('%.2f', 100*$3)."%") title'' w labels font ',17' textcolor rgb "#ffffff"
#set cbrange [0:1]
#dx=0.5;do for [i=1:3] {set arrow from dx+(i-1),-.5 to dx+(i-1),14.5 nohead linecolor "white" front}
#plot'K18-heatmap-mass' matrix rowheaders columnheaders with image,for [i=1:14] i-.5 title'' w l lc rgb 'white'



