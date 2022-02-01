generate_CS_key <- function(){
  sterfun <- read.table("T:/Labs/Spakowicz/data/exoio/steroid-dbid-key.TSV")
  
  ster.class <- as.data.frame(cbind(medname = unique(sterfun$Drug.name),
                                    medclass = "CS")) %>%
    separate(medname, into = "medname", sep = " ")
  
  ster.class <- ster.class[!duplicated(ster.class),]
  
  return(ster.class)
}