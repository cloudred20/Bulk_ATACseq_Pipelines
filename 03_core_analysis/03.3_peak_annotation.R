# Load libraries for genomic feature annotation and reference genome data
library(ChIPseeker)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(BSgenome.Hsapiens.UCSC.hg38)

# Assign your sample labels to the filtered peak list
names(MacsCalls) <- bamfile.label

# Annotate peaks using the UCSC hg38 database
# tssRegion: Defines the promoter as ±3 kb around the Transcription Start Site
peakAnnoList <- lapply(MacsCalls, annotatePeak, TxDb = TxDb.Hsapiens.UCSC.hg38.knownGene,
                       tssRegion=c(-3000, 3000))

# Visualize the distribution of genomic features (Promoter, Intron, Distal Intergenic, etc.)
# This bar plot shows if your ATAC-seq signal is predominantly in promoters.
plotAnnoBar(peakAnnoList)

# Visualize the distance from each peak to the nearest TSS
# Expect a sharp distribution centered at 0 for high-quality ATAC-seq.
plotDistToTSS(peakAnnoList)
