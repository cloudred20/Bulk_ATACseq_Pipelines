#!/bin/bash
# Generate a data matrix of read counts over your peak regions using the deepTools computeMatrix function

# Define an array of file names to be processed
readarray -t files < <(ls bowtie2_results/merged_bam/*_merged.bam | sed 's/.*bowtie2_results\/merged_bam\///' | sed 's/_merged.bam.*//' | sort -u)

# Get the file name for this array task
file="${files[$SLURM_ARRAY_TASK_ID - 1]}"

# Run deeptools
srun computeMatrix reference-point -S bowtie2_results/merged_bam/${file}.bw -R macs2/${file}/${file}_summits.bed --outFileName bowtie2_results/merged_bam/${file}.matrix.gz --referencePoint TSS --beforeRegionStartLength 3000 --afterRegionStartLength 3000  --binSize 1 --numberOfProcessors max --verbose