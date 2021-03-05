plan <- drake_plan(
  # Load all starting files
  CoRR = read.csv("T:/Labs/Spakowicz/projects/ppiio/data/raw/CoRR4684/2021-01-27/CoRR4684ARetrospecti_DATA_2021-01-27_1430.csv", 
                   stringsAsFactors = F),
  P188 = read.csv("T:/Labs/Spakowicz/projects/ppiio/data/raw/P188/2021-01-27/P188NSCLCIOTox111611_DATA_2021-01-27_1441.csv",
                   stringsAsFactors = F),
  TCC.clin = read_excel("T:/Labs/Spakowicz/projects/ppiio/data/raw/TCC000139/TCC000139-SPAK_ClinicalDataPoints_withSLIDS.xlsx"),
  TCC.IW = read_excel("T:/Labs/Spakowicz/projects/ppiio/data/raw/TCC000139/TCC000139-SPAK_MedicationLogFile_withSLIDS.xlsx"),
  meds = read_excel("T:/Labs/Spakowicz/projects/ppiio/data/raw/IW-meds/PLATELET_Variable_update.xlsx", sheet = 2, skip = 1),
  noio = readRDS("T:/Labs/Spakowicz/projects/ppiio/data/curated/NoImmunotherapy.RDS"),
  # This could also be a csv defining the important relationships, of course
  class.key = as.data.frame(cbind(medname = c("PANTOPRAZOLE", "OMEPRAZOLE", "LANSOPRAZOLE", "DEXLANSOPRAZOLE", "RABEPRAZOLE", "ESOMEPRAZOLE", "prilosec", 
                                              "yosprala", "prevacid", "dexilent", "aciphex", "protonix", "nexium", "vimovo", "zegerid" ),
                                  medclass = c(rep("PPI", 15)))) %>%
    mutate(medname = as.character(medname),
           medclass = as.character(medclass)),
  
  # Focus on CoRR
  cancer.key = generate_cancer_key(),
  ionames = as.data.frame(cbind(immunotherapy = c(1,2,3,4,5,6,7,8,9,10), 
                                Immunotherapy = c("Nivolumab", "Pembrolizumab", 
                                                  "Atezolizumab", "Ipilimumab", 
                                                  "Nivolumab + Ipilimumab", 
                                                  "Durvalumab + Tremelimumab", 
                                                  "Tremelimumab", "Nivolumab + Chemotherapy",
                                                  "Durvalumab", "Other"),
                                stringsAsFactors = FALSE),
                          stringsAsFactors = F) %>%
    mutate(immunotherapy = as.numeric(immunotherapy)),
  
  CoRR.form = quick_format_CoRR(CoRR, noio, cancer.key, ionames),
  start.ordering.offset = check_date_difference(meds),
  CoRR.timing = pull_timing_info(class.key, meds, start.ordering.offset["Median"], CoRR.form),
  
  # Focus on P188 - this is the same sort of data as CoRR, just an updated database. Format should be the same.
  P188.form = quick_format_CoRR(P188, noio, cancer.key, ionames),
  P188.timing = pull_timing_info(class.key, meds, start.ordering.offset["Median"], P188.form)
)
