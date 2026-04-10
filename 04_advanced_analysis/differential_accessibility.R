# Subset the count matrix for the comparison groups
# Replace "GroupA" and "GroupB" with your specific experimental labels
comp_groups <- c("^GroupA", "^GroupB") 
comp_counts <- assay(counts)
comp_counts <- comp_counts[, grep(paste(comp_groups, collapse = "|"), 
                                  colnames(comp_counts))]

# Refine Metadata and Set the Baseline
# 'ref' defines the control group so that positive Fold Change = More Open in Treated
comp_metaData <- metaData %>% filter(Group %in% c("GroupA", "GroupB"))
comp_metaData$Group <- factor(comp_metaData$Group, levels = c("GroupB", "GroupA"))
comp_metaData$Group <- relevel(comp_metaData$Group, ref = "GroupB")

# Run DESeq2 Differential Model
# Analyzes changes in accessibility across the defined groups
comp_atacdiff <- DESeqDataSetFromMatrix(comp_counts, comp_metaData, 
                                        design = ~ Group, 
                                        rowRanges = rowRanges(counts))
comp_atacdiff <- DESeq(comp_atacdiff)
comp_atacdiff <- results(comp_atacdiff, format = "GRanges")

# Restrict to specific regions (e.g., Promoters)
# 'toOverLap' should be your pre-defined GRanges of interest (TSS ±3kb)
comp_atacdiff <- subsetByOverlaps(comp_atacdiff, toOverLap)

# Volcano Plot Visualization
# Highlights significantly changing peaks (padj < 0.05) in black
comp_atacdiff_df <- as.data.frame(comp_atacdiff)
comp_atacdiff_df <- comp_atacdiff_df %>% 
  mutate(identity = ifelse(padj < 0.05, "Significant", "Non-Significant"))

ggplot(comp_atacdiff_df, aes(x = log2FoldChange, y = -log10(padj), color = identity)) +
  geom_point(alpha = 0.8, size = 2) +
  scale_color_manual(values = c("Significant" = "black", "Non-Significant" = "grey")) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
  theme_bw() +
  labs(title = "Differential Accessibility: GroupA vs GroupB")

# Load libraries
library(ChIPseeker)

# Biological Annotation & Gene Mapping
# Map significant peaks to the nearest hg38 gene symbol
comp_anno <- comp_atacdiff[!is.na(comp_atacdiff$padj) & comp_atacdiff$padj < 0.05, ]
comp_anno <- annotatePeak(comp_anno, TxDb = TxDb.Hsapiens.UCSC.hg38.knownGene)
plotAnnoPie(comp_anno)

# Export Results
geneID <- mapIds(x = org.Hs.eg.db, keys = comp_anno@anno$geneId, 
                 keytype = "ENTREZID", column = "SYMBOL", multiVals = "first")

mcols(comp_anno@anno)$geneID <- geneID

write.table(as.data.frame(comp_anno), "Differential_Accessibility_Results.txt", 
            quote = F, sep = "\t")
