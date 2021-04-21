ORIEN_timing_info <- function(clin, IW, des.meds){
  # Get list of meds in full list that belong in each of the pre-defined classes
  meds.members <- lapply(des.meds$medname, function(x) as.data.frame(cbind(Clarity_Med_Name = unique(IW$Clarity_Med_Name[grepl(x, IW$Clarity_Med_Name, ignore.case = T)]),
                                                                           medname = x))) %>%
    bind_rows() %>%
    mutate(Clarity_Med_Name = as.character(Clarity_Med_Name),
           medname = as.character(medname))
  
  des.meds.full <- meds.members %>%
    left_join(des.meds) %>%
    filter(!is.na(Clarity_Med_Name))
  
  # Reduce to desired meds, get timing
  time.obj.start <- des.meds.full %>%
    left_join(IW) %>%
    mutate(Days_Btwn_Collect_and_Med_Stop = ifelse(is.na(Days_Btwn_Collect_and_Med_Stop), 
                                                   Days_Btwn_Collect_and_Med_Start + 29,
                                                   Days_Btwn_Collect_and_Med_Stop))
  
  relative.days.covered <- lapply(1:nrow(time.obj.start), function(i) paste(time.obj.start$Days_Btwn_Collect_and_Med_Start[i]:time.obj.start$Days_Btwn_Collect_and_Med_Stop[i], collapse = ","))
  
  time.obj.start$relative.days.covered <- unlist(relative.days.covered)
  
  time.class <- time.obj.start %>%
    group_by(`RNA-SLID`, medclass) %>%
    summarise(alldays = paste(relative.days.covered, collapse = ","))
  time.class.unq <- lapply(1:nrow(time.class), function(x) paste(unique(unlist(strsplit(time.class$alldays[x], split = ","))), collapse = ","))
  time.class$alldays <- unlist(time.class.unq)
  time.class <- time.class %>%
    mutate(medclass = paste0(medclass, ".days.to.collection")) %>%
    spread(key = medclass, value = alldays)
  
  combined.obj <- clin %>%
    # left_join(time.med) %>% 
    left_join(time.class)
  
  binarize.collection <- lapply(unique(des.meds$medclass), function(x) check_timing_window(combined.obj[[paste0(x, ".days.to.collection")]], c(0,0)))
  names(binarize.collection) <- paste0(unique(des.meds$medclass), "_collection")
  
  combined.with.bin <- bind_cols(combined.obj, bind_cols(binarize.collection))
  return(combined.with.bin)
}
