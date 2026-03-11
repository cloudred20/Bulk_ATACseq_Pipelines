#!/bin/bash
# Exclude mitochondrial reads (chrM). Remove secondary alignments and low-quality reads (MAPQ < 10). Retain only properly paired, primary alignments.

#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --output=logs/filter_%A_%a.out
#SBATCH --error=logs/filter_%A_%a.err

# Create the output directory
mkdir -p bowtie2_results/filtered_bam

# Define an array of file names to be processed
readarray -t files < <(ls fastq_files/*.fastq.gz | sed 's/.*fastq_files//' | sed 's/_R.*//' | sort -u)

# Get the file name for this array task
file="${files[$SLURM_ARRAY_TASK_ID - 1]}"

# Filter out mitochondrial reads
# Filters out reads that are marked as secondary alignments (1024)
# Filters out reads with mapping quality less than 10 (q < 10) or non-unique alignment
# Filters out reads that are marked as unmapped, mate unmapped, not primary alignment, reads failing platform, duplicates and keeps only the properly paired reads (1804, -f 2)
srun ~/tools/samtools-1.17/samtools view -h bowtie2_results/markdup_bam${file}_marked_duplicates.bam \
    | grep -v "chrM" \
    | ~/tools/samtools-1.17/samtools view -F 1024 -b \
    | ~/tools/samtools-1.17/samtools view -q 10 -b \
    | ~/tools/samtools-1.17/samtools view -F 1804 -f 2 -b \
    | ~/tools/samtools-1.17/samtools sort -o bowtie2_results/filtered_bam${file}_quality_controlled.bam

# Generate statistics using samtools stats
srun ~/tools/samtools-1.17/samtools stats bowtie2_results/filtered_bam${file}_quality_controlled.bam > bowtie2_results/filtered_bam${file}_stats.txt

# Run MultiQC
conda activate python3.7
multiqc ./bowtie2_results/filtered_bam/. -o ./bowtie2_results/filtered_bam/
conda deactivate
