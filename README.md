#### ATAC-seq Workflow:

ATAC-seq is used to interrogate chromatin accessibility, providing insights into enhancer landscapes, chromatin states, and differences in accessibility between normal and diseased samples. The method employs a genetically engineered hyperactive Tn5 transposase, which simultaneously cleaves accessible chromatin by creating a 9-bp staggered nick and ligates high-throughput sequencing adapters at these sites.

Four major steps in ATAC-seq analysis include:
* (1) Pre-analysis quality control (QC) and alignment: The pre-alignment QC and read alignment steps are standard for most high-throughput sequencing technologies.
  * **FastQC 0.12.1** will be used to assess sequencing quality, including per-base sequence quality, per-base GC content, adapter contamination, and sequence duplication levels. Overall, high base quality scores with a modest decline toward the 3′ end of the reads are considered acceptable. Bias introduced by Tn5 transposase (as used in the Nextera protocol) may be observed, since the enzyme cleaves accessible chromatin and inserts sequencing adapters. Sharp peaks in an otherwise smooth distribution often indicate specific contaminants such as adapter dimers. Additionally, PCR duplication may occur, where certain fragments are overrepresented due to biased PCR amplification during library preparation. No major deviations from the expected GC content or read length distribution should be present, and quality metrics should remain consistent across all samples within the same experimental batch and sequencing run. 
  
  * Paired-end reads will be trimmed for adapter contamination and low-quality bases using **Trim Galore 0.6.10**. Reads will be processed in paired-end mode with a quality cutoff of Phred score 20 (-q 20), trimming bases with lower scores at the read ends. Reads shorter than 70 bp (--length 70) will be discarded to retain only informative fragments. FastQC can be performed again to check the successful removal of adapter and low-quality bases.

  * Trimmed reads will be then mapped to a reference genome (GRCh38.p13) using **Bowtie2 2 2.4.5** with the --very-sensitive preset to maximize alignment sensitivity. A maximum fragment length of 2000 bp for valid paired-end alignments (-X 2000) will be specified.

* (2) Post-alignment processing and QC: 
  * Aligned SAM files will be converted to BAM format, sorted, and indexed using **Samtools 1.17** to facilitate downstream processing. PCR and optical duplicates will be identified and marked using **Picard 2.26.10 MarkDuplicates**, reducing biases introduced by over-amplification.

  * Filtered BAM files will then be generated using **Samtools 1.17** to retain only high-quality, properly paired reads. Specifically, the following filters will be applied:

    * Mitochondrial reads will be excluded.
    * Secondary alignments (SAM flag 0x100 / 1024) will be removed.
    * Reads with mapping quality < 10 will be discarded to eliminate non-unique alignments.
    * Reads flagged as unmapped, mate unmapped, not primary alignment, failing platform/vendor quality checks, or duplicates will be removed.
    * Only properly paired reads (SAM flag 0x2) will be retained.
  * ATAC-seq is expected to produce a fragment size distribution with periodic peaks corresponding to nucleosome-free regions (<100 bp) and mono-, di-, and tri-nucleosomes (~200, 400, 600 bp). NFR fragments will be enriched at transcription start sites (TSS), while nucleosome-bound fragments will be depleted at TSS with slight flanking enrichment. Reads will be shifted +4 bp (positive strand) and −5 bp (negative strand) to correct for Tn5-induced 9-bp duplication, enabling base-pair resolution for transcription factor footprinting. Quality and fragment patterns will be assessed using R package, **ATACseqQC 1.28.0**.
  * This series of filtering steps will ensure a high-confidence set of nuclear, uniquely aligned, properly paired reads for downstream analyses.
* (3) Core analysis (peak calling)
  * Peaks will be identified from aligned, filtered BAM files using **MACS2 2.2.6** in paired-end mode (-f BAMPE). Peak calling will be performed with the human genome size (-g hs) and all duplicate reads retained (--keep-dup all). The --cutoff-analysis option will be used to estimate an appropriate significance threshold.
  * Peak quality will be assessed using **ChIPQC 1.40.0**, evaluating metrics such as the fraction of reads in peaks and the fraction of reads in blacklist regions.
* (4) Advanced analysis 
  * Peak Annotation: Identified peaks will be annotated using **ChIPseeker 1.40.0**, assigning each peak to the nearest or overlapping genomic feature, including genes, exons, introns, promoters, 5′ UTRs, 3′ UTRs, and other regions. Functional enrichment analyses, such as Gene Ontology (GO), will be performed to generate biologically meaningful insights for downstream interpretation.

  * Motif Analysis: ATAC-seq signals will be summarized against known transcription factor (TF) motif databases, **JASPAR2020 0.99.10**. Motifs, typically stored as position weight matrices (PWM), will be scanned across sequences using **TFBSTools 1.42.0** and **motifmatchr 1.26.0** to identify putative TF binding sites (TFBS).

  * Chromatin Accessibility Deviations: **chromVAR 1.26.0** will be used to calculate accessibility deviations for each motif across multiple conditions. Z-scores will be computed and adjusted for technical biases, including GC content, average accessibility, and fraction of reads in peaks.

  * Differential Accessibility Analysis: Differential ATAC-seq analyses will be performed with **DESeq2 1.44.0**, which models counts using a negative binomial distribution and requires biological replicates to estimate dispersion accurately.
  * Footprinting and Regulatory Network Reconstruction: Transcription factor footprints will be identified as regions of relative depletion within open chromatin, where active TFs prevent Tn5 cleavage. These footprints will be used to infer TF activity and reconstruct regulatory networks in specific samples. Motif information from **MotifDb 1.46.0** will support footprinting analyses.
