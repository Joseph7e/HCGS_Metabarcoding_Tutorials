# HCGS_Qiime2_Tutorial
Workflow for qiime2 workshop

## Useful Links:

[Devins workflow](https://bitbucket.org/dwthomas/workshop-notes/src/master/QIIME%2016S%20walkthrough%20T3%202019.md)

['QIIME2'](https://docs.qiime2.org/2019.7/):https://docs.qiime2.org/2019.7/

['QIIME2 visuals'](https://view.qiime2.org/):https://view.qiime2.org/

['Moving Pictures Tutorial'](https://docs.qiime2.org/2019.4/tutorials/moving-pictures/): 

['Getting Oriented'](https://docs.qiime2.org/2019.7/tutorials/overview/#let-s-get-oriented-flowcharts):

## Starting Data:
Your starting data is found within a shared HCGS directory. To start we will make a working directory and move all the sample data into it. Inside each sample directory are Illumina HiSeq 2500, paired-end, 250 bp sequencing reads. Looking in this directory you should see two files per sample, the forward and reverse reads. These files are in **FASTQ** format.

* Make a new directory and copy the raw data over

```bash
mkdir ~/qiime2_tutorial
cd ~/qiime2_tutorial/
ls Project_dir/ 

# copy all the fastq files at once into a single directory
mkdir raw-reads
cp Project_dir/Sample_*/*.fastq.gz raw-reads/
ls raw-reads/
```


* Count the reads and make a basic metadata file
```bash
cd raw-reads/
zgrep -c '@HSQ' *_R1_* > ../total_reads.txt
cd ../
sed 's/:/_/g' total_reads.txt | awk -F'_' '{print $1,$2,"TGATCCTTCTGCAGGTTCACCTAC",$6,$1}' | sed 's/ /\t/g' > mapping_file.tsv
echo -e "#SampleID\tBarcodeSequence\tLinkerPrimerSequence\tReadCounts\tDescription" | cat - mapping_file.tsv > temp && mv temp mapping_file.tsv
```

* Edit the mapping file if needed


* Activate the qiime environment

```bash
module purge
module load anaconda/colsa
source activate qiime2-2019.4
```

* Anatomy of a qiime command
```bash
qiime plugin action\
   --i-inputs  foo\       ## input arguments start with --i
   --p-parameters bar\    ## paramaters start with --p
   --m-metadata mdat\     ## metadata options start with --m
   --o-outputs out        ## and output starts with --o

```

* import data into qiime

```bash
qiime tools import\
   --type 'SampleData[PairedEndSequencesWithQuality]' \
   --input-path raw-reads \
   --input-format CasavaOneEightSingleLanePerSampleDirFmt \
   --output-path demuxed-raw-reads.qza
```

* visualize raw data
```bash
mkdir visuals
qiime demux summarize   --i-data demuxed-raw-reads.qza   --o-visualization visuals/demuxed-raw-reads
```

* Run denoising and create feature table
time: 160 min

```bash
qiime dada2 denoise-paired\
   --i-demultiplexed-seqs demuxed-raw-reads.qza\
   --p-trim-left-f 19 --p-trim-left-r 8\
   --p-trunc-len-f 245 --p-trunc-len-r 230\
   --p-n-threads 18\
   --o-table table\
   --o-representative-sequences rep-seqs \
   --o-denoising-stats stats-dada2.qza
   ```

* visualize output

```bash
## Metadata on denoising
qiime metadata tabulate\
   --m-input-file stats-dada2.qza\
   --o-visualization visuals/stats-dada2

## Unique sequences accross all samples
qiime feature-table tabulate-seqs\
   --i-data rep-seqs.qza\
   --o-visualization visuals/rep-seqs
   
## Table of per-sample sequence counts
qiime feature-table summarize\
   --i-table table.qza\
   --m-sample-metadata-file mapping_file.tsv\
   --o-visualization visuals/table
   
 ```
 
* Download reference data
https://www.arb-silva.de/download/archive/qiime/

```bash

qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path majority_taxonomy_7_levels.txt --output-path qiime-ref-taxonomy_99

qiime tools import --type 'FeatureData[Sequence]'  --input-path silva_132_99_16S.fna --output-path reference-seqs

```

* Assign taxonomy to sequences

```bash
qiime feature-classifier classify-consensus-blast --i-query rep-seqs.qza --i-reference-taxonomy reference_database/qiime-ref-taxonomy_99.qza --i-reference-reads reference_database/reference-seqs.qza --o-classification classification_blast.qza --p-perc-identity 0.8 --p-maxaccepts 1
```

* Visualize taxonomy
```bash
qiime metadata tabulate\
   --m-input-file classification_sklearn.qza \
   --o-visualization visuals/taxonomy.qzv

qiime taxa barplot --i-table table.qza\
   --i-taxonomy classification_sklearn.qza \
   --o-visualization visuals/taxa-barplot-sklearn \
   --m-metadata-file mapping_file.tsv
   ```
