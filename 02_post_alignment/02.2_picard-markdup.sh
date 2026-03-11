#!/bin/bash
# Mark PCR and optical duplicates to address over-amplification bias.

#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH --output=logs/markdup_%A_%a.out
#SBATCH --error=logs/markdup_%A_%a.err

# Load Picard module (required if using a module-based system)
module load picard/2.26.10-Java-15.lua

# Create the output directory
mkdir -p bowtie2_results/markdup_bam

# Define an array of file names to be processed
readarray -t files < <(ls fastq_files/*.fastq.gz | sed 's/.*fastq_files//' | sed 's/_R.*//' | sort -u)

# Get the file name for this array task
file="${files[$SLURM_ARRAY_TASK_ID - 1]}"

# Perform bowtie2 alignment for the specific file
srun java -jar $EBROOTPICARD/picard.jar MarkDuplicates -I bowtie2_results/sorted_bam${file}.sorted.bam -O bowtie2_results/markdup_bam${file}_marked_duplicates.bam -M bowtie2_results/markdup_bam${file}_marked_dup_metrics.txt

# Run MultiQC
conda activate python3.7
multiqc ./bowtie2_results/markdup_bam/. -o ./bowtie2_results/markdup_bam/
conda deactivate 