#!/bin/sh

# Simple FastQC + MultiQC wrapper
# Runs FastQC on all FASTQ files before trimming

FASTQ_DIR=./fastq_files
OUT_DIR=./fastqc_results

mkdir -p "$OUT_DIR"

# Run FastQC
fastqc "$FASTQ_DIR"/*.fastq.gz -o "$OUT_DIR"

# Activate conda env (edit name if needed)
conda activate python3.7

# Run FastQC via SLURM
srun fastqc "$FASTQ_DIR"/*.fastq.gz -o "$OUT_DIR"

# Run MultiQC
multiqc "$OUT_DIR" -o "$OUT_DIR"

conda deactivate
