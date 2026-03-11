#!/bin/bash
# Convert	bam	file to	a normalized bigwig	using the bamCoverage tool in deepTools

# Define an array of file names to be processed
readarray -t files < <(ls bowtie2_results/merged_bam/*_merged.bam | sed 's/.*bowtie2_results\/merged_bam\///' | sed 's/_merged.bam.*//' | sort -u)

# Get the file name for this array task
file="${files[$SLURM_ARRAY_TASK_ID - 1]}"

# Run deeptools
srun bamCoverage --bam bowtie2_results/merged_bam/${file}_merged.bam --outFileName bowtie2_results/merged_bam/${file}.bw --binSize 1 --normalizeUsing RPKM --effectiveGenomeSize 2913022398 --numberOfProcessors max --verbose 

