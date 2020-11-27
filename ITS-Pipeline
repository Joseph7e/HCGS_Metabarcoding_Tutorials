# ITS_metabarcoding_analyses
ITS2 pipeline
Sequences were amplified following the EMP, http://www.earthmicrobiome.org/protocols-and-standards/its/
Illumina Hiseq 2500, 250 bp paired-end reads.

## Nextera Adapters
### Adapters in Forward Reads
>Trans2_rc_in_20_sequences
CTGTCTCTTATACACATCTCCGAGCCCACGAGAC

### Adpeters in Reverse Reads
>Trans1_rc
CTGTCTCTTATACACATCTGACGCTGCCGACGA


## Primer Sequences
### EMP.ITSkabir reverse primer (ITS2), barcoded
Reverse complement of 3′ Illumina adapter -> CAAGCAGAAGACGGCATACGAGAT
Golay barcode -> NNNNNNNNNN
Reverse primer linker -> CG
Reverse primer (ITS2; Note: This is identical to ITS2 from White et al., 1990.) -> GCTGCGTTCTTCATCGATGC

## Reference Database : UNITE
#### https://unite.ut.ee/repository.php
#### https://plutof.ut.ee/#/datacite/10.15156%2FBIO%2F587481

wget "https://files.plutof.ut.ee/doi/0A/0B/0A0B25526F599E87A1E8D7C612D23AF7205F0239978CBD9C491767A0C1D237CC.zip"


qiime tools import   --type 'FeatureData[Taxonomy]'   --source-format HeaderlessTSVTaxonomyFormat   --input-path sh_   --output-path qiime-ref-taxonomy_99.qz

qiime tools import   --type 'FeatureData[Taxonomy]'   --source-format HeaderlessTSVTaxonomyFormat   --input-path sh_   --output-path q
iime-ref-taxonomy_99.qz


## Step 1: Trim Sequences and Remove Primers with cutadapt
sbatch ./cutadapt_trim_adapters_and_primers.sh

qiime tools import  --type 'SampleData[PairedEndSequencesWithQuality]' --input-path cutadapt_data/  --source-format CasavaOneEightSingleLanePerSampleDirFmt  --output-path cutadapt-paired-end.qza


## Step 1 NEW! : Trim sequences and remove primers in qiime2 : Make sure there are no reverse primsers on your forward reads cutadapt plugin which provides trim-paired option

qiime tools import  --type 'SampleData[PairedEndSequencesWithQuality]' --input-path raw_data/  --source-format CasavaOneEightSingleLanePerSampleDirFmt  --output-path raw-paired-end.qza

qiime cutadapt trim-paired --i-demultiplexed-sequences raw-paired-end.qza --o-trimmed-sequences trimmed-paired-end.qza --p-cores 60 --p-anywhere-f CTGTCTCTTATACACATCTCCGAGCCCACGAGAC --p-anywhere-r CTGTCTCTTATACACATCTGACGCTGCCGACGA --p-front-f CAAGCAGAAGACGGCATACGAGAT

## Step 2: DADA2 : after trimming primers, you may want to disable truncation filtering entirely by setting trunc_len to 0 

qiime dada2 denoise-paired --p-trim-left-f 0 --p-trim-left-r 0 --p-trunc-len-f 0 --p-trunc-len-r 0 --i-demultiplexed-seqs trimmed-paired-end.qza --o-table trimmed-0-0-table --o-representative-sequences trimmed-req-seqs --verbose --p-n-threads 60

## I also ran the single ends for comparison
qiime dada2 denoise-single --p-trim-left 0 --p-trunc-len 0 --i-demultiplexed-seqs cutadapt-single-end.qza --o-table cutadapt-single-end-0-0-tqble --o-representative-sequences cutadapt-single-end-rep-seqs --verbose --p-n-threads 60


## Step3: Assign Taxonomy: here we do it with qiime BLAST

qiime feature-classifier classify-consensus-blast --i-query trimmed-req-seqs.qz --i-reference-taxonomy reference_UNITE/qiime-ref-taxonomy_99.qza --i-reference-reads reference_UNITE/qiime_fasta_99.qza --o-classification unite_99_9_trimmed-paired-end-classification_blast.qza --p-perc-identity 0.9 --p-maxaccepts 1

qiime feature-classifier classify-consensus-blast --i-query cutadapt-single-end-rep-seqs.qza --i-reference-taxonomy reference_UNITE/qiime-ref-taxonomy_99.qza --i-reference-reads reference_UNITE/qiime_fasta_99.qza --o-classification unite_99_9_cutadapt-single-end-classification_blast.qza --p-perc-identity 0.9 --p-maxaccepts 1
































### Make blast database for taxonomy assignment (go into database rep set) only if using joes taoxnomy assignment
makeblastdb -dbtype nucl -in 99_otus.fasta -out 99_otus
#
## Make fresh directory for raw reads, all reads should be gzipped at this point.

mkdir raw_reads & cd raw_reads

