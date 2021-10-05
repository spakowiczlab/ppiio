format_revised_treatments <- function(){
  from.MH <- read.csv("T:/Labs/Spakowicz/ppiio/data/curated/MH_treatments.csv", stringsAsFactors = F, header = F)
  from.MH.cols <- from.MH %>%
    mutate(MRN = gsub("(^\\d+) .*", "\\1", V1),
           Immunotherapy = gsub(".*;(.*)", "\\1", V1))

  from.MH.cols$Immunotherapy[5] <- "given an anti-CTLA4 Ab but a new one: AGEN1884 CTLA4; kept as other"
  from.MH.cols$Immunotherapy[11] <- "Pembro + chemo (FOLFOX) - no option to change in this database's dropdown menu; it only has nivo + chemo"
  from.MH.cols$Immunotherapy.group <- c("PD1+targeted", "PD1+monoclonalAb", "CTLA4+targeted", "PD1+monoclonalAb", "CTLA4",
                                        "PD1+targeted", "PD1+monoclonalAb", "CTLA4+targeted", "PD1+targeted", "PD1+targeted",
                                        "PD1+chemo", "PD1+targeted", "PD1+chemo", "PD1+chemo", "PD1+targeted",
                                        "PD1+CTLA4+chemo", "PD1+chemo", "PD1+targeted", "PD1+chemo", "PD1+chemo",
                                        "PD1+targeted", "PD1+targeted", "PD1+targeted", "PD1+chemo", "PD1+targeted")
  
  revised.ids <- from.MH.cols %>%
    arrange(MRN)
  return(revised.ids)

}
