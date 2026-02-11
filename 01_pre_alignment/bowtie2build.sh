#!/bin/sh
# Generate genome indexes for hg38 using Bowtie2

# Load Bowtie2 module
module load Bowtie2/

mkdir bowtie2
cd bowtie2 

# ENSEMBL annotation  
wget https://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
bowtie2-build Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz Homo_sapiens

# UCSC annotation
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
bowtie2-build hg38.fa.gz hg38
