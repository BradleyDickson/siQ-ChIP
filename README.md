# siQ-ChIP: sans spike-in Quantitative ChIP-seq
This is the small package of bash and fortran codes used to quantify ChIP-seq data without requiring "spike-ins" to be added to your ChIP-seq protocol.

The user must supply three inputs:

- A file called "params.in" which contains all the empirical coefficients of siQ-ChIP. One of our params.in files is included in this repository for reference. The file contents are given by a column of the table (Table S1 from the paper LINKtoPAPER) <img src="./paramstable.svg"/>

- A file called "resi" which specifies (1) the resolution with which to compute <a href="https://www.codecogs.com/eqnedit.php?latex=\hat{e}(x,L)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\hat{e}(x,L)" title="\hat{e}(x,L)" /></a>, (2) the bin-size for discreting the fragment length L, and (3) the resolution with which to compute <a href="https://www.codecogs.com/eqnedit.php?latex=\hat{e}(x)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\hat{e}(x)" title="\hat{e}(x)" /></a> and a coarse <a href="https://www.codecogs.com/eqnedit.php?latex=\hat{e}(x,L)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\hat{e}(x,L)" title="\hat{e}(x,L)" /></a>. the high-res <a href="https://www.codecogs.com/eqnedit.php?latex=\hat{e}(x,L)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\hat{e}(x,L)" title="\hat{e}(x,L)" /></a> is written to a file called "chr$.2d" where "$" is the chromosome number and the lower-res <a href="https://www.codecogs.com/eqnedit.php?latex=\hat{e}(x,L)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\hat{e}(x,L)" title="\hat{e}(x,L)" /></a> is write to "chr$.2dLR" where the "LR" stands for lower-resolution. The cumulative efficiency (<a href="https://www.codecogs.com/eqnedit.php?latex=\hat{e}(x)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\hat{e}(x)" title="\hat{e}(x)" /></a>) is written to "chr$.ce". The main figures from our paper (ADD CITE) were generated with a resi file that looked like this:

~~~~
300 50 10000
~~~~

- A file containing all QC'd paired-end reads. An example of the first few lines of this file are as follows where the start, stop and length of reads is listed:

~~~~
chr1	100000041	100000328	287
chr1	100000189	100000324	135
chr1	10000021	10000169	148
chr1	100000389	100000596	207
chr1	100000748	100001095	347
chr1	100000917	100001015	98
chr1	100000964	100001113	149
chr1	10000122	10000449	327
chr1	100001232	100001602	370
~~~~

- Our reads file was created with the line:
~~~~
awk -v MAQ=20 ‘$5>=MAQ && $2==99 || $5>=MAQ && $2==163 {print $3”\t”$4”\t”$4+$9-1} sample.sam | awk ‘$2<=$3{print $1”\t”$2”\t”$3”\t”$3-$2} | sort -k1,1 -k2,2n > outfile.bed
~~~~

## Running the calculation:

This code is designed to make use of a compute environment that supports a parallel filesystem and compute nodes with more than 23 CPU in a node. You may need to customize the scripts to prevent running all chromosomes simultaneously if your environment does not accommodate the intended batch execution.

In all of our applications the following script was used to launch whole genome processing, parallelized by chromosome number. **Notice that the paths to respective input and IP data files are specified in this script.** This script also waits in our PBS queue for all the jobs to complete before exiting PBS:

~~~~
#launch all copies
for((i=1;i<23;i++)); do
nohup ./Slave.sh $i inputPATH/inputFILE ipPATH/ipFILE &
done
#wait for all copies to complete
#code failure can hang this loop forever, FYI
nfs=0
while [ $nfs -lt 22 ] ; do
sleep 60
nfs=`for w in chr*.ce ; do echo $w;done | wc |awk '{print $1}'`
done
~~~~

The contents of the script Slave.sh were as follows:

~~~~
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

~~~~

This configuration allows any chromosome to be processed individually. To process chromosome "i" one would use:
~~~~
./Slave.sh i inputPath/inputFile ipPath/ipFile
~~~~

## Outputfiles and formats
The siQ-ChIP computations are done by the code 2Dlow-mem.f, which outputs several files. These are the files and their basic format:

- chr$i.ce is the siQ-ChIP cumulative efficiency <a href="https://www.codecogs.com/eqnedit.php?latex=\hat{e}(x)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\hat{e}(x)" title="\hat{e}(x)" /></a> for chromosome $i. Where "ce" is the cumulative efficiency, the file format is:
~~~~
chr$i start end ce
~~~~

- chr$i.2d is the siQ-ChIP object <a href="https://www.codecogs.com/eqnedit.php?latex=\hat{e}(x,L)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\hat{e}(x,L)" title="\hat{e}(x,L)" /></a>. Where "exl" is the value, the file format is:
~~~~
chr$i fragment-start fragment-length exl
~~~~

- chr$1.2dLR is a per-base-pair average of <a href="https://www.codecogs.com/eqnedit.php?latex=\hat{e}(x,L)" target="_blank"><img src="https://latex.codecogs.com/svg.latex?\hat{e}(x,L)" title="\hat{e}(x,L)" /></a> as described in the manuscript. the file format is the same as for chr$i.2d

The siQ-ChIP code processes all chromosomes in parallel and write output for each one. To combine them all into a single genome-wide summary use:
~~~~
cat chr*.ce | sort -k1,1 -k2,2n > sorted.bedGraph
~~~~

The sorted.bedGraph file can then be converted into a bigwig file using bedGraphToBigWig from UCSC tools.
