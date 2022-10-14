**The first publication 'A physical basis for quantitative ChIP-seq' can be found at JBC [here.](https://pubmed.ncbi.nlm.nih.gov/32994221/) There is also an interactive web page devoted to the mathematical model [here.](http://proteinknowledge.com/siqD3/) The code below is described in a publicatoin forthcoming, preprint here.**  

# The siQ-ChIP codebase WARNINGs:

- Clone this repo. Do not cut and paste the fortran files.
- Paired-end sequencing only (this could be ignored but it will be you who suffers)
- Please don't cut and paste from spreadsheets and webpages. (unless you know how to remove special/binary characters)
- No dashes in your file names.
- Tripple check your file names in EXPlayout, this is the number one error source.
- Some human-genome-specific things are hardcoded. We have set this up for mouse but the code here is for **HUMAN**. Reach out to me if you're using this outside human genome, it is easy to adapt to other cases.
- Your bed files should be sorted as ```sort -k1,1 -k2,2n``` and should only contain 4 columns: chr start stop length. You can find details for how we align [here](https://www.jbc.org/content/early/2020/09/29/jbc.RA120.015353).
- If you want to use the getHeatMaps.sh script, you will have to customize it.

# Philosophy of use

siQ-ChIP is all about comparing sets of ChIP-seq data. Because of this, the siQ-ChIP code has been put together to make it easy to work on and compare multiple ChIP-seq datasets all at once. Therefore, the central object in using the siQ-ChIP code is the **EXPlayout** file. Once you create this file (and create parameter files) the siQ-ChIP scripts will do the rest. The EXPlayout file declares which IP, input, and parameter files go together to generate siQ-ChIP tracks and it declares which (if any) sets of siQ-ChIP tracks should be compared.

Building data looks like---> ****Do each of these****:

1) build bed files of sequencing data

2) build parameter files for siQ scaling

3) build EXPlayout file for your experiment

4) Link any annotations you want: ``` ln -s PATH/your_annotations.bed ./Annotations.bed``` ---> You gotta use Annotations.bed for the name you link to!

5) Execute ```./getsiq.sh``` or for HPC ```nohup ./getsiq.sh > Errors.out &```

Each of these steps (save for generating your aligned bed files) is discussed below.

# Things we do for siQ-ChIP data

- Compute <img src="https://render.githubusercontent.com/render/math?math=\alpha"> from DNA masses, DNA fragment lengths, reaction volumes

- Build IP track

- Build input track

- Build scaled tracks <img src="https://render.githubusercontent.com/render/math?math=s(x)=\alpha\frac{IP(x)}{input(x)}">

- Annotate fragment distributions for no-track visualization

- Compare response (scale and shape) in all pairs of <img src="https://render.githubusercontent.com/render/math?math=s_{cntl}"> and <img src="https://render.githubusercontent.com/render/math?math=s_{exp}">
    - detect and collect peak locations
    - compute area response
    - compute Frechet distances
    - write database for this information
- Annotate responses for track-based visualization    

All of this is rolled into the getsiq.sh script(s).

# To perform siQ-ChIP
At this point you have determined your antibody:chromatin isotherm and managed to demonstrate clear observation of signal (captured DNA mass). Your samples have all been sequenced and you have mapped your data to your target genome. You will need the **bed** files from your alignment and you will need to prepare the following parameter files for all of your samples. (Bed files are to be sorted as noted above.)

**Bed file format:** A bed file containing all QC'd paired-end reads for an IP and an INPUT sample. An example of the first few lines of one of these files are as follows where the chr, start, stop and length of reads is listed:

~~~~
chr1    100000041       100000328       287
chr1    100000189       100000324       135
chr1    10000021        10000169        148
chr1    100000389       100000596       207
chr1    100000748       100001095       347
chr1    100000917       100001015       98
chr1    100000964       100001113       149
chr1    10000122        10000449        327
chr1    100001232       100001602       370
~~~~

# Parameter files
Each ChIP reaction has its own parameter file that contains the information required to compute the siQ-ChIP quantitative scale. Each parameter file ***must*** have the following information in the following format (example given below):
```
input sample volume
total volume before removal of input
input DNA mass (ng)
IP DNA mass (ng)
IP average fragment length (from Bioanalyzer)
input average fragment length (from Bioanalyzer)
```

