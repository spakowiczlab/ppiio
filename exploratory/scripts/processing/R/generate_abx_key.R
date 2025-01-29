generate_abx_key <- function(){
  abxkey <- as.data.frame(cbind(medname = c("penicillin", "Amoxicillin", "Ampicillin", "Piperacillin", "Cefalexin", 
                                            "Cephalexin", "Ceftriaxone", "Ceftazidime", "Cefepime", "Aztreonam", "Imipenem",
                                            "Ciprofloxacin", "levofloxacin", "Moxifloxacin",
                                            "Azithromycin", "Clarithromycin", "Erythromycin",
                                            "Doxycycline", "Tetracycline", "Minocycline",
                                            "Linezolid", "Daptomycin",
                                            "Acyclovir", "Ganciclovir", "Valacyclovir", "Valaciclovir", "Valganciclovir", 
                                            "Foscarnet", "Oseltamivir",
                                            "Fluconazole", "Voriconazole", "Posaconazole", "Caspofungin", "Micafungin",
                                            "Vancomycin", "Sulfamethoxazole","Clindamycin","Metronidazole"),
                                medclass = "ABX"),
                          stringsAsFactors = F)
  return(abxkey)
}
