## ATAC-seq Workflow:

ATAC-seq is used to interrogate chromatin accessibility, providing insights into enhancer landscapes, chromatin states, and differences in accessibility between normal and diseased samples. 

### Four major steps in ATAC-seq analysis include:

#### (1) Initial Quality Control and alignment (QC): 
  * **Raw-reads QC:** The sequence quality of raw reads including per-base sequence quality, per-base GC content, adapter contamination, and sequence duplication levels are assessed using tools like **FastQC 0.12.1**. 
    - High base quality scores are acceptable with a modest decline toward the 3′ end of reads.
    - Tn5 transposase bias may occur, as it cleaves accessible chromatin to insert sequencing adapters.
    - Sharp peaks in a smooth distribution may indicate contaminants like adapter dimers.
    - PCR duplication can result in overrepresentation of certain fragments due to biased amplification.
    - Quality metrics should show no major deviations in GC content or read length distribution.
    - Consistency in quality metrics is expected across all samples within the same experimental batch and sequencing run.
  
  * **Adapter trimming:** Paired-end reads will be trimmed for adapter contamination and low-quality bases using **Trim Galore 0.6.10**. 
    - Reads will be processed in paired-end mode with a quality cutoff of Phred score 20 (-q 20), trimming bases with lower scores at the read ends. 
    - Reads shorter than 70 bp (--length 70) will be discarded to retain only informative fragments. 
    - FastQC can be performed again to check the successful removal of adapter and low-quality bases.

  * **Read alignment:** Trimmed reads will be then mapped to a reference genome (GRCh38.p13) using **Bowtie2 2 2.4.5** 
    - --very-sensitive preset to maximize alignment sensitivity. 
    - maximum fragment length of 2000 bp for valid paired-end alignments (-X 2000) will be specified.
    - Aligned SAM files will be converted to BAM format, sorted, and indexed using **Samtools 1.17** to facilitate downstream processing. 

#### (2) Post-alignment processing and QC:
  * **Mark duplicates:** PCR and optical duplicates will be identified and marked using **Picard 2.26.10 MarkDuplicates**, reducing biases introduced by over-amplification.

  * **Filtering:** Filtered BAM files will then be generated using **Samtools 1.17** to retain only high-quality, properly paired reads. 
    - Mitochondrial reads will be excluded.
    - Secondary alignments (SAM flag 0x100 / 1024) will be removed.
    - Reads with mapping quality < 10 will be discarded to eliminate non-unique alignments.
    - Reads flagged as unmapped, mate unmapped, not primary alignment, failing platform/vendor quality checks, or duplicates will be removed.
    - Only properly paired reads (SAM flag 0x2) will be retained.
    - This series of filtering steps will ensure a high-confidence set of nuclear, uniquely aligned, properly paired reads for downstream analyses.

  * **Alignment-level QC:** Quality and fragment patterns will be assessed using R package, **ATACseqQC 1.28.0**.
    - ATAC-seq generates a fragment size distribution with periodic peaks for nucleosome-free regions (<100 bp) and mono-, di-, and tri-nucleosomes (~200, 400, 600 bp). 
    - Nucleosome-free fragments are enriched at transcription start sites (TSS), while nucleosome-bound fragments are depleted at TSS with slight flanking enrichment. 
    - Reads are shifted +4 bp (positive strand) and −5 bp (negative strand) to correct for Tn5-induced 9-bp duplication, allowing for base-pair resolution in transcription factor footprinting.

#### (3) Core analysis (peak calling):
  * **Peak calling:** Peaks will be identified from aligned, filtered BAM files using **MACS2 2.2.6** in paired-end mode (-f BAMPE). 
    - Peak calling will be performed with the human genome size (-g hs) and all duplicate reads retained (--keep-dup all). 
    - The --cutoff-analysis option will be used to estimate an appropriate significance threshold.

  * **Peak-level QC:** Peak quality will be assessed using **ChIPQC 1.40.0**, evaluating metrics such as the fraction of reads in peaks and the fraction of reads in blacklist regions.

#### (4) Advanced analysis:
  * **Peak Annotation:** Identified peaks will be annotated using **ChIPseeker 1.40.0**, assigning each peak to the nearest or overlapping genomic feature, including genes, exons, introns, promoters, 5′ UTRs, 3′ UTRs, and other regions. Functional enrichment analyses, such as Gene Ontology (GO), will be performed to generate biologically meaningful insights for downstream interpretation.

  * **Motif Analysis:** ATAC-seq signals will be summarized against known transcription factor (TF) motif databases, **JASPAR2020 0.99.10**. Motifs, typically stored as position weight matrices (PWM), will be scanned across sequences using **TFBSTools 1.42.0** and **motifmatchr 1.26.0** to identify putative TF binding sites (TFBS).

  * **Chromatin Accessibility Deviations:** **chromVAR 1.26.0** will be used to calculate accessibility deviations for each motif across multiple conditions. Z-scores will be computed and adjusted for technical biases, including GC content, average accessibility, and fraction of reads in peaks.

  * **Differential Accessibility Analysis:** Differential ATAC-seq analyses will be performed with **DESeq2 1.44.0**, which models counts using a negative binomial distribution and requires biological replicates to estimate dispersion accurately.

  * **Footprinting and Regulatory Network Reconstruction:** Transcription factor footprints will be identified as regions of relative depletion within open chromatin, where active TFs prevent Tn5 cleavage. These footprints will be used to infer TF activity and reconstruct regulatory networks in specific samples. Motif information from **MotifDb 1.46.0** will support footprinting analyses.

