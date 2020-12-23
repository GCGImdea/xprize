library(dplyr)
library(stringr)
library(tidyverse)
library(lubridate)
library(data.table)
library(caret)
library(readr)
library(ggplot2)
library(forecast)
library(fpp2)
library(TTR)

ox_country_path <- "../data/oxford/country/" # Oxford data
ox_region_path <- "../data/oxford/region/"

fore_path <- "../data/estimates-symptom-lags/estimates/"

output_file <- "../work/whole-forecast.csv"
output_folder <- "../work/forecast/"

start_date <- ymd("2020-01-01")
end_date <- ymd("2021-12-31")

onset_to_death_window <- 13 # CDC web site
onset_to_hospital <- 6 # CDC web site
cases_in_hospital <- 0.25 # Augusto's study in our draft
hospital_in_icu <- 0.30 # CDC web site <50: 23.8%, 50-64: 36.1%, >64: 35.3%
recent_period <-100


process_country_region <- function(code, file_path) {
  
  cat("\n working on ", code, "\n")
  
  # Initialize with Oxford data
  df <- read.csv(paste0(file_path, code, "-estimate.csv"))
  df <- df %>%
    select(CountryName, RegionName, Date, 
           cases,
           PredictedDailyNewCases = avgcases7days,
           PredictedDailyNewDeaths = avgdeaths7days,
           avgcases7days_delta,
           avgdeaths7days_delta)
  df$Date <- as.Date(df$Date)
  df$RegionName[is.na(df$RegionName)] <- ""
  df$isSpecialty <- 0
  
  # Change leading NAs to 0
  first_non_NA <- min(which(!is.na(df$PredictedDailyNewCases)))
  df$PredictedDailyNewCases[1:first_non_NA] <- 0
  df$PredictedDailyNewDeaths[1:first_non_NA] <- 0
  
  #Remove trailing NAs
  df <- df[!is.na(df$PredictedDailyNewCases),]
  
  old_ll <- nrow(df)
  
  # Compute Infection-fatality rate with latest numbers
  IFR <- sum(df$PredictedDailyNewDeaths[(old_ll - recent_period):(old_ll)]) /
    sum(df$PredictedDailyNewCases[(old_ll - recent_period - onset_to_death_window):
                                    (old_ll - onset_to_death_window)])
  cat("IFR ", IFR, "\n")
  
  #Fill table until the end_date
  df <- df %>% 
    complete(Date = seq.Date(start_date, end_date, by="day")) %>% 
    fill(CountryName, RegionName, cases, PredictedDailyNewCases, isSpecialty, PredictedDailyNewDeaths)
  
  new_ll <- nrow(df)
  
  cat("len ", old_ll, "new len ", new_ll, "\n")
  
  # Change df$PredictedDailyNewCases
  top_cases <- max(df$PredictedDailyNewCases)
  stats_cases <- boxplot.stats(df$PredictedDailyNewCases[(old_ll - recent_period):(old_ll)])$stats
  cat("stats cases ", stats_cases, "\n")
  
  file_name <- paste0(fore_path, code, "-estimates.csv")
  if (file.exists(file_name)){
    cat("Forecast file exists!\n")
    df_fore <- read.csv(file_name)
    # df_fore <- df_fore %>%
    #   select (date, estimate)
    df_fore$Date <- as.Date(df_fore$date)
    #max_date <- max(df_fore$Date)
    df <- df %>% full_join(df_fore, by = "Date")
    df$estimate[1:old_ll] <- df$cases[1:old_ll]
    #df$estimate[df$Date > max_date] <- stats_cases[3]
    df$estimate[is.na(df$estimate)]  <- stats_cases[3]
    df$PredictedDailyNewCases <- frollmean(df$estimate, 7, fill = 0)
    df$isSpecialty <- 1
  }
  else {
    half_wave <- 40
    x_step <- 1/half_wave
    y_gap <- top_cases - df$PredictedDailyNewCases[old_ll]
    for (i in seq(1, half_wave)) {
      df$PredictedDailyNewCases[old_ll+i] <- df$PredictedDailyNewCases[old_ll] +
        ((i*x_step)^2 / 2 + i*x_step / 2) * y_gap
    }
    
    y_gap <- top_cases - stats_cases[3]
    for (i in seq(1, half_wave)) {
      df$PredictedDailyNewCases[old_ll + half_wave + i] <- df$PredictedDailyNewCases[old_ll + half_wave] -
        ( ((i*x_step)^2 / 2 + i*x_step/2) * y_gap )
    }
    
    df$PredictedDailyNewCases[(old_ll +2*half_wave+1):new_ll] <- stats_cases[3]
    
  }
  
  # Change df$PredictedDailyNewDeaths
  df$PredictedDailyNewDeaths[(old_ll+1):new_ll] <- 
    df$PredictedDailyNewCases[(old_ll+1-onset_to_death_window):(new_ll-onset_to_death_window)] * IFR
  df$PredictedDailyNewDeaths[is.na(df$PredictedDailyNewDeaths)] <- 0
  
  # Hospital cases
  df$PredictedDailyNewHospital <- shift(df$PredictedDailyNewCases * cases_in_hospital, 
                                        n = onset_to_hospital, 
                                        fill = 0)
  
  df$PredictedDailyNewICU <- df$PredictedDailyNewHospital * hospital_in_icu
    
  write.csv(df,paste0(output_folder, code, "-forecast.csv"), row.names = F)
  
  jpeg(paste0(output_folder, code, "-forecast-cases.jpg"))
  plot(df$Date, df$PredictedDailyNewCases, type="o", col="blue", pch="o", lty=1)
  # points(df$Date, df$PredictedDailyNewDeaths, col="red", pch="*")
  # lines(df$Date, df$PredictedDailyNewDeaths, col="red",lty=2)
  dev.off()
  
  jpeg(paste0(output_folder, code, "-forecast-deaths.jpg"))
  plot(df$Date, df$PredictedDailyNewDeaths, type="o", col="red", pch="o", lty=1)
  # points(df$Date, df$DeathsFromIFR, col="blue", pch="*")
  # lines(df$Date, df$DeathsFromIFR, col="blue",lty=2)
  dev.off()
  
  jpeg(paste0(output_folder, code, "-forecast-hosp.jpg"))
  plot(df$Date, df$PredictedDailyNewHospital, type="o", col="red", pch="o", lty=1)
  points(df$Date, df$PredictedDailyNewICU, col="blue", pch="*")
  lines(df$Date, df$PredictedDailyNewICU, col="blue",lty=2)
  dev.off()
  
  df <- df %>%
    select(CountryName, RegionName, Date, 
           PredictedDailyNewCases,
           isSpecialty,
           PredictedDailyNewDeaths,
           #DeathsFromIFR,
           PredictedDailyNewHospital,
           PredictedDailyNewICU
           )
  
  
  return(df)
}




# df_all <- data.frame(CountryName=character(),
#                  RegionName=character(),
#                  Date=as.Date(character()),
#                  PredictedDailyNewCases=double(),
#                  PredictedDailyNewDeaths=double(),
#                  stringsAsFactors=FALSE) 

df_all <- data.frame()

#save data for countries of interest

interest <- list.files(ox_country_path, pattern="*.csv", full.names=FALSE)
interest <- substring(interest, 1, 2)

for (c in interest) {
  df_all <- bind_rows(df_all, process_country_region(c, file_path=ox_country_path))
}

interest <- list.files(ox_region_path, pattern="*.csv", full.names=FALSE)
interest <- word(interest,1,sep = "-")

for (c in interest) {
  df_all <- bind_rows(df_all, process_country_region(c, file_path=ox_region_path))
}

df_all <- df_all[order(df_all$CountryName,df_all$RegionName,df_all$Date),]
write.csv(df_all,output_file, row.names = F)


