plan <- drake_plan(
  CoRR = read.csv("T:/Labs/Spakowicz/projects/ppiio/data/raw/CoRR4684/2021-01-27/CoRR4684ARetrospecti_DATA_2021-01-27_1430.csv", 
                   stringsAsFactors = F),
  meds = read_excel("T:/Labs/Spakowicz/projects/throm/data/PLATELET_Variable_update.xlsx", sheet = 2, skip = 1),
  noio = readRDS("T:/Labs/Spakowicz/projects/ppiio/data/curated/NoImmunotherapy.RDS"),
  cancer.key = generate_cancer_key(),
  CoRR.form = quick_format_CoRR(CoRR, noio, cancer.key),

  # This could also be a csv defining the important relationships, of course
  class.key = as.data.frame(cbind(medname = c("PANTOPRAZOLE", "OMEPRAZOLE", "LANSOPRAZOLE", "DEXLANSOPRAZOLE", "RABEPRAZOLE", "ESOMEPRAZOLE", "prilosec", 
                                              "yosprala", "prevacid", "dexilent", "aciphex", "protonix", "nexium", "vimovo", "zegerid" ),
                                   medclass = c(rep("PPI", 15)))) %>%
    mutate(medname = as.character(medname),
           medclass = as.character(medclass)),
  
  start.ordering.offset = check_date_difference(meds),
  CoRR.timing = pull_timing_info(class.key, meds, start.ordering.offset["Median"], CoRR.form)
)
