#!/bin/sh

# Runs FastQC on all FASTQ files after trimming

# Create output directory
mkdir -p ./fastqc_results

# Run FastQC 
# Output reports (.html + .zip) will be written to trimgalore_results
~/tools/FastQC/fastqc ./trimgalore_results/*.fq.gz -o ./trimgalore_results

# Run MultiQC
conda activate python3.7
multiqc ./fastqc_results -o ./fastqc_results
conda deactivate
