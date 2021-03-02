pull_timing_info <- function(des.meds, meds.list, cdb){
 #Goal: Get df of timing columns for each of the desired meds, classes. This is a different version than appears in abx_class-improve because
  # I'd like to think my coding has improved some. Assumes similar format to the meds list in db-meds.RData.
  # test <- c("piperacillin", "amoxicillin", "vancomycin")
  
  # Get list of meds in full list that belong in each of the pre-defined classes
  meds.members <- lapply(des.meds$medname, function(x) as.data.frame(cbind(GENERIC_NAME = unique(meds.list$GENERIC_NAME[grepl(x, meds.list$GENERIC_NAME, ignore.case = T)]),
                                                               medname = x))) %>%
    bind_rows() %>%
    mutate(GENERIC_NAME = as.character(GENERIC_NAME),
           medname = as.character(medname))
  
  des.meds.full <- meds.members %>%
    left_join(des.meds)
  
  # Generate object that has all necessary info for timing columns and calculate for each entry.
  iostarts <- cdb %>%
    select(MRN, iostart)
  
  time.obj.start <- des.meds.full %>%
    left_join(meds.list) %>%
    mutate(MRN = as.character(MRN), 
           START_DATE = as.Date(START_DATE)) %>%
    select(MRN, GENERIC_NAME, START_DATE, REFILLS, medname, medclass) %>%
    inner_join(iostarts) %>%
    filter(!is.na(START_DATE)) %>%
    mutate(REFILLS = ifelse(is.na(REFILLS), 0, REFILLS),
           # quant.num = as.numeric(str_extract("^\\d+", QUANTITY)),
           med.dur = (REFILLS+1) * 30,
           days.to.io = START_DATE - iostart,
           stop.date = days.to.io + med.dur - 1,
           )
  
  relative.days.covered <- lapply(1:nrow(time.obj.start), function(i) paste(time.obj.start$days.to.io[i]:time.obj.start$stop.date[i], collapse = ","))
  
  time.obj.start$relative.days.covered <- unlist(relative.days.covered)
  # Collapse timing info by med, class
  
  # Hold off on the by-med version for now - probably only need if we want to break down ppi and h2b further, like with ABX classes
  # time.med <- time.obj.start %>%
  #   group_by(MRN, medname) %>%
  #   summarise(alldays = paste(relative.days.covered, collapse = ","))
  # time.med.unq <- lapply(1:nrow(time.med), function(x) paste(unique(unlist(strsplit(time.med$alldays[x], split = ","))), collapse = ","))
  # time.med$alldays <- unlist(time.med.unq)
  # time.med <- time.med %>%
  #   mutate(medname = paste0(medname, ".days.to.iostart")) %>%
  #   spread(key = medname, value = alldays)
  
  time.class <- time.obj.start %>%
    group_by(MRN, medclass) %>%
    summarise(alldays = paste(relative.days.covered, collapse = ","))
  time.class.unq <- lapply(1:nrow(time.class), function(x) paste(unique(unlist(strsplit(time.class$alldays[x], split = ","))), collapse = ","))
  time.class$alldays <- unlist(time.class.unq)
  time.class <- time.class %>%
    mutate(medclass = paste0(medclass, ".days.to.iostart")) %>%
    spread(key = medclass, value = alldays)
  
  corr.addtime <- cdb %>%
    # left_join(time.med) %>% 
    left_join(time.class)
  
  return(corr.addtime)

}
