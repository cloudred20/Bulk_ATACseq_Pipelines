## HPC-Ready Pipelines for Bulk ATAC-seq Processing and Analysis
This repository provides an HPC-optimized workflow for processing and analyzing bulk ATAC-seq data. Integrates best-practice tools for comprehensive quality control (QC), peak calling, and differential accessibility analysis, providing deep insights into chromatin accessibility and enhancer landscapes.

### Four major steps in ATAC-seq analysis include:

#### (1) Pre-alignment processing and QC: 
  * **Raw-reads QC:** Assess sequencing quality, adapter contamination, and duplication levels using **FastQC 0.12.1**. 
  * **Adapter trimming:** Remove adapter sequences and low-quality bases from paired-end reads using **Trim Galore 0.6.10**. 
  * **Read alignment:** Map trimmed reads to the reference genome (GRCh38.p13) using **Bowtie2 2 2.4.5** 

#### (2) Post-alignment processing and QC:
  * **Mark duplicates:** Identify and mark PCR/optical duplicates using **Picard 2.26.10 MarkDuplicates** to reduce over-amplification bias.
  * **Filtering:** Generate filtered BAM files using **Samtools 1.17** to retain only high-quality, properly paired reads. 
  * **Alignment-level QC:** Evaluate fragment size distribution and alignment quality metrics using R package, **ATACseqQC 1.28.0**.

#### (3) Core analysis (peak calling):
  * **Peak calling:** Detect accessible chromatin regions using **MACS2 2.2.6** in paired-end mode (-f BAMPE). 
  * **Peak-level QC:** Assess peak quality using **ChIPQC 1.40.0** including FRiP scores and blacklist region overlaps.

#### (4) Advanced analysis:
  * **Peak Annotation:** Annotate identified peaks with **ChIPseeker 1.40.0**, assigning genomic features and performing GO enrichment analyses.
  * **Motif Analysis:** Identify putative transcription factor binding sites (TFBS) using **JASPAR2020 0.99.10, TFBSTools 1.42.0 and motifmatchr 1.26.0**.
  * **Chromatin Accessibility Deviations:** Quantify motif accessibility deviations across conditions using **chromVAR 1.26.0**.
  * **Differential Accessibility Analysis:** Perform differential ATAC-seq with **DESeq2 1.44.0** using biological replicates for accurate dispersion estimation.
  * **Footprinting and Regulatory Network Reconstruction:** Detect TF footprints (Tn5 protection sites) and infer TF activity using motif information from **MotifDb 1.46.0**.

### Resources
  1. https://github.com/nf-core/atacseq
  2. https://doi.org/10.1186/s13059-020-1929-3

