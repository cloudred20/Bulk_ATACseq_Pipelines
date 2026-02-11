#!/bin/sh

# Runs FastQC on all FASTQ files after trimming

mkdir -p ./fastqc_results

# Run FastQC 
~/tools/FastQC/fastqc ./trimgalore_results/*.fq.gz -o ./trimgalore_results

# Run MultiQC
conda activate python3.7
multiqc ./fastqc_results -o ./fastqc_results
conda deactivate
