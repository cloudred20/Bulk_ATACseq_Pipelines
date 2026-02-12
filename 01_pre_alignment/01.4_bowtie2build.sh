#!/bin/sh
# Generate Bowtie2 genome indexes for human genome (hg38)
# This script downloads reference FASTA files and builds Bowtie2 indexes
# Both ENSEMBL and UCSC versions are included

# Load Bowtie2 module (required if using a module-based system)
module load Bowtie2/

# Create output directory and move into it
mkdir bowtie2
cd bowtie2 

# 1. ENSEMBL annotation
# Downloads the primary assembly FASTA from ENSEMBL and builds index
wget https://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

# Build Bowtie2 index for ENSEMBL reference
# Output files will be prefixed with "Homo_sapiens"
bowtie2-build Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz Homo_sapiens

# 2. UCSC annotation
# Downloads hg38 FASTA from UCSC and builds index
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz

# Build Bowtie2 index for UCSC reference
# Output files will be prefixed with "hg38"
bowtie2-build hg38.fa.gz hg38
