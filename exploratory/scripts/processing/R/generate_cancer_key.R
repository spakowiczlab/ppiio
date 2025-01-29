generate_cancer_key <- function(){
  cancer.copy <- c("1 non-small cell lung cancer
2 small cell lung cancer
3 melanoma
4 renal cell carcinoma
5 head and neck carcinoma
6 merkel cell carcinoma
7 Hodgkin lymphoma
8 breast cancer
9 colon cancer
10 pancreatic cancer
11 Sarcoma
12 Prostate
13 bladder cancer
14 AML
15 ALL
17 Other") %>%
    strsplit(., split = "\n") %>%
    unlist
  
  cancer.key <- 
    data.frame(
      cancer =  cancer.copy %>%
        gsub("(\\d+).*", "\\1", .) %>%
        as.integer(),
      cancer.name = cancer.copy %>%
        gsub("\\d+ (.*)", "\\1", .),
      stringsAsFactors = FALSE
    ) %>%
    mutate(cancer.aggregated = ifelse(cancer.name %in% c("non-small cell lung cancer",
                                                         "melanoma",
                                                         "renal cell carcinoma",
                                                         "head and neck carcinoma"), 
                                      cancer.name,
                                      "Other"))
  return(cancer.key)
}
