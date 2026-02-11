#!/bin/sh

# Runs FastQC on all FASTQ files before trimming

mkdir -p ./fastqc_results

# Run FastQC
~/tools/FastQC/fastqc ./fastq_files/*.fastq.gz -o ./fastqc_results

# Run MultiQC
conda activate python3.7
multiqc ./fastqc_results -o ./fastqc_results
conda deactivate