An example file would look like this:
```
50
250
135
10
400
382
```

At this point, you have a parameter file for each of your samples and you have a bed file for each sample (IP and input). Next, you need to build a "layout file" to tell the siQ-ChIP scripts which files go together and which samples should be quantitatively compared. 

# The EXPlayout file
siQ-ChIP enables the comparison of two or more ChIP-seq experiments. So we assume you have two IP datasets, two input datasets, and two sets of measurements required to evaluate the quantitative scale for each of these IP-cases.

The siQ-ChIP track for experiment 1 is built by combining ```IP1.bed input1.bed params1.in``` Likewise, the second experiment is processed using ```IP2.bed input2.bed params2.in```. This is to say that the IP, input, and measurements (params) will be integrated to produce one track (at quantified scale) for each experiment.

To build all the siQ-ChIP tracks and to compare annotated fragment distributions and tracks, we only need to build the following EXPlayout file and make sure our params files are defined (see below). ***No dashes in file names***
```
#getTracks: IP.bed input.bed params output_name
IP1.bed input1.bed params1.in exp1siq
IP2.bed input2.bed params2.in exp2siq
#getResponse: CNTR.bed EXP.bed output_name
exp1siq.bed exp2siq.bed exp1TOexp2
#getFracts: data any order, last is output_name
IP1.bed IP2.bed input1.bed input2.bed MyExperiment
#END
```

The getFracts section outputs datafiles named MyExperiment.

The names **exp1siq** and **exp2siq** are arbitrary, but be sure to use consistency in this file or your data will not be produced. In the example above, siQ scaled tracks are produced (called exp1siq.bed and exp2siq.bed) and then these two tracks are compared in the #getResponse section. In the last section, the initial bed files are used to compute the fractional composition of the sample DNA fragments.

Whitespace in this EXPlayout file will break your run. Be careful if you copy and paste to generate this file. Always check for characters that are hidden, particularly if you cut and paste from webpage like GitHub!!!

You need to provide aligned bed files for IP and input and you need to provide the paramter files (params.in) for computing the quantitative scale. The names of these files will not matter, but be consistent in your use of the file names.

#Build siQ-ChIP data
Now you can build your siQ-ChIP data using ```./getsiq.sh```


# EXPlayout for p300/CBP inhibition

In our publication we studied drug treatment in a cell system. We had *control* datasets:

-DMSO treated cells IP'd by H3K18ac and H3K27ac antibody and we have an input sample from DMSO treated cells.

We also had *experimental* datasets:

-A485 treated cells IP'd by H3K18ac and H3K27ac antibody and we have an input sample from A485 treated cells.
-CBP30 treated cells IP'd by H3K18ac and H3K27ac antibody and we have an input sample from CBP30 treated cells.

After sequencing, this left us with **six** IP datasets and **three** input datasets. These **nine** sets of sequenced fragments needed to be organized and compared correctly. We wanted to generate the siQ-ChIP quantitative tracks for each IP and to compare the impacts of A485 to DMSO and CBP30 to DMSO for each antibody.

The first step was to create **params.in** files for each of the **six** IPs. These files contain
-the input sample volume
-the total volume before removal of input
-input DNA mass (ng)
-IP DNA mass (ng)
-IP average fragment length (base pair, from Bioanalyzer)
-input average fragment length (base pair, from Bioanalyzer)

Here is an example file from DMSO H3K18ac IP named DMSOK18params.in:
```
50
250
98.7
22.68
499
382
```

