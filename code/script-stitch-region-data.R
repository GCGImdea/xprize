library(dplyr)
library(stringr)

ox_region_path <- "../data/oxford/region/" # Oxford data
confirmed_region_path <- "../data/estimates-confirmed/" # Confirmed data from ECDC
ccfr_fatalities_path <- "../data/estimates-ccfr-fatalities/" # CCFR fatalities
ccfr_region_path <- "../data/estimates-ccfr-based/" # CCFR estimates
hospital_region_path <- "../data/estimates-confirmed-hospital/" # Hospital data from ECDC
W_region_path <- "../data/estimates-W/smooth/" # Estimates from the CoronaSurveys poll
umd_api_region_path <- "../data/estimates-umd-symptom-survey/" # Data from UMD Symptom Survey via API
umd_challenge_region_path <- "../data/estimates-umd-unbatched/PlotData/" # Data from UMD Symptom Survey via Challenge
cmu_region_path <- "../data/CMU-covidcast/" # Data on US states from CMU Symptom Survey via Covidcast API
google_mobility_path <- "../data/google-mobility/" # Date from Google mobility

output_path <- "../data/Aggregate/"

start_date <- "2020-01-01"

region_dataset <- function(code,
                            df_giant,
                            prefix = "conf_",
                            region_path = confirmed_region_path,
                            file_postfix = "-estimate.csv")
  {
  date_col <- paste0(prefix, "date")
  file_name <- paste0(region_path, code, file_postfix)
  if (file.exists(file_name)){
    cat("File", file_name, "exists!\n")
    df_aux <- read.csv(file_name)
    names(df_aux) <- tolower(names(df_aux))
    names(df_aux) <- paste0(prefix, names(df_aux))
    #df_aux$date <- as.Date(df_aux$conf_date)
    df_aux$date <- as.Date(df_aux[,date_col])
    df_aux <- df_aux[!is.na(df_aux$date),]
    df_giant <- df_giant %>% full_join(df_aux, by = "date")
  }
  return(df_giant)
  }


load_and_combine_region <- function(code, nsum = FALSE) {
  
  cat("\n working on ", code, "\n")
  
  # Initialize with Oxford data
  df_giant <- read.csv(paste0(ox_region_path, code, "-estimate.csv"))
  names(df_giant) <- tolower(names(df_giant))
  df_giant$date <- as.Date(df_giant$date)
  
  df_giant <- region_dataset(code, df_giant, prefix = "conf_", region_path = confirmed_region_path,
                  file_postfix = "-estimate.csv")
  
  df_giant <- region_dataset(code, df_giant, prefix = "ccfr_", region_path = ccfr_region_path,
                  file_postfix = "-estimate.csv")

  df_giant <- region_dataset(code, df_giant, prefix = "fatal_", region_path = ccfr_fatalities_path,
                              file_postfix = "-estimate.csv")
  
  # df_giant <- region_dataset(code, df_giant, prefix = "hosp_", region_path = hospital_region_path,
  #                 file_postfix = "-hospital-icu.csv")

  # df_giant <- region_dataset(code, df_giant, prefix = "W_", region_path = W_region_path,
  #                 file_postfix = "-estimate-past-smooth.csv")

  df_giant <- region_dataset(code, df_giant, prefix = "W_", region_path = W_region_path,
                 file_postfix = "-estimate.csv")
  
  # df_giant <- region_dataset(code, df_giant, prefix = "umdapi_", region_path = umd_api_region_path,
  #                 file_postfix = "-estimate.csv")
  # 
  # df_giant <- region_dataset(code, df_giant, prefix = "umdchl_", region_path = umd_challenge_region_path,
  #                 file_postfix = "_UMD_region_nobatch_past_smooth.csv")
  
  df_giant <- region_dataset(code, df_giant, prefix = "cmu_", region_path = cmu_region_path,
                  file_postfix = "-estimate.csv")

  df_giant <- region_dataset(code, df_giant, prefix = "gmob_", region_path = google_mobility_path,
                              file_postfix = "-estimate.csv")
  
  df_giant <- df_giant[df_giant$date >= start_date,]
  df_giant <- df_giant[order(df_giant$date),]
  out_path <- paste0(output_path, code, "-alldf.csv")
  write.csv(df_giant, out_path, row.names = FALSE)
  cat("[saved data]")
}

#save data for regions of interest

interest <- list.files(ox_region_path, pattern="*.csv", full.names=FALSE)
interest <- word(interest,1,sep = "-")
#interest <- substring(interest, 1, 5)

dd <- sapply(interest, load_and_combine_region, nsum = F)


