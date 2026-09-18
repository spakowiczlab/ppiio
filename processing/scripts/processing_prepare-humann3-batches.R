# Cohort 3 (Iobio) shotgun metagenome processing
# ---------------------------------------------------------------------------
# Run on OSC (project PAS1695). Figure 4 uses the MetaPhlAn aggregate only;
# HUMAnN3 pathway abundances are written here for completeness but are not
# used in the published notebooks.
#
# Inputs (cluster):
#   /fs/ess/PAS1695/archive/projects/iobio/*.fastq.gz
#     Paired Illumina NovaSeq 6000 reads (R1/R2) for 14 libraries:
#     8 baseline stools, 4 follow-ups, 2 negative controls (NCE, NCL).
#     Sequencer filenames still contain collection dates. Recode to study IDs
#     with the key file (not in git):
#       /fs/ess/PAS1695/projects/iobio/sample-id-key.csv
#       or file.path(Tdrive, "iobio-sample-key.csv")
#     Columns: sequencer, sample (e.g. P026_d0).
#
# Tools:
#   HUMAnN 3 (conda env humann3.2023.12), 28 threads per library
#   MetaPhlAn is run inside HUMAnN (`*_metaphlan_bugs_list.tsv`)
#   Nucleotide DB: /fs/ess/PAS1695/db/chocophlan/chocophlan
#   Protein DB:    /fs/ess/PAS1695/db/chocophlan/uniref
#
# Outputs in this repo (study IDs, e.g. P026_d0):
#   ../data/2023-12-07_mpa-aggregate.csv
#   ../data/2023-12-07_humann3-aggregate.csv
# The MetaPhlAn table is copied to manuscript/data/Cohort_3/ for Figure 4.
# Figure 4 keeps the 8 baseline samples; follow-ups and controls are unused.
# ---------------------------------------------------------------------------

library(tidyverse)

# sequencer -> study ID. File is on OSC / the lab share, not in this repo.
key_candidates <- c(
  "/fs/ess/PAS1695/projects/iobio/sample-id-key.csv",
  if (exists("Iobio_sample_map")) Iobio_sample_map,
  if (exists("Tdrive")) file.path(Tdrive, "iobio-sample-key.csv")
)
key_file <- key_candidates[file.exists(key_candidates)][1]
if (is.na(key_file)) {
  stop(
    "Missing iobio-sample-key.csv (columns sequencer,sample). ",
    "Keep it on the lab share or OSC; do not commit it."
  )
}
sample_map <- read.csv(key_file, stringsAsFactors = FALSE)

# --- Concatenate R1/R2 per library ------------------------------------------

fq.files <- list.files("/fs/ess/PAS1695/archive/projects/iobio",
                       full.names = TRUE, pattern = "fastq")

fq.df <- data.frame(fq.files, stringsAsFactors = FALSE) %>%
  mutate(sampnames = gsub(".*(DS.*)_R\\d_.*", "\\1", fq.files))

scoms <- paste0(
  "zcat /fs/ess/PAS1695/archive/projects/iobio/",
  fq.df$sampnames, "_R1_001.fastq.gz  /fs/ess/PAS1695/archive/projects/iobio/",
  fq.df$sampnames, "_R2_001.fastq.gz | gzip -c > /fs/scratch/PAS1695/projects/iobio/concat-fqs/",
  fq.df$sampnames, ".fastq.gz"
)
scoms <- unique(scoms)

lapply(scoms, function(x) system(command = x))

samples <- unique(fq.df$sampnames)

# --- One PBS job per library (HUMAnN 3) -------------------------------------

for (s in samples) {
  fileOut <- paste0("/fs/scratch/PAS1695/projects/iobio/batch/humann3_", s, ".pbs")

  writeLines(
    c(
      paste0("#PBS -N humann3_", s),
      "#PBS -A PAS1695",
      "#PBS -l walltime=10:00:00",
      "#PBS -l nodes=1:ppn=28",
      "#PBS -j oe",
      "",
      "cd /fs/scratch/PAS1695/projects/iobio/concat-fqs",
      "module load python/3.7-2019.10",
      "source activate humann3.2023.12",
      paste0(
        "humann -i ", s, ".fastq.gz", " -o ", "../humann3/", s,
        " --threads 28 --input-format fastq.gz",
        " --nucleotide-database /fs/ess/PAS1695/db/chocophlan/chocophlan",
        " --protein-database /fs/ess/PAS1695/db/chocophlan/uniref"
      ),
      ""
    ),
    fileOut
  )
}

# --- Aggregate MetaPhlAn and HUMAnN3 tables ---------------------------------

mettab.ls <- lapply(samples, function(x) {
  read.table(
    paste0("/fs/scratch/PAS1695/projects/iobio/humann3/",
           x, "/", x, "_humann_temp/", x, "_metaphlan_bugs_list.tsv"),
    header = FALSE, sep = "\t", stringsAsFactors = FALSE
  ) %>%
    mutate(V2 = as.character(V2))
})
names(mettab.ls) <- samples
metab.df <- bind_rows(lapply(samples, function(x) {
  mettab.ls[[x]] %>% mutate(sequencer = x)
}))

metab.df.form <- metab.df %>%
  rename(
    "Taxonomy" = "V1",
    "TaxNum" = "V2",
    "RelAbun" = "V3",
    "Alternative.Tax" = "V4"
  ) %>%
  left_join(sample_map, by = "sequencer") %>%
  select(Taxonomy, TaxNum, RelAbun, Alternative.Tax, sample)

write.csv(metab.df.form, "/fs/ess/PAS1695/projects/iobio/2023-12-07_mpa-aggregate.csv",
          row.names = FALSE)
write.csv(metab.df.form, "../data/2023-12-07_mpa-aggregate.csv", row.names = FALSE)

humann.ls <- lapply(samples, function(x) {
  read.table(
    paste0("/fs/scratch/PAS1695/projects/iobio/humann3/",
           x, "/", x, "_pathabundance.tsv"),
    header = FALSE, sep = "\t", stringsAsFactors = FALSE
  ) %>%
    mutate(sequencer = x)
})

humann3.df <- humann.ls %>%
  bind_rows() %>%
  rename("Pathway" = "V1", "PathAbun" = "V2") %>%
  left_join(sample_map, by = "sequencer") %>%
  select(Pathway, PathAbun, sample)

write.csv(humann3.df, "/fs/ess/PAS1695/projects/iobio/2023-12-07_humann3-aggregate.csv",
          row.names = FALSE)
write.csv(humann3.df, "../data/2023-12-07_humann3-aggregate.csv", row.names = FALSE)
