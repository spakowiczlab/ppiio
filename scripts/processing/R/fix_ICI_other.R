fix_ICI_other <- function(db, rtreat){
  db.good <- db %>%
    filter(!MRN %in% rtreat$MRN)
  db.bad <- db %>%
    filter(MRN %in% rtreat$MRN) %>%
    select(-Immunotherapy, -immunotherapy.group) %>%
    left_join(rtreat) %>%
    filter(!grepl("monoclonalAb", immunotherapy.group))
  
  db.fixed <- bind_rows(db.good, db.bad)
  return(db.fixed)
}
