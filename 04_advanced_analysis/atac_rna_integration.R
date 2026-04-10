library(tidyverse)

# Clean up ATAC results for joining (example using IL13vsNS)
atac_for_join <- as.data.frame(IL13vsNSanno_atacdiff@anno) %>%
  select(geneID, log2FoldChange, padj) %>%
  rename(SYMBOL = geneID, log2FC_ATAC = log2FoldChange, padj_ATAC = padj)

# Load your external RNA-seq DE results 
# (Ensure this file has a column named 'SYMBOL')
rna_res <- read.table("RNAseq_IL13vsNS_results.txt", header = TRUE, sep = "\t")

# Join datasets
cor_data <- inner_join(atac_for_join, rna_res, by = "SYMBOL")
