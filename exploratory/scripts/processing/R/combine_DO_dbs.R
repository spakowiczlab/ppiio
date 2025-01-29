combine_DO_dbs <- function(corr, p118){
  concerning.pats <- intersect(corr$MRN, p118$MRN)
  corr.concer <- corr %>%
    filter(MRN %in% concerning.pats) %>%
    arrange(MRN) %>%
    select(-days, -lastcontact, -deathdate, -vitalstatus, -dob, -iostart, date) %>%
    mutate_all(as.character)
  p118.concer <- p118 %>%
    filter(MRN %in% concerning.pats) %>%
    arrange(MRN) %>%
    mutate_all(as.character)
  
  
  cols.to.check <- intersect(colnames(p118.concer), colnames(corr.concer))
  
  for(i in cols.to.check){
    for(j in 1:nrow(p118.concer)){
    p118.concer[j,i] <- ifelse(is.na(p118.concer[j,i]) | p118.concer[j,i] == "", as.character(corr.concer[j,i]),
                               as.character(p118.concer[j,i]))
    }
  }
  

  corr.in <- corr %>%
    mutate_all(as.character) %>%
    filter(!MRN %in% as.character(concerning.pats))
  p118.in <- p118 %>%
    mutate_all(as.character)%>%
    filter(!MRN %in% as.character(concerning.pats))
  
  cmbined.db <- p118.concer %>%
    # mutate_all(as.character) %>%
    bind_rows(corr.in) %>%
    bind_rows(p118.in)
  
  return(cmbined.db)
}
