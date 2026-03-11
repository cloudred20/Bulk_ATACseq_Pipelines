######## QC for alignments ----

library(ATACseqQC)
library(Rsamtools)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(BSgenome.Hsapiens.UCSC.hg38)
library(ggplot2)

## Define BAM directory
bam_dir <- "bowtie2_results/merged_bam"

## Identify BAM files and indexes
bamfile <- list.files(path = bam_dir,
                      pattern = "merged.bam$",
                      full.names = TRUE)

bamfile.index <- paste0(bamfile, ".bai")

## Extract sample labels automatically
bamfile.label <- gsub("_merged.bam", "", basename(bamfile))


#################################################
## 1. Estimate library complexity
#################################################

lib_comp <- vector("list", length(bamfile))

for (i in seq_along(bamfile)) {

  dup_freq <- readsDupFreq(bamFile = bamfile[i],
                           index = bamfile.index[i])

  lib_comp[[i]] <- estimateLibComplexity(dup_freq)

}

names(lib_comp) <- bamfile.label


#################################################
## 2. Fragment size distribution
#################################################

frag_size <- vector("list", length(bamfile))

for (i in seq_along(bamfile)) {

  frag_size[[i]] <- fragSizeDist(
    bamFiles = bamfile[i],
    bamFiles.labels = bamfile.label[i],
    index = bamfile.index[i]
  )

}

names(frag_size) <- bamfile.label


#################################################
## 3. Mapping Quality Control
#################################################

bamfileQC <- vector("list", length(bamfile))

for (i in seq_along(bamfile)) {

  bamfileQC[[i]] <- bamQC(
    bamfile = bamfile[i],
    index = bamfile.index[i],
    mitochondria = "chrM",
    outPath = NULL,
    doubleCheckDup = TRUE
  )

}

names(bamfileQC) <- bamfile.label


## PCR bottleneck coefficients
lapply(bamfileQC, function(x) x$PCRbottleneckCoefficient_1)
lapply(bamfileQC, function(x) x$PCRbottleneckCoefficient_2)


## MAPQ distribution plots
lapply(bamfileQC, function(x) {

  ggplot(x$MAPQ, aes(x = Var1, y = Freq, fill = Freq)) +
    geom_bar(stat = "identity") +
    labs(x = "MAPQ score", y = "Read count") +
    theme_minimal()

})


#################################################
## 4. Shift reads (Tn5 correction)
#################################################

possibleTag <- combn(LETTERS, 2)
possibleTag <- c(paste0(possibleTag[1, ], possibleTag[2, ]),
                 paste0(possibleTag[2, ], possibleTag[1, ]))

outPath <- "split_bam"

if (dir.exists(outPath)) unlink(outPath, recursive = TRUE, force = TRUE)
dir.create(outPath)

for (i in seq_along(bamfile)) {

  bamFile <- bamfile[i]
  label <- bamfile.label[i]

  bamTop100 <- scanBam(
    BamFile(bamFile, yieldSize = 100),
    param = ScanBamParam(tag = possibleTag)
  )[[1]]$tag

  tags <- names(bamTop100)[lengths(bamTop100) > 0]

  gal_raw <- readBamFile(
    bamFile,
    tag = tags,
    asMates = TRUE,
    bigFile = TRUE
  )

  shiftedBamFile <- file.path(outPath, paste0(label, "_shifted.bam"))

  gal_shifted <- shiftGAlignmentsList(
    gal_raw,
    outbam = shiftedBamFile
  )

}