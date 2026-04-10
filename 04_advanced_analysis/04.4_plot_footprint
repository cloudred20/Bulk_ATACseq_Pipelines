# Generate all possible 2-letter tags (AA, AB... ZZ) to scan for custom BAM tags
possibleTag <- combn(LETTERS, 2)
possibleTag <- c(paste0(possibleTag[1, ], possibleTag[2, ]),
                 paste0(possibleTag[2, ], possibleTag[1, ]))

# Setup output directory for shifted BAM files
outPath <- "split_bam"
if (dir.exists(outPath)) unlink(outPath, recursive = TRUE, force = TRUE)
dir.create(outPath)

# Loop through each BAM file to perform coordinate shifting
for(i in seq_along(bamfile)){
  bamFile <- bamfile[i]
  label <- bamfile.label[i]
  
# Load libraries
library(BSgenome.Hsapiens.UCSC.hg38)
library(MotifDb)

# Scan the first 100 reads to identify which tags are actually present in the file
  bamTop100 <- scanBam(BamFile(bamFile, yieldSize = 100), 
                       param = ScanBamParam(tag = possibleTag))[[1]]$tag
  tags <- names(bamTop100)[lengths(bamTop100) > 0]
  
  # Read the BAM file as paired-end mates (asMates = TRUE)
  gal_raw <- readBamFile(bamFile, tag = tags, asMates = TRUE, bigFile = TRUE)
  
  # Apply the ATAC-seq specific shift: +4bp for forward and -5bp for reverse strands
  # This centers the signal precisely on the Tn5 insertion site.
  shiftedBamFile <- file.path(outPath, paste0(label, "_shifted.bam"))
  gal_shifted <- shiftGAlignmentsList(gal_raw, outbam=shiftedBamFile)
}

# Query MotifDb for the Position Frequency Matrix (PFM) of the target TF
# Example uses STAT6 from the JASPAR 2022 database
target_motif <- "STAT6" 
tf_query <- query(MotifDb, c(target_motif, "jaspar2022"))
tf_pfm <- as.list(tf_query)

# Select specific shifted BAMs and their indexes for comparison (e.g., Treated vs Control)
selected_bams <- list.files(path = "split_bam", pattern = "_shifted.bam$", full.names = TRUE)[c(1,2)]
selected_indices <- list.files(path = "split_bam", pattern = "_shifted.bam.bai$", full.names = TRUE)[c(1,2)]

# Generate the footprint profile
# factorFootprints calculates the Tn5 insertion density around the motif sites
# min.score = "90%" ensures only high-confidence binding sites are analyzed
footprint_res <- factorFootprints(
    bamfiles = selected_bams, 
    index = selected_indices,
    pfm = tf_pfm[[1]], 
    genome = BSgenome.Hsapiens.UCSC.hg38,
    min.score = "90%", 
    seqlev = paste0("chr", c(1:22, "X", "Y")),
    group = c("Group1", "Group2"), # Generic group labels
    upstream = 100, 
    downstream = 100
)
