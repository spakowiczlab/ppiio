check_timing_window <- function(vect, per){
  wind <- per[1]:per[2]
  wind <- paste(as.character(wind), collapse = ",|,")
  wind <- paste(",", wind, ",", sep = "")
  vect.form <- paste0(",", vect, ",")
  ifelse(grepl(pattern = wind, x = vect.form), 1, 0)
}
