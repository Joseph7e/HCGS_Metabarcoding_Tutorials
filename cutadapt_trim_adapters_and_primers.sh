#!/usr/bin/sh
#SBATCH --ntasks=1
#SBATCH --job-name="CUTADAPT"
#SBATCH --output="CUTADAPT"


module purge


# Define variables
READ1="CTGTCTCTTATACACATCTCCGAGCCCACGAGAC" #Nexterera adapter in FWD
READ2="CTGTCTCTTATACACATCTGACGCTGCCGACGA" #Nexterera adapter in REV
PRIMER_F="TCAAGCAGAAGACGGCATACGAGAT" #Reverse complement of 3′ Illumina adapter
PRIMER_R="GCTGCGTTCTTCATCGATGC" #Reverse primer (ITS2)
MIN_LENGTH=50 # Discard trimmed reads that are shorter than MIN_LENGTH
OVERLAP_MIN_LENGTH=10
MIN_QUALITY=10
CUTADAPT="/mnt/lustre/macmaneslab/maa1024/.local/bin/cutadapt -q ${MIN_QUALITY} --minimum-length ${MIN_LENGTH} -O ${OVERLAP_MIN_LENGTH}"
NAMES=(`cat readnamelist.txt`)

mkdir trimmed

for i in "${NAMES[@]}"
do
	echo $i
	FORWARD_READ="${i}_R1_001.fastq"
	REVERSE_READ="${i}_R2_001.fastq"
	TRIMMED_R1="$(echo $i | cut -d'/' -f3)_R1_001.fq"
	TRIMMED_R2="$(echo $i | cut -d'/' -f3)_R2_001.fq"

	srun ${CUTADAPT} -a ${READ1} -A ${READ2} -g ${PRIMER_F} -G ${PRIMER_R} -o trimmed/${TRIMMED_R1} -p trimmed/${TRIMMED_R2} ${FORWARD_READ} ${REVERSE_READ}
done
