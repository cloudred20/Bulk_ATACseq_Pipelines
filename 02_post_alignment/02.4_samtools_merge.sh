#!/bin/bash

# Merge high-quality biological replicates into pooled BAM files. Re-index and generate statistics for condition-level libraries.

#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --output=logs/merge_%A_%a.out
#SBATCH --error=logs/merge_%A_%a.err

# Create the output directory
mkdir -p bowtie2_results/merged_bam

# Set the paths
samtool_path=~/tools/samtools-1.17/samtools
output_dir=bowtie2_results/merged_bam
input_dir=bowtie2_results/filtered_bam  

# Define the input BAM files for each group.
# The number of groups and the number of replicates per group can vary depending on the experiment.
# Add or remove groups and replicate BAM files as needed.

input_files[0]="$input_dir/Sample1_quality_controlled.bam $input_dir/Sample2_quality_controlled.bam $input_dir/Sample3_quality_controlled.bam $input_dir/Sample4_quality_controlled.bam"
input_files[1]="$input_dir/Sample5_quality_controlled.bam $input_dir/Sample6_quality_controlled.bam $input_dir/Sample7_quality_controlled.bam $input_dir/Sample8_quality_controlled.bam"
input_files[2]="$input_dir/Sample9_quality_controlled.bam $input_dir/Sample10_quality_controlled.bam $input_dir/Sample11_quality_controlled.bam $input_dir/Sample12_quality_controlled.bam"
input_files[3]="$input_dir/Sample13_quality_controlled.bam $input_dir/Sample14_quality_controlled.bam $input_dir/Sample15_quality_controlled.bam $input_dir/Sample16_quality_controlled.bam"
input_files[4]="$input_dir/Sample17_quality_controlled.bam $input_dir/Sample18_quality_controlled.bam $input_dir/Sample19_quality_controlled.bam $input_dir/Sample20_quality_controlled.bam"

# Define the output names for the merged BAM files.
# Ensure the number of entries here matches the number of groups defined above.

merged_names=(
    "Group1.bam"
    "Group2.bam"
    "Group3.bam"
    "Group4.bam"
    "Group5.bam"
)

# Get the array index to access the correct input files
ARRAY_INDEX=$((SLURM_ARRAY_TASK_ID - 1))

# Get the input files for the current task
CURRENT_input_files=(${input_files[${ARRAY_INDEX}]})

# Merge BAM files, index merged BAM file, generate statistics using samtools stats
MERGED_NAME="${merged_names[${ARRAY_INDEX}]}"
${samtool_path} merge ${output_dir}/${MERGED_NAME} ${CURRENT_input_files[@]}
${samtool_path} index ${output_dir}/${MERGED_NAME}
${samtool_path} stats ${output_dir}/${MERGED_NAME} > ${output_dir}/${MERGED_NAME}_stats.txt

# Run MultiQC
conda activate python3.7
multiqc ./bowtie2_results/merged_bam/. -o ./bowtie2_results/merged_bam/
conda deactivate 