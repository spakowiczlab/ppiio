pull_class_assignments <- function(){
  h2b <- read.table(file_in("T:/Labs/Spakowicz/ppiio/data/curated/h2b.txt"), stringsAsFactors = F, sep = "\t") %>%
    rename("medname" = "V1") %>%
    mutate(medclass = "H2B")
  ppi <- read.table(file_in("T:/Labs/Spakowicz/ppiio/data/curated/proton-pump-inhibitors.txt"), stringsAsFactors = F, sep = "\t") %>%
    rename("medname" = "V1") %>%
    mutate(medclass = "PPI")
  
  complete.class <- bind_rows(h2b, ppi)
  return(complete.class)
}
