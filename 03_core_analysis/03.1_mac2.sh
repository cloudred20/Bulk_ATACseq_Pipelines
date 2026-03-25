# Run MACS2
conda activate macs2

#!/bin/bash

# Create the output directory
mkdir -p macs2

#SBATCH --cpus-per-task=8
#SBATCH --mem=16G                
#SBATCH --output=logs/macs2_%A_%a.out
#SBATCH --error=logs/macs2_%A_%a.err

# Define groups: "path/to/file.bam:GroupName"
# You can add or remove groups by adding/deleting lines in this array
bam_files=(
    "./split_bam/NS_shifted.bam:NS"
    "./split_bam/IL13_shifted.bam:IL13"
    "./split_bam/PNSNS_shifted.bam:PNSNS"
    "./split_bam/PIL13NS_shifted.bam:PIL13NS"
    "./split_bam/PIL13IL13_shifted.bam:PIL13IL13"
)

# Iterate over the bam files and call peaks
# -g hs: Genome size for human (2.7e9)
# --keep-dup all: Retains all reads (standard for ATAC-seq if deduplicated previously)
# -f BAMPE: Uses paired-end insert sizes for better peak resolution
for entry in "${bam_files[@]}"; do
    IFS=":" read -r input_bam sample_name <<< "$entry"
    macs2 callpeak -t "$input_bam" -g hs --keep-dup all --cutoff-analysis -f BAMPE --outdir "./macs2/$sample_name" -n "$sample_name" 2> "./macs2/${sample_name}_macs2.log"
done

# Run MultiQC
conda activate python3.7
multiqc ./macs2/. -o ./macs2/
conda deactivate 
