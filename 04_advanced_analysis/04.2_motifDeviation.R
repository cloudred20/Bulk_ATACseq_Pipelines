# Load libraries
library(motifmatchr); library(TFBSTools); library(JASPAR2020); library(BSgenome.Hsapiens.UCSC.hg38)
library(chromVAR)

# Load JASPAR 2020 Motif Database
# Focuses on 'vertebrates' and the 'CORE' collection for high-confidence TF profiles
opts <- list(tax_group = "vertebrates", collection = "CORE", all_versions = FALSE)
motifsToScan <- getMatrixSet(JASPAR2020, opts)

# Correct for GC Content Bias
# Essential for ATAC-seq because Tn5 has a sequence preference and 
# different genomic regions vary in GC content, which can skew accessibility scores.
counts <- addGCBias(counts, genome = BSgenome.Hsapiens.UCSC.hg38)

# Motif Matching in Consensus Peaks
# Scans the peaks to find where the JASPAR motifs are located
motif_ix <- matchMotifs(motifsToScan, counts, genome = BSgenome.Hsapiens.UCSC.hg38)

# Compute ChromVAR Deviations
# Calculates how much the accessibility of peaks with a specific motif 
# deviates from the expected accessibility across all samples.
BiocParallel::register(BiocParallel::SerialParam()) # Run sequentially for stability
deviations <- computeDeviations(object = counts, annotations = motif_ix)
variability_Known <- computeVariability(deviations) # Rank motifs by how much they change
devZscores <- deviationScores(deviations)          # Normalized scores for visualization

# Identify the Most Variable TFs
# Merges variability metrics with Z-scores to identify 'driver' TFs
devTotal <- merge(variability_Known, devZscores, by = "row.names")
devTotal <- devTotal[order(devTotal$variability, decreasing = TRUE), ]
write.csv(devTotal, "Variability_of_JASPARmotifs_across_samples.csv", quote = FALSE)

devTotal[1:10, 1:7]

# Volcano Plot of TF Variability
# Motifs in the top-right corner are both highly variable and statistically significant.
ggplot(devTotal, aes(x = variability, y = -log10(p_value_adj))) +
  geom_point(alpha = 0.25, color = "red", size = 3) +
  geom_vline(xintercept = quantile(devTotal[,"variability"], .95), 
             linetype = "dashed", color = "darkblue") +
  xlab("Variability of motif-sets across samples") + 
  ylab("-log10(adjusted p.value)") + theme_classic()

# Heatmap of Top 5% Most Variable Motifs
# Visualizes how TF activity 'clusters' your samples (e.g., IL13 vs NS replicates).
devToPlot <- devTotal %>% 
  filter(variability >= quantile(devTotal[,"variability"], .95)) %>%
  select(-c(1:7)) %>% as.matrix()
rownames(devToPlot) <- devTotal$name[1:nrow(devToPlot)]

pheatmap::pheatmap(devToPlot, scale = "row", main = "Top Variable TF Motifs")
