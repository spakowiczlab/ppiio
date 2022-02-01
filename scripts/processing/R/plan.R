plan <- drake_plan(
  # Load all starting files
  CoRR = read.csv("T:/Labs/Spakowicz/ppiio/data/raw/CoRR4684/2022-01-27/CoRR4684ARetrospecti_DATA_2022-01-27_0958.csv", 
                  stringsAsFactors = F),
  P188 = read.csv("T:/Labs/Spakowicz/ppiio/data/raw/P188/2022-01-27/P188NSCLCIOTox111611_DATA_2022-01-27_0959.csv",
                  stringsAsFactors = F),
  TCC.clin = read_excel("T:/Labs/Spakowicz/ppiio/data/raw/TCC000139/TCC000139-SPAK_ClinicalDataPoints_withSLIDS.xlsx"),
  TCC.IW = read_excel("T:/Labs/Spakowicz/ppiio/data/raw/TCC000139/TCC000139-SPAK_MedicationLogFile_withSLIDS.xlsx"),
  meds = read_excel("T:/Labs/Spakowicz/ppiio/data/raw/IW-meds/PLATELET_Variable_update.xlsx", sheet = 2, skip = 1),
  meds.new = read_excel("T:/Labs/Spakowicz/ppiio/data/raw/IW-meds/hboc1212/TASK1202137_HBOC1212_Main data report_20211007.xlsx", sheet = 4)%>%
    mutate(MRN = PAT_MRN_ID,
           GENERIC_NAME = MEDICATION_NAME,
           REFILLS = NA),
  noio = readRDS("T:/Labs/Spakowicz/ppiio/data/curated/NoImmunotherapy.RDS"),
  # This could also be a csv defining the important relationships, of course
  class.key = pull_class_assignments(),
  abx.key = generate_abx_key(),
  CS.key = generate_CS_key(),
  revised.treatments = format_revised_treatments(),

  # Focus on CoRR
  cancer.key = generate_cancer_key(),
  ionames = as.data.frame(cbind(immunotherapy = c(1,2,3,4,5,6,7,8,9,10,11), 
                                Immunotherapy = c("Nivolumab", "Pembrolizumab", 
                                                  "Atezolizumab", "Ipilimumab", 
                                                  "Nivolumab + Ipilimumab", 
                                                  "Durvalumab + Tremelimumab", 
                                                  "Tremelimumab", "Nivolumab + Chemotherapy",
                                                  "Durvalumab", "Other", "Unknown"),
                                immunotherapy.group = c("PD-1", "PD-1", "CTLA-4", "PD-L1", "PD1+CTLA4", "PD1+CTLA4",
                                                        "CTLA-4", "PD1+chemo", "PD-L1", "Other", "Unknown"),
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
                                                   "Ipilimumab", "Other"),
                                 immunotherapy.group = c("PD-1", "PD1+chemo", "PD1+chemo", "PD1-chemo",  "PD1+chemo", "PD1+CTLA4", "CTLA-4",
                                                         "PD-1", "PD1+CTLA4", "CTLA-4", "PD1+chemo", "PD-L1", "CTLA-4", "Other")), 
                           stringsAsFactors = F)%>%
    mutate(immunotherapy = as.numeric(immunotherapy)), 
  
  CoRR.form = quick_format_CoRR(CoRR, noio, cancer.key, ionames),
  start.ordering.offset = check_date_difference(meds),
  CoRR.timing = pull_timing_info(bind_rows(class.key,abx.key), meds, 
                                 start.ordering.offset["Median"], CoRR.form, F),
  # CoRR.addCS = pull_timing_info(CS.key, meds, start.ordering.offset["Median"], CoRR.timing),
  CoRR.addICIgroup = fix_ICI_other(CoRR.timing, revised.treatments),
  
  # Focus on P188 - this is the same sort of data as CoRR, just an updated database. Format should be the same.
  P188.form = quick_format_CoRR(P188, noio, cancer.key, ionames2),
  order.offset.2 = check_date_difference(meds.new),
  P188.timing = pull_timing_info(bind_rows(class.key,abx.key), meds.new,
                                 order.offset.2["Median"], P188.form, T),
  # P188.addCS = pull_timing_info(CS.key, meds.new, start.ordering.offset["Median"], P188.timing),
  P188.addICIgroup = fix_ICI_other(P188.timing, revised.treatments),
  
  # Focus on TCC000139
  TCC.full = ORIEN_timing_info(TCC.clin, TCC.IW, class.key),
  
  # Combine CoRR and P188, removing duplicate patients
  DO.combined = combine_DO_dbs(CoRR.addICIgroup, P188.addICIgroup)
)
