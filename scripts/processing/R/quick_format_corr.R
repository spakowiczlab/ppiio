quick_format_CoRR <- function(corrdb, nio, cankey, IO.names){
  corrdb %>%
    rename("MRN"="record_id") %>%
    filter(vitalstatus != 3) %>%
    mutate(vitalstatus = ifelse(vitalstatus == 1, 1, 0))%>%
    mutate(deathdate = ifelse(deathdate == "", NA, deathdate),
           lastcontact = ifelse(lastcontact == "", NA, lastcontact)) %>%
    mutate(date = coalesce(deathdate, lastcontact),
           date = as.Date(date),
           iostart = as.Date(iostart),
           dob = as.Date(dob),
           MRN = as.character(MRN))%>%
    mutate(age=as.numeric(as.character(floor((date-dob)/365))))%>%
    filter(!is.na(iostart))%>%
    mutate(follow_up = as.numeric(as.character(date- iostart)))%>%
    left_join(cankey) %>%
    left_join(IO.names) %>%
    filter(immunotherapy != 11) %>%
    drop_na(iostart, ppi, date, dob) %>%
    filter(!MRN %in% nio)
}
