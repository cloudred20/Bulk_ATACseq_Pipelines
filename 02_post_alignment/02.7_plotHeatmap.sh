#!/bin/bash
# Generate a heatmap and average plot from the data matrix using the plotHeatmap function in deepTools

# Define an array of file names to be processed
readarray -t files < <(ls bowtie2_results/merged_bam/*_merged.bam | sed 's/.*bowtie2_results\/merged_bam\///' | sed 's/_merged.bam.*//' | sort -u)

# Get the file name for this array task
file="${files[$SLURM_ARRAY_TASK_ID - 1]}"

# Run deeptools
srun plotHeatmap --matrixFile bowtie2_results/merged_bam/${file}.matrix.gz --outFileName bowtie2_results/merged_bam/${file}.png --colorMap=Blues --verbose