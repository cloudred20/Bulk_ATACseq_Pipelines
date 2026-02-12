#!/bin/bash
# Perform Bowtie2 alignment for trimmed paired-end FASTQ files

#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH -t 12:00:00
#SBATCH -o bowtie2_results/slurm_%A_%a.out
#SBATCH -e bowtie2_results/slurm_%A_%a.err

# Load Bowtie2 module (required if using a module-based system)
module load Bowtie2

# Create the output directory
mkdir -p bowtie2_results

# Define an array of file names to be processed
readarray -t files < <(ls fastq_files/*.fastq.gz | sed 's/.*fastq_files//' | sed 's/_R.*//' | sort -u)

# Get the file name for this array task
file="${files[$SLURM_ARRAY_TASK_ID - 1]}"

# Perform bowtie2 alignment for the specific file
srun bowtie2 --very-sensitive -X 2000 -x ./bowtie2/hg38 \
    -1 trimgalore_results${file}_R1_001_val_1.fq.gz \
    -2 trimgalore_results${file}_R2_001_val_2.fq.gz \
    -S bowtie2_results/${file}.sam
