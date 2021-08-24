plan <- drake_plan(
  # Load all starting files
  CoRR = read.csv("T:/Labs/Spakowicz/ppiio/data/raw/CoRR4684/2021-08-23/CoRR4684ARetrospecti_DATA_2021-08-23_2328.csv", 
                  stringsAsFactors = F),
  P188 = read.csv("T:/Labs/Spakowicz/ppiio/data/raw/P188/2021-08-23/P188NSCLCIOTox111611_DATA_2021-08-23_2326.csv",
                  stringsAsFactors = F),
  TCC.clin = read_excel("T:/Labs/Spakowicz/ppiio/data/raw/TCC000139/TCC000139-SPAK_ClinicalDataPoints_withSLIDS.xlsx"),
  TCC.IW = read_excel("T:/Labs/Spakowicz/ppiio/data/raw/TCC000139/TCC000139-SPAK_MedicationLogFile_withSLIDS.xlsx"),
  meds = read_excel("T:/Labs/Spakowicz/ppiio/data/raw/IW-meds/PLATELET_Variable_update.xlsx", sheet = 2, skip = 1),
  noio = readRDS("T:/Labs/Spakowicz/ppiio/data/curated/NoImmunotherapy.RDS"),
  # This could also be a csv defining the important relationships, of course
  class.key = pull_class_assignments(),
  
  # Focus on CoRR
  cancer.key = generate_cancer_key(),
  ionames = as.data.frame(cbind(immunotherapy = c(1,2,3,4,5,6,7,8,9,10,11), 
                                Immunotherapy = c("Nivolumab", "Pembrolizumab", 
                                                  "Atezolizumab", "Ipilimumab", 
                                                  "Nivolumab + Ipilimumab", 
                                                  "Durvalumab + Tremelimumab", 
                                                  "Tremelimumab", "Nivolumab + Chemotherapy",
                                                  "Durvalumab", "Other", "Unknown"),
                                stringsAsFactors = FALSE),
                          stringsAsFactors = F) %>%
    mutate(immunotherapy = as.numeric(immunotherapy)),
  ionames2 = as.data.frame(cbind(immunotherapy = 1:14, 
                                 Immunotherapy = c("Pembrolizumab monotherapy", "Pembrolizumab, Carboplatin, Pemetrexed", 
                                                   "Pembrolizumab, Carboplatin, Paclitaxel", "Pembrolizumab, Cisplatin, Pemetrexed", 
                                                   "Pembrolizumab, Carboplatin, Abraxane", 
                                                   "Nivo + Ipi", 
                                                   "Atezolizumab", "Nivolumab monotherapy", "Medi4736 + Tremelimumab",
                                                    "Tremelimumab", "Nivo + chemo", "MEDI4736, durvalumab",
                                                   "Ipilimumab", "Other")), 
                           stringsAsFactors = F)%>%
    mutate(immunotherapy = as.numeric(immunotherapy)), 
  
  CoRR.form = quick_format_CoRR(CoRR, noio, cancer.key, ionames),
  start.ordering.offset = check_date_difference(meds),
  CoRR.timing = pull_timing_info(class.key, meds, start.ordering.offset["Median"], CoRR.form),
  
  # Focus on P188 - this is the same sort of data as CoRR, just an updated database. Format should be the same.
  P188.form = quick_format_CoRR(P188, noio, cancer.key, ionames2),
  P188.timing = pull_timing_info(class.key, meds, start.ordering.offset["Median"], P188.form),
  
  # Focus on TCC000139
  TCC.full = ORIEN_timing_info(TCC.clin, TCC.IW, class.key),
  
  # Combine CoRR and P188, removing duplicate patients
  DO.combined = combine_DO_dbs(CoRR.timing, P188.timing)
)
