# Load required libraries for peak QC, genomic manipulation, and visualization
library(ChIPQC)
library(rtracklayer)
library(DT)
library(tidyverse)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)

# Import ENCODE Blacklist regions (high-signal artifacts/repetitive regions)
# Reference: ENCSR636HFF - PMID 31249361
blkList <- import.bed("ENCFF356LFX.bed.gz")

# Locate all MACS2 .narrowPeak files generated in the previous step
openRegionPeaks <- list.files(path = "macs2", recursive = T, pattern = ".narrowPeak", full.names = T)

# Initialize list to store QC results for each sample
qcRes <- NULL

# Iterate through BAM files to calculate ChIP-seq/ATAC-seq specific QC metrics
for (i in 1:length(bamfile)) {
qcRes[[i]] <- ChIPQCsample(reads = bamfile[i],                   # Filtered BAM file
                           peaks = openRegionPeaks[i],           # Corresponding MACS2 peak file
                           annotation = "hg38",                  # Reference genome                                   
                           chromosomes = NULL,                   # Process all chromosomes
                           blacklist = blkList)                  # Regions to flag for noise calculation
  
}

# Extract 'Reads in Peaks' (RiP%) and 'Reads in Blacklist' (RiBL%)
# High RiP% (>20%) and low RiBL% (<1%) indicate high-quality libraries
lapply(qcRes, function(x) QCmetrics(x)[c("RiBL%", "RiP%")])

## Calculate percentage of duplicated reads identified by ChIPQC
(unlist(lapply(qcRes, function(x) flagtagcounts(x)["DuplicateByChIPQC"]))/ 
    unlist(lapply(qcRes, function(x) flagtagcounts(x)["Mapped"])))*100

# Convert QC results to GRanges objects for downstream manipulation
MacsCalls <- lapply(qcRes, granges)
unlist(lapply(MacsCalls, length))

# Remove peaks that overlap with ENCODE blacklist regions to improve signal-to-noise
MacsCalls <- lapply(MacsCalls, function(x) x[!x %over% blkList])


# Verify final peak counts after filtering
cat("Peak counts after blacklist removal:\n")
unlist(lapply(MacsCalls, length))

# Label the list for organized downstream analysis
names(MacsCalls) <- bamfile.label
