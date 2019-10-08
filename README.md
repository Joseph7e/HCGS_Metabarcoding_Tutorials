# HCGS_Qiime2_Tutorial
Workflow for qiime2 workshop

## Useful Links:

['Qiime2'](https://docs.qiime2.org/2019.7/)

['QIIME2 visuals'](http://support.illumina.com/content/dam/illumina-support/help/BaseSpaceHelp_v2/Content/Vault/Informatics/Sequencing_Analysis/BS/swSEQ_mBS_FASTQFiles.htm):

['Moving Pictures Tutorial'](http://support.illumina.com/content/dam/illumina-support/help/BaseSpaceHelp_v2/Content/Vault/Informatics/Sequencing_Analysis/BS/swSEQ_mBS_FASTQFiles.htm): SampleName_Barcode_LaneNumber_001.fastq.gz

['QIIME2 visuals'](http://support.illumina.com/content/dam/illumina-support/help/BaseSpaceHelp_v2/Content/Vault/Informatics/Sequencing_Analysis/BS/swSEQ_mBS_FASTQFiles.htm): SampleName_Barcode_LaneNumber_001.fastq.gz

## Starting Data:
Your starting data is found within a shared HCGS directory. To start we will make a working director and move all the sample data into it. Inside each sample directory are Illumina HiSeq 2500, paired-end, 250 bp sequencing reads. Looking in this directory you should see two files per sample, the forward and reverse reads. These files are in **FASTQ** format.

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
sed 's/:/_/g' total_reads.txt | awk -F'_' '{print $1,$2,"TGATCCTTCTGCAGGTTCACCTAC",$6}' | sed 's/ /\t/g' > mapping_file.tsv
echo -e "#SampleID\tBarcodeSequence\tLinkerPrimerSequence\tReadCounts" | cat - mapping_file.tsv > temp && mv temp mapping_file.tsv
```

## Edit the mapping file if needed
