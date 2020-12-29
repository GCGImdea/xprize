library(dplyr)
library(stringr)

ox_country_path <- "../data/oxford/country/" # Oxford data
owid_country_path <- "../data/owid/" # Our World in Data data
confirmed_country_path <- "../data/estimates-confirmed/" # Confirmed data from ECDC
ccfr_fatalities_path <- "../data/estimates-ccfr-fatalities/" # CCFR fatalities
ccfr_country_path <- "../data/estimates-ccfr-based/" # CCFR estimates
hospital_country_path <- "../data/estimates-confirmed-hospital/" # Hospital data from ECDC
W_country_path <- "../data/estimates-W/smooth/" # Estimates from the CoronaSurveys poll
umd_api_country_path <- "../data/estimates-umd-symptom-survey/" # Data from UMD Symptom Survey via API
umd_challenge_country_path <- "../data/estimates-umd-unbatched/PlotData/" # Data from UMD Symptom Survey via Challenge
google_mobility_path <- "../data/google-mobility/" # Date from Google mobility

output_path <- "../data/Aggregate/"

start_date <- "2020-01-01"

country_dataset <- function(code,
                            df_giant,
                            prefix = "conf_",
                            country_path = confirmed_country_path,
                            file_postfix = "-estimate.csv")
  {
  date_col <- paste0(prefix, "date")
  file_name <- paste0(country_path, code, file_postfix)
  if (file.exists(file_name)){
    cat("File", file_name, "exists!\n")
    df_aux <- read.csv(file_name)
    names(df_aux) <- tolower(names(df_aux))
    names(df_aux) <- paste0(prefix, names(df_aux))
    #df_aux$date <- as.Date(date_aux)
    df_aux$date <- as.Date(df_aux[,date_col])
    df_aux <- df_aux[!is.na(df_aux$date),]
    df_giant <- df_giant %>% full_join(df_aux, by = "date")
  }
  return(df_giant)
  }


load_and_combine_country <- function(code, nsum = FALSE) {
  
  cat("\n working on ", code, "\n")
  
  # Initialize with Oxford data
  df_giant <- read.csv(paste0(ox_country_path, code, "-estimate.csv"))
  names(df_giant) <- tolower(names(df_giant))
  df_giant$date <- as.Date(df_giant$date)
  
  df_giant <- country_dataset(code, df_giant, prefix = "owid_", country_path = owid_country_path,
                              file_postfix = "-estimate.csv")
  
  df_giant <- country_dataset(code, df_giant, prefix = "conf_", country_path = confirmed_country_path,
                  file_postfix = "-estimate.csv")
  
  df_giant <- country_dataset(code, df_giant, prefix = "ccfr_", country_path = ccfr_country_path,
                  file_postfix = "-estimate.csv")
  
  df_giant <- country_dataset(code, df_giant, prefix = "fatal_", country_path = ccfr_fatalities_path,
                              file_postfix = "-estimate.csv")
  
  df_giant <- country_dataset(code, df_giant, prefix = "hosp_", country_path = hospital_country_path,
                  file_postfix = "-hospital-icu.csv")
  
  # df_giant <- country_dataset(code, df_giant, prefix = "W_", country_path = W_country_path,
  #                 file_postfix = "-estimate-past-smooth.csv")

  df_giant <- country_dataset(code, df_giant, prefix = "W_", country_path = W_country_path,
                  file_postfix = "-estimate.csv")
  
  df_giant <- country_dataset(code, df_giant, prefix = "umdapi_", country_path = umd_api_country_path,
                  file_postfix = "-estimate.csv")
  
  df_giant <- country_dataset(code, df_giant, prefix = "umdchl_", country_path = umd_challenge_country_path,
                  file_postfix = "_UMD_country_nobatch_smooth.csv")
  
  df_giant <- country_dataset(code, df_giant, prefix = "gmob_", country_path = google_mobility_path,
                              file_postfix = "-estimate.csv")
  
  df_giant <- df_giant[df_giant$date >= start_date,]
  df_giant <- df_giant[order(df_giant$date),]
  out_path <- paste0(output_path, code, "-alldf.csv")
  write.csv(df_giant, out_path, row.names = FALSE)
  cat("[saved data]")
}

#save data for countries of interest

interest <- list.files(ox_country_path, pattern="*.csv", full.names=FALSE)
interest <- substring(interest, 1, 2)

dd <- sapply(interest, load_and_combine_country, nsum = F)


