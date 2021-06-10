# siQ-ChIP: sans spike-in Quantitative ChIP-seq
This is the small package of bash and fortran codes used to quantify ChIP-seq data without requiring "spike-ins" to be added to your ChIP-seq protocol.

**The publication 'A physical basis for quantitative ChIP-seq' can be found at JBC [here.](https://www.jbc.org/content/early/2020/09/29/jbc.RA120.015353) There is also an interactive web page devoted to the mathematical model [here.](http://proteinknowledge.com/siqD3/)**

This is v2.0.0 of the siQ-ChIP software. The workflow is streamlined and simplified. The output is automatically in fraction-fragments-captured (so the <a href="https://www.codecogs.com/eqnedit.php?latex=\langle&space;L&space;\rangle" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\langle&space;L&space;\rangle" title="\langle L \rangle" /></a> factor from the paper may be avoided now) and resolution is set to 100bp. This is hard coded in the runCrunch.sh script, and can be edited. Lastly, the cycles used in library prep are currently assumed equal for inputs and IPs. If you need this changed, let us know.

The user must supply the following inputs:

- A file called "params.in" which contains all the empirical coefficients of siQ-ChIP. One of our params.in files is included in this repository for reference. The file contents are given by a column of the interactive table [here](./interactive_siQ_table.xlsx) originally contributed by Robert Vaughan. We note that you may enter Library 'concentration' as ng/uL. Please follow indicated units.


- A file containing all QC'd paired-end reads for an IP and an INPUT sample. An example of the first few lines of one of these files are as follows where the start, stop and length of reads is listed:

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

This is now a serial process requiring 1 cpu, running for a few minutes on our HPC. The IPfile and INPUTfile paths+names must not exceed 65 characters. THESE are to be SORTED BED files. The TAG argument is simply the name you wish for your output siQ-ChIP track. **gfortran is required** though you can use a different compiler if you modify runCrunch.sh.

~~~~
./runCrunch.sh IPFILE INPUTFILE params.in TAG
~~~~

The contents of the script runCrunch.sh were as follows:

~~~~
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
~~~~


## Outputfiles and formats

The code will output a bedfile named SIQtag.bed where tag is specified at runtime using the TAG argument of runCrunch.sh

The bedGraph file can then be converted into a bigwig file using bedGraphToBigWig from UCSC tools.
