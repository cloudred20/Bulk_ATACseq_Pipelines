#!/bin/sh

# Runs FastQC on all FASTQ files before trimming

# Assumes:
#  - FASTQ files are in ./fastq_files
#  - FastQC is installed at ~/tools/FastQC/fastqc (edit if different)
#  - multiqc is available in the conda environment

# Create output directory
mkdir -p ./fastqc_results

# Run FastQC on all gzipped FASTQ files
# Output reports (.html + .zip) will be written to fastqc_results
~/tools/FastQC/fastqc ./fastq_files/*.fastq.gz -o ./fastqc_results

# Run MultiQC
conda activate python3.7
multiqc ./fastqc_results -o ./fastqc_results
conda deactivate
