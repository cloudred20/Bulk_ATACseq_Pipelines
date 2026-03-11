#!/bin/bash
# Standardize alignment files and generate mapping statistics.

#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --output=logs/sort_index_%A_%a.out
#SBATCH --error=logs/sort_index_%A_%a.err

# Load Bowtie2 module (required if using a module-based system)
module load samtools/1.17

# Create the output directory
mkdir -p bowtie2_results/sorted_bam

# Define an array of file names to be processed
readarray -t files < <(ls fastq_files/*.fastq.gz | sed 's/.*fastq_files//' | sed 's/_R.*//' | sort -u)

# Get the file name for this array task
file="${files[$SLURM_ARRAY_TASK_ID - 1]}"

# Perform sorting and indexing for the specific file
srun ~/tools/samtools-1.17/samtools view -bS bowtie2_results${file}.sam | ~/tools/samtools-1.17/samtools sort -o bowtie2_results/sorted_bam${file}.sorted.bam && srun ~/tools/samtools-1.17/samtools index bowtie2_results/sorted_bam${file}.sorted.bam

# Generate statistics using samtools stats
srun ~/tools/samtools-1.17/samtools stats bowtie2_results/sorted_bam${file}.sorted.bam > bowtie2_results/sorted_bam${file}_stats.txt

# Run MultiQC
conda activate python3.7
multiqc ./bowtie2_results/sorted_bam/. -o ./bowtie2_results/sorted_bam/
conda deactivate 