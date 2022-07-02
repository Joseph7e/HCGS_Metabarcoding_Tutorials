# HCGS_Qiime2_Tutorial
Workflow for qiime2 workshop

![alt text](https://pbs.twimg.com/profile_images/788836988933681153/5x29uqk3_400x400.jpg)

## Useful Links:

['QIIME2'](https://docs.qiime2.org/2019.7/):https://docs.qiime2.org/2021.11/

['QIIME2 visuals'](https://view.qiime2.org/):https://view.qiime2.org/

['Moving Pictures Tutorial'](https://docs.qiime2.org/2021.11/tutorials/moving-pictures/): 

['Getting Oriented'](https://docs.qiime2.org/2021.11/tutorials/overview/#let-s-get-oriented-flowcharts):

['Metadata file'](https://docs.google.com/spreadsheets/d/1ZiRFItD26vgetcQQft41yiZgTJULstbdYrcprlgLws0/edit?usp=sharing)

# 16S Metabarcoding with Qiime 2
In this example we'll go over how to use QIIME 2 to analyze metabarcoding data.
These data are from set of mouse fecal samples provided by [Jason Bubier from The Jackson Laboratory](https://www.jax.org/research-and-faculty/faculty/research-scientists/jason-bubier).
The samples were run targeting the V1-V3 region of the 16S gene using the 27F - 534R primer pair on an Illumnina MiSeq on a paired end 300 bp run.
#### Primers
~~~
27F [20 bp]
 5'AGM GTT YGA TYM YGG CTC AG
534R [17 bp]
 5'ATT ACC GCG GCT GCT GG
~~~
For Metadata we have the sex, strain, age in days.
Our goal is to examine the correlation of the fecal microbiome we observe with these metadata.
We will primarily use the [Qiime 2](https://qiime2.org/) bioinformatics platform.
Qiime 2 is free and open source and available from Linux and OSX.
We will use the Qiime2 command line interface, there is also the ["Artifact" python API](https://docs.qiime2.org/2019.4/interfaces/artifact-api/) which can be more powerful.
## Getting the Data
We start by activating the Qiime 2 environment.  The server is a shared resource and we may want to be able to use different version of programs, like blast or R or Python than Qiime 2 requires.  To enable this Qiime 2 is given its own working environment with the exact version of all the programs it requires.  Qiime 2 currently puts out a new version about every 3 months.  You should upgrade varsions as they come available, even if you began with an earlier version.
~~~bash
#      version: qiime2-year.month
conda activate qiime2-2022.2
~~~
Now lets grab a copy of the data!  Notice that the copy command will warn us that it is skipping the reads directory, that is OK!
~~~bash
mkdir T3_Mouse
cd T3_Mouse/
cp /home/share/examples/cocaine_mouse/* .
ls
# mdat.tsv

less -S mdat.tsv
#SampleID       Sex     Treatment       Strain  Date    PrePost Dataset HaveBred        PerformedPCR    Description     pptreatment     Testing
#q2:types       categorical     categorical     categorical     numeric categorical     categorical     categorical     categorical             categorical     categorical
JBCDJ00OLJ1STT0B00000191821C7M7FGT1904904       F       Sham    CC004   0       Pre     Dataset1                Jax     19182_1 PreSham Train
JBCDJ00OLK1STT0B00000191671C7M7FGT1904905       F       Coc     CC041   0       Pre     Dataset1                Jax     19167_1 PreCoc  Train
JBCDJ00OLL1STT0B00000191771C7M7FGT1904906       M       Sham    CC004   0       Pre     Dataset1                Jax     19177_1 PreSham Test
JBCDJ00OLM1STT0B00000191861C7M7FGT1904907       M       Coc     CC004   0       Pre     Dataset1                Jax     19186_1 PreCoc  Test
JBCDJ00OLN1STT0B00000191791C7M7FGT1904908       F       Coc     CC004   0       Pre     Dataset1                Jax     19179_1 PreCoc  Train
JBCDJ00OLO1STT0B00000191691C7M7FGT1904909       F       Sham    CC041   0       Pre     Dataset1                Jax     19169_1 PreSham Test
JBCDJ00OLP1STT0B00000191731C7M7FGT1904910       M       Coc     CC041   0       Pre     Dataset1                Jax     19173_1 PreCoc  Test
JBCDJ00OLQ1STT0B00000191641C7M7FGT1904911       M       Coc     CC041   0       Pre     Dataset1                Jax     19164_1 PreCoc  Train
JBCDJ00OLR1STT0B00000191801C7M7FGT1904912       F       Sham    CC004   0       Pre     Dataset1                Jax     19180_1 PreSham Train
JBCDJ00OLS1STT0B00000191831C7M7FGT1904913       F       Coc     CC004   0       Pre     Dataset1                Jax     19183_1 PreCoc  Train
JBCDJ00OLT1STT0B00000191841C7M7FGT1904914       M       Sham    CC004   0       Pre     Dataset1                Jax     19184_1 PreSham Train
JBCDJ00OLU1STT0B00000191711C7M7FGT1904915       M       Coc     CC041   0       Pre     Dataset1                Jax     19171_1 PreCoc  Train
JBCDJ00OLV1STT0B00000191681C7M7FGT1904916       F       Sham    CC041   0       Pre     Dataset1                Jax     19168_1 PreSham Train

~~~
When we look at the metadata file we see the metadata that we will be able to use during our analysis.

Now we're ready to import the data into qiime. We will be using the qiime 2 command line interface, there is also a python interface called the Artifact API which can be a powerful tool.
~~~bash
# Anatomy of a qiime command
qiime plugin action\
   --i-inputs  foo\       ## input arguments start with --i
   --p-parameters bar\    ## paramaters start with --p
   --m-metadata mdat\     ## metadata options start with --m
   --o-outputs out        ## and output starts with --o
~~~
Qiime works on two types of files, Qiime Zipped Archives (.qza) and Qiime Zipped Visualizations (.qzv).  Both are simply renamed .zip archives that hold the appropriate qiime data in a structured format.  This includes a "provenance" for that object which tracks the history of commands that led to it.  The qza files contain data, while the qzv files contain visualizations displaying some data.  We'll look at a quality summary of our reads to help decide how to trim and truncate them.
~~~bash
qiime tools import\
   --type 'SampleData[PairedEndSequencesWithQuality]'\
   --input-path manifest.csv\
   --output-path demux\
   --input-format PairedEndFastqManifestPhred33
   ## the correct extension is automatically added for the output by qiime.
~~~

## Quality Control
Now we want to look at the quality profile of our reads.  Our goal is to determine how much we should truncate the reads before the paired end reads are joined.  This will depend on the length of our amplicon, and the quality of the reads.
~~~bash
qiime demux summarize\
   --i-data demux.qza\
   --o-visualization demux
~~~
When looking we want to answer these questions:

How much total sequence do we need to preserve an sufficient overlap to merge the paired end reads?

How much poor quality sequence can we truncate before trying to merge?

In this case we know our amplicons are about 390 bp long, and we want to preserve approximately 50 bp combined overlap.  So our target is to retain ~450 bp of total sequence from the two reads.  450 bp/2 = 225 bp but looking at the demux.qzv, the forward reads seem to be higher quality than the reverse, so let's retain more of the forward and less of the reverse.

## Denoising
We're now ready to denoise our data. Through qiime we will be using the program DADA2, the goal is to take our imperfectly sequenced reads, and recover the "real" sequence composition of the sample that went into the sequencer.
DADA2 does this by learning the error rates for each transition between bases at each quality score.  It then assumes that all of the sequences are errors off the same original sequence.  Then using the error rates it calculates the likelihood of each sequence arising.  Sequences with a likelihood falling below a threshold are split off into their own groups and the algorithm is iteratively applied.  Because of the error model we should only run samples which were sequenced together through dada2 together, as different runs may have different error profiles.  We can merge multiple runs together after dada2.  During this process dada2 also merges paired end reads, and checks for chimeric sequences.
~~~bash
qiime dada2 denoise-paired\
   --i-demultiplexed-seqs demux.qza\
   --p-trim-left-f 20 --p-trim-left-r 17\
   --p-trunc-len-f 250 --p-trunc-len-r 250\
   --p-n-threads 18\
   --o-denoising-stats dns\
   --o-table table\
   --o-representative-sequences rep-seqs
~~~
Now lets visualize the results of Dada2.
~~~bash
## Metadata on denoising
qiime metadata tabulate\
   --m-input-file dns.qza\
   --o-visualization dns
## Unique sequences accross all samples
qiime feature-table tabulate-seqs\
   --i-data rep-seqs.qza\
   --o-visualization rep-seqs
## Table of per-sample sequence counts
qiime feature-table summarize\
   --i-table table.qza\
   --m-sample-metadata-file mdat.tsv\
   --o-visualization table
~~~
Looking at dns.qzv first we can see how many sequences passed muster for each sample at each step performed by dada2.  Here we are seeing great final sequence counts, and most of the sequences being filtered in the initial quality filtering stage.  Relatively few are failing to merge, which suggests we did a good job selecting our truncation lengths.

In the table.qzv we can see some stats on our samples.  We have millions of counts spread across thousands of unique sequences and tens of samples.  We'll come back to the table.qzv file when we want to select our rarefaction depth.

In the rep-seqs.qzv we can see the sequences and the distribution of sequence lengths.  Each sequence is a link to a web-blast against the ncbi nucleotide database.
The majority of the sequences we observe are in our expected length range.
Later on we can use this to blast specific sequences we are interested in against the whole nucleotide database.

## Taxonomic Assignment
To assign taxonomy we will use a naive bayes classifier trained by the qiime2 authors on our gene region.
If we were using a different primer pair we would want to use a different method, like vsearch.

~~~bash
qiime feature-classifier classify-sklearn\
   --i-classifier /home/share/databases/SILVA_databases/silva-132-99-515-806-nb-classifier.qza\
   --i-reads rep-seqs.qza\
   --p-n-jobs 18\
   --o-classification taxonomy.qza
~~~

The classifier uses the kmers of the sequence as it's features.
The classification is the assignment that maximizes the bayes likelihood of that taxonomic assignment with the assumption that the kmers are independent.
This method can work well even when that assumption is violated.
~~~
Bayes Law:
posterior = (prior x evidence)/evidence
~~~
This is a commonly used machine learning method, including in the similar problem of text categorization.
You should only use it when you have a trained and validated classifier for your specific target region.
Let's visualize the taxonomy in a few different ways.
~~~bash
qiime metadata tabulate\
   --m-input-file taxonomy.qza\
   --o-visualization taxonomy.qzv

qiime taxa barplot --i-table table.qza\
   --i-taxonomy taxonomy.qza\
   --o-visualization taxa-barplot\
   --m-metadata-file mdat.tsv
~~~

## Diversity analysis
Our next step is to look at the diversity in the sequences of these samples.
Here we will use the differences between the sequences in the sample, and metrics to quantify those differences to tell us about the diversity, richness and evenness of the sequence variants found in the samples.
In doing so we will construct a de novo phylogenetic tree, which works much better if we first remove any spurious sequences that are not actually the target region of our 16S gene.
To do that we will use our taxonomic assignments to filter out sequences that remained Unassigned, are assigned only as Bacteria or are Eukaryotes.  We should look at what we are filtering out and try and find out what it is.

~~~bash
## exact match to filter out unassigned and Bacteria
## exact because bacteria is part of many other that we want to keep.
qiime taxa filter-table\
   --i-table table.qza\
   --i-taxonomy taxonomy.qza\
   --p-exclude "Unassigned,D_0__Bacteria"\
   --p-mode exact\
   --o-filtered-table bacteria-table

## Partial match to Eukaryota to filter out any Euks
qiime taxa filter-table\
   --i-table bacteria-table.qza\
   --i-taxonomy taxonomy.qza\
   --p-exclude "Eukaryota"\
   --o-filtered-table bacteria-table2

mv bacteria-table2.qza bacteria-table.qza

## Any additional sequences that we should exclude can be filtered on a "per feature basis"
## In this case we had some sequences that look like they were sequenced backwards!

qiime feature-table filter-features\
   --i-table bacteria-table.qza\
   --m-metadata-file exclude.tsv\
   --p-exclude-ids\
   --o-filtered-table bact-table.qza

## How much did we filter out?
qiime feature-table summarize\
   --i-table bacteria-table.qza\
   --m-sample-metadata-file mdat.tsv\
   --o-visualization bacteria-table

## Does it look very different?
qiime taxa barplot --i-table bacteria-table.qza\
   --i-taxonomy taxonomy.qza\
   --o-visualization bacteria-taxa-barplot\
   --m-metadata-file mdat.tsv

## Filter the sequences to reflect the new table.
qiime feature-table filter-seqs\
   --i-table bacteria-table.qza\
   --i-data rep-seqs.qza\
   --o-filtered-data bacteria-rep-seqs

qiime feature-table tabulate-seqs\
   --i-data bacteria-rep-seqs.qza\
   --o-visualization bacteria-rep-seqs
~~~

Now that we have only our target region we can create the de novo phylogenetic tree.
We'll use the default qiime2 pipeline because it is quick and easy to run, while providing good results.
This pipeline first performs a multi sequence alignment with mafft, this alignment would be significantly worse if we had not removed the non target sequences.
It then masks highly variable parts of the sequence as they add noise to the tree.
It then uses FastTree to create an unrooted phylogenetic tree which is then midpoint rooted.

~~~bash
qiime phylogeny align-to-tree-mafft-fasttree\
   --i-sequences bacteria-rep-seqs.qza\
   --o-alignment aligned-rep-seqs.qza\
   --o-masked-alignment masked-aligned-rep-seqs.qza\
   --o-tree unrooted-tree.qza\
   --o-rooted-tree rooted-tree.qza\
   --p-n-threads 18
~~~

Now we can look at the [tree we created on iToL](https://itol.embl.de/tree/20922221311082651562009639).
And for reference here is [the tree if we had not filtered it](https://itol.embl.de/tree/209222213110293351562082149).
We can see that the filtering upped the contrast between different groups.

Now we are ready to run some diversity analysis!
We are going to start by running qiimes core phylogenetic pipeline, this will take into account the relationships between sequences, as represented by our phylogenetic tree.
It will calculate a few key metrics for us, faiths-pd a measure of phylogenetic diversity, evenness, a measure of evenness and several beta statistics, like weighted and unweighted unifracs.
To do these comparisons we need to make our samples comparable to each other.
The way this is generally done is to rarefy the samples to the same sampling depth.
We can use the bacteria-table.qzv we made earlier to inform this decision.
We want to balance setting as high as possible of a rarefaction depth to preserve as many reads as possible, while setting it low enough to preserve as many samples as possible.

~~~bash
qiime diversity core-metrics-phylogenetic\
   --i-phylogeny rooted-tree.qza\
   --i-table bacteria-table.qza\
   --p-sampling-depth 89503\
   --m-metadata-file mdat.tsv\
   --output-dir core-metrics-results
~~~
From this initial step we can start by looking at some PCoA plots, we'll augment the PCoA with some of the most predictive features.

~~~bash
qiime feature-table relative-frequency\
   --i-table core-metrics-results/rarefied_table.qza\
   --o-relative-frequency-table core-metrics-results/relative_rarefied_table

qiime diversity pcoa-biplot\
   --i-features core-metrics-results/relative_rarefied_table.qza\
   --i-pcoa core-metrics-results/unweighted_unifrac_pcoa_results.qza\
   --o-biplot core-metrics-results/unweighted_unifrac_pcoa_biplot

qiime emperor biplot\
   --i-biplot core-metrics-results/unweighted_unifrac_pcoa_biplot.qza\
   --m-sample-metadata-file mdat.tsv\
   --o-visualization core-metrics-results/unweighted_unifrac_pcoa_biplot
~~~
We can see that the strains separate well, which implies that we should be able to find some separating distances in our data.

Lets start looking for those differences by looking at differences in diversity as a whole.
For numeric metadata categories we can plot our favorite metrics with the value of that metadata.

~~~bash
qiime diversity alpha-correlation\
   --i-alpha-diversity core-metrics-results/faith_pd_vector.qza\
   --m-metadata-file mdat.tsv\
   --o-visualization core-metrics-results/faith-alpha-correlation
~~~

Then for the categorical metadata catagories we can plot some box and whisker plots.
~~~bash
qiime diversity alpha-group-significance\
   --i-alpha-diversity core-metrics-results/faith_pd_vector.qza\
   --m-metadata-file mdat.tsv\
   --o-visualization core-metrics-results/faith-group-significance
~~~

## Differential Abundance Analysis
Now lets combine the taxonomy with the diversity analysis to see if there are related groups of organisms that are differentially abundant groups within the samples.
We'll start by combining our table and tree into a hierarchy and set of balances.
Balances are the weighted log ratios of sets of features for samples.
And we will be looking for significant differences in the balances between groups of samples.
~~~bash
qiime gneiss ilr-phylogenetic\
   --i-table bacteria-table.qza\
   --i-tree rooted-tree.qza\
   --o-balances balances --o-hierarchy hierarchy
~~~
To view the sets used in the balances we can plot out a heatmap of feature abundance which highlights the ratios.
~~~bash
qiime gneiss dendrogram-heatmap\
   --i-table bacteria-table.qza\
   --i-tree hierarchy.qza\
   --m-metadata-file mdat.tsv\
   --m-metadata-column Strain\
   --p-color-map seismic\
   --o-visualization heatmap.qzv
~~~
With this we can begin to look at specific balances to see their composition.
~~~bash
for ((i=0; i<10; i++)); do
  qiime gneiss balance-taxonomy\
     --i-table bacteria-table.qza\
     --i-tree hierarchy.qza\
     --i-taxonomy taxonomy.qza\
     --p-taxa-level 5\
     --p-balance-name y$i\
     --m-metadata-file mdat.tsv\
     --m-metadata-column Strain\
     --o-visualization y${i}_taxa_summary.qzv
done
~~~
