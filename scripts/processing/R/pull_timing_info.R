pull_timing_info <- function(des.meds, meds.list, cdb){
 #Goal: Get df of timing columns for each of the desired meds, classes. This is a different version than appears in abx_class-improve because
  # I'd like to think my coding has improved some. Assumes similar format to the meds list in db-meds.RData.
  # test <- c("piperacillin", "amoxicillin", "vancomycin")
  
  # Get list of meds in full list that belong in each of the pre-defined classes
  meds.members <- lapply(des.meds$medname, function(x) as.data.frame(cbind(GENERIC_NAME = unique(meds$GENERIC_NAME[grepl(x, meds$GENERIC_NAME, ignore.case = T)]),
                                                               medname = x))) %>%
    bind_rows() %>%
    mutate(GENERIC_NAME = as.character(GENERIC_NAME),
           medname = as.character(medname))
  
  des.meds.full <- meds.members %>%
    left_join(des.meds)
  
  # Generate object that has all necessary info for timing columns and calculate for each entry.
  iostarts <- cdb %>%
    select(record_id, iostart)
  
  time.obj.start <- des.meds.full %>%
    left_join(meds.list) %>%
    mutate(record_id == MRN, 
           START_DATE = as.Date(START_DATE)) %>%
    select(record_id, GENERIC_NAME, START_DATE, QUANTITY, REFILLS) %>%
    # right_join(iostarts) %>%
    mutate(REFILLS = ifelse(is.na(REFILLS), 0, REFILLS),
           # quant.num = as.numeric(str_extract("^\\d+", QUANTITY)),
           med.dur = (REFILLS+1) * 30,
           days.to.io = START_DATE - iostart)
  
  # Collapse timing info by med, class
    

}