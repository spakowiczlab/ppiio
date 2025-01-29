check_date_difference <- function(x){
  tmp <- x %>%
    mutate(start = as.Date(START_DATE),
           ordering = as.Date(ORDERING_DATE)) %>%
    dplyr::select(start, ordering) %>%
    drop_na()
  timedif <- tmp$ordering - tmp$start
  summarize.dif <- summary(as.numeric(timedif))
  return(summarize.dif)
}