mv /path/to/project/dir/*/*R1* ./
mv /path/to/project/dir/*/*R3* ./
#
## rename files to this format --> SampleName_barcode_L001_R1_001.fastq.gz
##### for your data I simply needed to fix the ones with ITS in it. (remove the -n to actually make the change)
rename -v -n 's/(.*)-(.*)__(.*)/$1$2_$3/' *
#
## Merge reads, add forward reads that did not merge to merged reads
cd raw_reads
join_reads_and_prep_for_qiime.py ./



## Truncate primers

truncate_reverse_primer.py -f seqs.fna -m mapping_file.txt -o truncate_reverse_primers

## Open Reference OTU Picking

pick_open_reference_otus.py -i seqs.fna -o pick_references_output_open -r /home/genome/joseph7e/MEG_its_test/its_database/rep_set/97_otus.fasta -p parameters

### Run qiime2 enviornment



## IMPORT TO QIIME 2 table
qiime tools import \
  --input-path ../otu_table_mc2.biom \
  --type "FeatureTable[Frequency]" \
  --source-format BIOMV210Format \
  --output-path feature-table-from_qiime1.qza

### Import to qiime 2 taxonomy

qiime tools import \
  --type "FeatureData[Taxonomy]" \
  --input-path ../uclust_assigned_taxonomy/rep_set_tax_assignments.txt \
  --output-path taxonomy_from_qiime1

### Summarize data in table
qiime feature-table summarize \
  --i-table feature-table-from_qiime1.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file ../../../Microbiome_ITS_Mapping_File.csv
  
  
### Summarize through barplots
qiime taxa barplot \
  --i-table feature-table-from_qiime1.qza \
  --i-taxonomy taxonomy_from_qiime1.qza \
  --m-metadata-file Microbiome_ITS_Mapping_File.tsv \
  --o-visualization taxa-bar-plots.qzv



## Create a tree

## Import the rrep set form qiime2

qiime tools import \
  --type "FeatureData[Sequence]" \
  --input-path ../rep_set.fna \
  --output-path rep_set_from_qiime1

qiime alignment mafft \
  --i-sequences rep_set_from_qiime1.qza \
  --o-alignment aligned-rep-seqs.qza

qiime alignment mask \
  --i-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza


qiime phylogeny fasttree \
  --i-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza


### root the tree

qiime phylogeny midpoint-root   --i-tree tree_unrooted_from_qiime1.qza   --o-rooted-tree rooted-tree.qza

### Rareify this shit

my_numbers : 6092, 2130, 10065


sampling_depth=10065

qiime diversity core-metrics \
  --i-phylogeny rooted-tree.qza \
  --i-table feature-table-from_qiime1.qza \
  --p-sampling-depth $sampling_depth \
  --output-dir core-metric_$sampling_depth


### ALpha diversity

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metric_$sampling_depth/faith_pd_vector.qza \
  --m-metadata-file Microbiome_ITS_Mapping_File.tsv \
  --o-visualization core-metric_$sampling_depth/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metric_$sampling_depth/evenness_vector.qza \
  --m-metadata-file Microbiome_ITS_Mapping_File.tsv \
  --o-visualization core-metric_$sampling_depth/evenness-group-significance.qzv
  
qiime diversity alpha-correlation \
  --i-alpha-diversity core-metric_$sampling_depth/faith_pd_vector.qza \
  --m-metadata-file Microbiome_ITS_Mapping_File.tsv \
  --o-visualization core-metric_$sampling_depth/faith-pd-correlation.qzv
  
qiime diversity alpha-correlation \
  --i-alpha-diversity core-metric_$sampling_depth/evenness_vector.qza \
  --m-metadata-file Microbiome_ITS_Mapping_File.tsv \
  --o-visualization core-metric_$sampling_depth/evenness-correlation.qzv  
  
  
### Beta diversity

categories: #SampleID,BarcodeSequence,LinkerPrimerSequence,SampleType,Year,State,WNSStatus,Species,Sex,Description

category=Year

qiime diversity beta-group-significance \
  --i-distance-matrix core-metric_$sampling_depth/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file Microbiome_ITS_Mapping_File.tsv \
  --m-metadata-category $category \
  --o-visualization core-metric_$sampling_depth/unweighted-unifrac-$category-significance.qzv


### Emperor PCOA plots (must be numerical)

sampling_depth=2130
#category=WNSStatus

qiime emperor plot \
  --i-pcoa core-metric_$sampling_depth/unweighted_unifrac_pcoa_results.qza \
  --m-metadata-file ../../../../Microbiome_ITS_Mapping_File.txt \
  --o-visualization core-metric_$sampling_depth/unweighted-unifrac-emperor.qzv

qiime emperor plot \
  --i-pcoa core-metric_$sampling_depth/bray_curtis_pcoa_results.qza \
  --m-metadata-file ../../../../Microbiome_ITS_Mapping_File.txt \
  --o-visualization core-metric_$sampling_depth/bray-curtis-emperor.qzv
