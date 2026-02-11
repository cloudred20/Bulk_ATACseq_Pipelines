#!/bin/sh
# Run trimgalore for automatic adapter decontamination (paired-end)
# Assumes:
#  - cutadaptenv is available in the conda environment

#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH -o trimgalore_results/slurm_%A_%a.out
#SBATCH -e trimgalore_results/slurm_%A_%a.err

# Create output directory
mkdir trimgalore_results

# Activate conda environment containing TrimGalore/cutadapt
conda activate cutadaptenv

# Build list of sample prefixes from FASTQ files
# Assumes files like: sample_R1_001.fastq.gz and sample_R2_001.fastq.gz

# Define an array of file names to be processed
readarray -t files < <(ls fastq_files/*.fastq.gz | sed 's/.*fastq_files//' | sed 's/_R.*//' | sort -u)

# Run TrimGalore (paired-end)
file="${files[$SLURM_ARRAY_TASK_ID - 1]}"

# Perform bowtie2 alignment for the specific file
srun ~/tools/TrimGalore-0.6.10/trim_galore -q 20 --phred33 --length 70 -o ./trimgalore_results --paired fastq_files${file}_R1_001.fastq.gz fastq_files${file}_R2_001.fastq.gz 

# Deactivate conda environment
conda deactivate
