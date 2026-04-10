# Load libraries
library(GenomicAlignments); library(TxDb.Hsapiens.UCSC.hg38.knownGene); library(biomaRt)
library(DESeq2)

# Identify and import all MACS2 narrowPeak files recursively
peaks <- list.files(path = "macs2", pattern = "peaks.narrowPeak", recursive = T, full.names = T)

# Convert raw peak files into GRanges objects for genomic manipulation
# Simple = TRUE extracts only the core coordinates (Chr, Start, End)
peaks <- lapply(peaks, ChIPQC:::GetGRanges, simple = TRUE)

# Create a non-redundant (union) peak set
# unlist/GRangesList combines all peaks; reduce() merges overlapping intervals into a single representative peak to prevent double-counting.
peaks_nR <- GenomicRanges::reduce(unlist(GRangesList(peaks)))

# Determine which individual samples contribute to each consensus peak
peaks_overlap <- list()
for (i in 1:length(peaks)) {
  peaks_overlap[[i]] <- peaks_nR %over% peaks[[i]]
}

# Build an overlap matrix to track peak presence across groups
peaks_overlap_matrix <- do.call(cbind, peaks_overlap)
colnames(peaks_overlap_matrix) <- bamfile.label
mcols(peaks_nR) <- peaks_overlap_matrix

# Check total number of non-redundant peaks before filtering
length(peaks_nR)

# Remove artifacts and mitochondrial noise
# Exclude ENCODE Blacklist regions and ChrM to ensure high-quality regulatory targets
nrToCount <- peaks_nR[!peaks_nR %over% blkList & !seqnames(peaks_nR) %in% "chrM"]

# Check final number of peaks ready for count summarization
length(nrToCount)

# Organize BAM files and create a pointer list
# yieldSize = 5e+06 reads chunks at a time to manage memory during counting
bams <- c(paste("bowtie2_results/filtered_bam/Sample", 1:4, "_quality_controlled.bam", sep = ""),
          paste("bowtie2_results/filtered_bam/Sample", 5:8, "_quality_controlled.bam", sep = ""),
          paste("bowtie2_results/filtered_bam/Sample", 9:12, "_quality_controlled.bam", sep = ""),
          paste("bowtie2_results/filtered_bam/Sample", 13:16, "_quality_controlled.bam", sep = ""),
          paste("bowtie2_results/filtered_bam/Sample", 17:20, "_quality_controlled.bam", sep = ""))

bamFl <- BamFileList(bams, yieldSize = 5e+06)

# Quantify reads in the non-redundant (consensus) peak set
# singleEnd = FALSE ensures the tool treats your paired-end data correctly
counts <- summarizeOverlaps(features = peaks_nR,
                            reads = bamFl,
                            ignore.strand = FALSE,
                            singleEnd = FALSE)

# Label the count matrix by experimental replicate
colnames(counts) <- c(paste("Group1_Rep", 1:4, sep = ""), 
                      paste("Group2_Rep", 1:4, sep = ""),
                      paste("Group3_Rep", 1:4, sep = ""),
                      paste("Group4_Rep", 1:4, sep = ""),
                      paste("Group5_Rep", 1:4, sep = ""))

# Prepare metadata and build the DESeq2 object
Group <- factor(c(rep("Group1", 4), rep("Group2", 4), rep("Group3", 4), rep("Group4", 4), rep("Group5", 4)))
metaData <- data.frame(Group, row.names = colnames(counts))

atacDDS <- DESeqDataSetFromMatrix(assay(counts), metaData, ~Group, rowRanges = rowRanges(counts))

# Variance Stabilizing Transformation (VST)
# Normalizes data to homoscedasticity, making it suitable for PCA visualization
atacVSD <- vst(atacDDS, blind = FALSE)

# Principal Component Analysis (PCA)
# ntop = 112001 ensures we use all consensus peaks for the variance calculation
pcaData <- plotPCA(atacVSD, intgroup = "Group", ntop = 112001, returnData = TRUE) 
percentVar <- round(100 * attr(pcaData, "percentVar"))

# Visualization with ggplot2
# using ntop=112001 top features by variance
ggplot(pcaData, aes(PC1, PC2, fill=group)) +
  geom_point(size=4, shape = 21, alpha = 0.8) +
  xlab(paste0("PC1: ",percentVar[1],"% variance")) +
  ylab(paste0("PC2: ",percentVar[2],"% variance")) +
  theme_bw() + 
  theme(legend.position = "none", 
        axis.text = element_text(size = 14), 
        axis.title = element_text(size = 14))