Next, define the EXPlayout file as follows: 
```
#getTracks
CBPK27ac.bed CBinput.bed CBPK27params.in K27cbp
CBPK18ac.bed CBinput.bed CBPK18params.in K18cbp
A485K18a.bed A4input.bed A485K18params.in K18a485
A485K27a.bed A4input.bed A485K27params.in K27a485
DMSOK27a.bed DMinput.bed DMSOK27params.in K27dmso
DMSOK18a.bed DMinput.bed DMSOK18params.in K18dmso
#getResponse
K27dmso.bed K27cbp.bed dms2cbpK27
K27dmso.bed K27a485.bed dms2a48K27
K18dmso.bed K18cbp.bed dms2cbpK18
K18dmso.bed K18a485.bed dms2a48K18
#getFracts
DMSOK27a.bed CBPK27ac.bed A485K27a.bed DMinput.bed CBinput.bed A4input.bed K27_fractions
DMSOK18a.bed CBPK18ac.bed A485K18a.bed DMinput.bed CBinput.bed A4input.bed K18_fractions
#END
```
All of the parameter files, siQ-scaled tracks, and fastq files can be found at [GEO](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE207783) The complete database of peaks is here on git and is called databases-p300.tgz

# Plotting results with our scripts for gnuplot
The gnuplot scripts ```plotFracts.gnu``` and ```plotResponse.gnu``` are straightforward to use. These scripts will plot the heat map for fractional composition and the peak-based response distributions, respectively. Within each script you need to find the line
```path="./FILENAME" #you file name here```
and replace FILENAME with the name of your data. For plotFracts.gnu this will be the name you declared in the #getFracts section of the EXPlayout file. For plotResponse.gnu this will be the name you declared in the #getResponse section of EXPlayout **appended with -anno**. For example, based on the EXPlayout above for the p300/CBP inhibition studies we might use Ldms2cbpK27NS-anno for plotResponse.gnu and K27_fractions (or K18_fractions) for plotFracts.gnu. **You will have to modify the annotation class names in this file if you do not conform to the names used by the ChromHmm annotations.**

The ```getCircles.sh``` script will generate a gnuplot script output based on some selections you control in this shell script.  This is how we generated the SI figures showing the Frechet distance examples. To use, you would need to edit the ```awk``` statement and then use the script's output to define a gnuplot script. loading that script will create an svg like those shown in our SI-Fig. 2.

The, likely, most interesting data provided by this approach is the Response distribution. In our example EXPlayout above we wrote the response data to a file called ```exp1TOexp2```. You can access the response distribution by building a histogram on column 7 of this file. The shape distribution can be accessed by building a histogram on column 5 of this same file. You can build and plot these histograms however you like. The connection to your annotations, if you had them, will be recorded in the -anno versions of this file and you may also sort and aggregate those data however you like.

# Dependencies and assumptions
You need bc, gfortran, gnuplot version 5.2 or better. This has only been tested in bourne again shell.

# What to do after you run the code: Understanding outputs

- You ran the code with ```nohup ./getsiq.sh > output.log &```

All outputs and error messages are in the output.log file. This file is useful for checking that the code ran successfully. Most of what is written here are debug messages that should be suppressed but some explanation will be better.

Some of the things you can check before assuming it ran fine:

- Check for filename problems: ```grep 'file or path is incorrect' output.log``` If you get any output, then a file listed in EXPlayout was not found. The output.log file will help you find which file exactly was missing. 
- Check for potential error in aligned beds: ```grep 'counted it as this    0.000' output.log``` Any output here indicates an error in your aligned bed files. Could be sorting or format errors. Output.log can help you discover which file is broken.
- Check for fortran memory complaints: ```grep -B1 'Fortran runtime error' outputlog``` Any output here will contain information about exactly what code broke and on what line. After testing on several datasets, I see no reason you should have this error unless it stems from oddities in your data. You will have to investigate case by case and be prepared to validate data anomaly as valid and not as technical issues.
- Sanity check for fragment lengths: compare bioanalyzer lengths and aligned fragment lengths. You should not see a 2x in bioan with no ~2x also in aligned frags. Likely, this error should be brought to my attention and I can help you resolve it.

# The files created.

Lets take the following fake EXPlayout as our example.
```
#getTracks: IP.bed input.bed params output_name
IP1.bed input1.bed params1.in exp1siq
IP2.bed input2.bed params2.in exp2siq
#getResponse: CNTR.bed EXP.bed output_name
exp1siq.bed exp2siq.bed exp1TOexp2
#getFracts: data any order, last is output_name
IP1.bed IP2.bed input1.bed input2.bed MyExperiment
#END
```

