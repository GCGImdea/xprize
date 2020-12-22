library(dplyr)
library(stringr)
library(tidyverse)
library(lubridate)

ox_country_path <- "../data/oxford/country/" # Oxford data
ox_region_path <- "../data/oxford/region/"

output_file <- "../work/whole-forecast.csv"
output_folder <- "../work/forecast/"

start_date <- ymd("2020-01-01")
end_date <- ymd("2021-12-31")

onset_to_death_window <- 13 # CDC web site
recent_period <-200


process_country_region <- function(code, file_path) {
  
  cat("\n working on ", code, "\n")
  
  # Initialize with Oxford data
  df <- read.csv(paste0(file_path, code, "-estimate.csv"))
  df <- df %>%
    select(CountryName, RegionName, Date, 
           PredictedDailyNewCases = avgcases7days,
           PredictedDailyNewDeaths = avgdeaths7days,
           avgcases7days_delta,
           avgdeaths7days_delta)
  df$Date <- as.Date(df$Date)
  df$RegionName[is.na(df$RegionName)] <- ""
  
  # Change leading NAs to 0
  first_non_NA <- min(which(!is.na(df$PredictedDailyNewCases)))
  df$PredictedDailyNewCases[1:first_non_NA] <- 0
  df$PredictedDailyNewDeaths[1:first_non_NA] <- 0
  
  #Remove trailing NAs
  df <- df[!is.na(df$PredictedDailyNewCases),]
  
  old_ll <- nrow(df)
  
  #Fill table until the end_date
  df <- df %>% 
    complete(Date = seq.Date(start_date, end_date, by="day")) %>% 
    fill(CountryName, RegionName, PredictedDailyNewCases, PredictedDailyNewDeaths)
  
  new_ll <- nrow(df)
  
  cat("len ", old_ll, "new len ", new_ll, "\n")
  
  # Change df$PredictedDailyNewCases
  top_cases <- max(df$PredictedDailyNewCases)
  stats_cases <- boxplot.stats(df$avgcases7days_delta[(old_ll - recent_period):(old_ll)])$stats
  
  cat("stats cases ", stats_cases, "\n")
  
  for (i in seq(1, new_ll-old_ll)) {
    df$PredictedDailyNewCases[old_ll+i] <- 
      min(top_cases, df$PredictedDailyNewCases[old_ll] + i*stats_cases[4])
  }
  
  # Change df$PredictedDailyNewCases
  top_deaths <- max(df$PredictedDailyNewDeaths)
  stats_deaths <- boxplot.stats(df$avgdeaths7days_delta[(old_ll - recent_period):(old_ll)])$stats
  
  cat("stats deaths ", stats_deaths, "\n")
  
  for (i in seq(1, new_ll-old_ll)) {
    df$PredictedDailyNewDeaths[old_ll+i] <- 
      min(top_deaths, df$PredictedDailyNewDeaths[old_ll] + i*stats_deaths[4])
  }
  
  IFR <- sum(df$PredictedDailyNewDeaths[(old_ll - recent_period):(old_ll)]) /
    sum(df$PredictedDailyNewCases[(old_ll - recent_period - onset_to_death_window):
                                         (old_ll - onset_to_death_window)])
    
  cat("IFR ", IFR, "\n")
  
  df$DeathsFromIFR <- df$PredictedDailyNewCases * IFR
  
  write.csv(df,paste0(output_folder, code, "-forecast.csv"), row.names = F)
  
  jpeg(paste0(output_folder, code, "-forecast-cases.jpg"))
  plot(df$Date, df$PredictedDailyNewCases, type="o", col="blue", pch="o", lty=1)
  # points(df$Date, df$PredictedDailyNewDeaths, col="red", pch="*")
  # lines(df$Date, df$PredictedDailyNewDeaths, col="red",lty=2)
  dev.off()
  
  jpeg(paste0(output_folder, code, "-forecast-deaths.jpg"))
  plot(df$Date, df$PredictedDailyNewDeaths, type="o", col="red", pch="o", lty=1)
  points(df$Date, df$DeathsFromIFR, col="blue", pch="*")
  lines(df$Date, df$DeathsFromIFR, col="blue",lty=2)
  dev.off()
  
  df <- df %>%
    select(CountryName, RegionName, Date, 
           PredictedDailyNewCases,
           PredictedDailyNewDeaths,
           DeathsFromIFR)
  
  
  return(df)
}


df <- data.frame(CountryName=character(),
                 RegionName=character(),
                 Date=as.Date(character()),
                 PredictedDailyNewCases=double(),
                 PredictedDailyNewDeaths=double(),
                 stringsAsFactors=FALSE) 

#save data for countries of interest

interest <- list.files(ox_country_path, pattern="*.csv", full.names=FALSE)
interest <- substring(interest, 1, 2)

for (c in interest) {
  df <- bind_rows(df, process_country_region(c, file_path=ox_country_path))
}

interest <- list.files(ox_region_path, pattern="*.csv", full.names=FALSE)
interest <- word(interest,1,sep = "-")

for (c in interest) {
  df <- bind_rows(df, process_country_region(c, file_path=ox_region_path))
}

df$isSpecialty <- 0
#df$isSpecialty[df$CountryName == "Spain"] <- 1

df <- df[order(df$CountryName,df$RegionName,df$Date),]
write.csv(df,output_file, row.names = F)


