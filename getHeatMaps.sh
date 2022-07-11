#make the siq and mass files for heatmaps
# prep for plotting heatmaps
# We have k27 and k9 groups so there are two groups below
head -1 K27_fractions |sed -e 's/#//g' |awk '{print $1,$2,$3,$4,$5}' > K27-heatmap-siQ #removed pound sed is obsolete now
#to get siQ efficiency we need alpha * IP_frags/input_frags
#fraction data compiled above is like IP_frag/tot_frags, etc. so factors of depth must be used here to 
#cancel depth in fractions, allowing depths in alpha to be only contribution
#in order from ./makeFracts.sh run above we have
#DMSOK27a.bed CBPK27ac.bed A485K27a.bed DMinput.bed CBinput.bed A4input.bed K27_fractions
#K18a485.alpha  K18cbp.alpha  K18dmso.alpha  K27a485.alpha  K27cbp.alpha  K27dmso.alpha
a1=`awk '{print $1*$3/$2}' K27dmso.alpha`
a2=`awk '{print $1*$3/$2}' K27cbp.alpha`
a3=`awk '{print $1*$3/$2}' K27a485.alpha`
#recall, the first row and first column are labels. hence index running 2-6 not 1-5.
tail -n +2 K27_fractions| awk -v a=$a1 -v b=$a2 -v c=$a3 '{print $1,a*$2/$5,b*$3/$6,c*$4/$7}' >> K27-heatmap-siQ
#####
head -1 K18_fractions |sed -e 's/#//g' |awk '{print $1,$2,$3,$4,$5}' > K18-heatmap-siQ #removed pound sed is obsolete now
a1=`awk '{print $1*$3/$2}' K18dmso.alpha`
a2=`awk '{print $1*$3/$2}' K18cbp.alpha`
a3=`awk '{print $1*$3/$2}' K18a485.alpha`
tail -n +2 K18_fractions| awk -v a=$a1 -v b=$a2 -v c=$a3 '{print $1,a*$2/$5,b*$3/$6,c*$4/$7}' >> K18-heatmap-siQ

#do mass heat maps
#A485K18params.in  CBPK18params.in  DMSOK18params.in
#A485K27params.in  CBPK27params.in  DMSOK27params.in
#DMSOK27a.bed CBPK27ac.bed A485K27a.bed DMinput.bed CBinput.bed A4input.bed K27_fractions
a1=`sed -n 4p DMSOK27params.in`
a2=`sed -n 4p CBPK27params.in`
a3=`sed -n 4p A485K27params.in`
head -1 K18_fractions |sed -e 's/#//g' |awk '{print $1,$2,$3,$4}' > K27-heatmap-mass
tail -n +2 K18_fractions| awk -v a=$a1 -v b=$a2 -v c=$a3 '{print $1,a*$2,b*$3,c*$4}' >> K27-heatmap-mass
a1=`sed -n 4p DMSOK18params.in`
a2=`sed -n 4p CBPK18params.in`
a3=`sed -n 4p A485K18params.in`
head -1 K18_fractions |sed -e 's/#//g' |awk '{print $1,$2,$3,$4}' > K18-heatmap-mass
tail -n +2 K18_fractions| awk -v a=$a1 -v b=$a2 -v c=$a3 '{print $1,a*$2,b*$3,c*$4}' >> K18-heatmap-mass