The ```#getTracks``` section builds two siQ-ChIP quantitative tracks, exp1siq.bed and exp2siq.bed. The ```#getResponse``` section then compares those two tracks and generates the files exp1TOexp2, exp1TOexp2-frechNS-anno, and exp1TOexp2-anno. File use is interdependent between these two sections so double check EXPlayout to make sure there are no typos.

exp1TOexp2 is the database of peaks and information that got written by frechet.f90. You can look for ```write(81``` in frechet.f90 to see what is there. This file is further processed to generate exp1TOexp2-anno and exp1TOexp2-frechNS-anno. These two -anno files have the general format

```chromosome start-position stop-position response annotation```

Here, response will either be the peak height resonse or peak shape respnse where the shape data is given in the -frechNS-anno file. The names in the annotation column are derived from your linked Annotations.bed file. 

The annotated data can be traced back into the full database using simple bash. For example
```for w in `grep ANNOTATION exp1TOexp2-anno |awk '{print $2}'`; do
awk -v le=$w '{if($12==le+50) print $0}' exp1TOexp2;
done```
This will pull out the full data in ```exp1TOexp2``` for the peaks annotated as ```ANNOTATION```

The final section ```#getFracts``` uses the aligned bed files (IP1.bed and IP2.bed and inputs in this example) to count how many fragments fell on each annotation class (given by your linked Annotations.bed file). In this example, all of the data are collected in a file called MyExperiment. This file will contain a header that holds the sample names as specified in EXPlayout and each row of the file will report the fraction of the total fragments that overlap each annotation, with the annotation name being given in the first column of the file.

Here is an example of the data output by the ```#getFracts``` section:
```
Anno DMSOK27a CBPK27ac A485K27a DMinput CBinput A4input
TssBiv .00009119959709528315 .00010346963349701149 .00010621792224725879 .00005111123213655286 .00005094955546175296 .00005304027894009585
BivFlnk .00007054576052734924 .00007831659951018258 .00007436317267885877 .00003295741587275724 .00003107832866284489 .00003277584701011186
EnhBiv .00007277250228232961 .00007136688324734205 .00007712622018103859 .00008235268338122440 .00008095893364560789 .00008034714025088204
ReprPC .00446726349154591675 .00402783682390770127 .00771448176161494175 .01061163421021713394 .01102648298931843919 .01110402046329490882
ReprPCWk .05479853328070477602 .05057350857766083910 .08092030948576258742 .10703052906716744506 .10934921192132281429 .10945775171748991270
Quies .49070627375453412221 .48419135341702555601 .54120619085235206676 .64264482336302728409 .64403107391783560527 .64537931869685567075
TssA .04614812563690058330 .05357550378122772981 .04914204851119694447 .00479384680142899541 .00439222750128729767 .00456231415599871850
TssAFlnk .06495712279664306739 .07117465480106684141 .04633760843201331661 .00920173774920760226 .00867847137561031727 .00841733999904984304
TxFlnk .00484968218424906797 .00648658999330463629 .00490132745569366985 .00082812997702091843 .00079729077989254189 .00082656549525307268
Tx .03300289453838013702 .03861375244426283460 .03299161077672479985 .02722330216773862023 .02671903608842079309 .02668873903614291497
TxWk .13974395503349971612 .15305017931502679292 .12787083624349983112 .11399690965665495275 .11217057731134830009 .11080686547279850865
EnhG .00867761261915851816 .01037225749467808720 .00627251634641484889 .00266889698488263762 .00260744026890383224 .00256881176781574751
Enh .11654230636681297650 .12238549116555243664 .05966134230069773060 .03227487051378582149 .03147675463664021528 .02987073703350440219
ZNF_Rpts .00028925052680998686 .00030137779712409452 .00029322841616883325 .00034061897867501300 .00033050823599338997 .00034155148043793302
Het .00251450778728704079 .00233969077149294122 .00328295208458517318 .00437504248204096614 .00445036715523404625 .00452258470304143618
```

The file called 'exp1TOexp2' in the above example will contain a full record of the peaks compared. The format of that data is as follows:
```peak_number chr start end frechet 1.0 response area_numerator area_denominator max_numerator max_denominator left right``` 
where 'left' and 'right' are the location of the maximumfor that interval.
