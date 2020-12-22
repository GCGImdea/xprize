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
  
  IFR <- sum(df$PredictedDailyNewDeaths[(old_ll - recent_period):(old_ll)]) /
    sum(df$PredictedDailyNewCases[(old_ll - recent_period - onset_to_death_window):
                                    (old_ll - onset_to_death_window)])
  
  cat("IFR ", IFR, "\n")
  
  # Change df$PredictedDailyNewCases
  # if (IFR == 0) {
    top_cases <- max(df$PredictedDailyNewCases)
    stats_cases <- boxplot.stats(df$PredictedDailyNewCases[(old_ll - recent_period):(old_ll)])$stats
    
    cat("stats cases ", stats_cases, "\n")
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
    
    # for (i in seq(half_wave+1, new_ll-old_ll)) {
    #   df$PredictedDailyNewCases[old_ll+i] <- 
    #     min(top_cases, df$PredictedDailyNewCases[old_ll] + i*stats_cases[4])
    # }
  # }
  # else{
  #   set.seed(123)
  #   q <- seq(1:(old_ll - onset_to_death_window))
  #   y <- df$PredictedDailyNewDeaths[(onset_to_death_window+1):old_ll] / IFR 
  #   cat("q:", length(q), "\n")
  #   cat("y:", length(y), "\n")
  #   
  #   #model <- lm(y ~ poly(q,3))
  #   model <- lm(y ~ poly(q, 4, raw = TRUE))
  #   
  #   cat("f")
  #   
  #   summary(model)
  #   confint(model, level=0.95)
  #   
  #   new_df <- data.frame(r = seq((old_ll - onset_to_death_window + 1):new_ll))
  #   cat("d")
  #   predicted.intervals <- predict(model,new_df,interval='confidence',
  #                                  level=0.95)
  #   cat("f")
  #   df$PredictedDailyNewCases[(old_ll - onset_to_death_window + 1):new_ll] <- predicted.intervals[,1]
  # }
  
  
  
  
  
  # Change df$PredictedDailyNewDeaths
  # top_deaths <- max(df$PredictedDailyNewDeaths)
  # stats_deaths <- boxplot.stats(df$avgdeaths7days_delta[(old_ll - recent_period):(old_ll)])$stats
  # 
  # cat("stats deaths ", stats_deaths, "\n")
  # 
  # for (i in seq(1, new_ll-old_ll)) {
  #   df$PredictedDailyNewDeaths[old_ll+i] <- 
  #     min(top_deaths, df$PredictedDailyNewDeaths[old_ll] + i*stats_deaths[4])
  # }
  
  df$PredictedDailyNewDeaths[(old_ll+1):new_ll] <- 
    df$PredictedDailyNewCases[(old_ll+1-onset_to_death_window):(new_ll-onset_to_death_window)] * IFR
  
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

df_all$isSpecialty <- 0
#df$isSpecialty[df$CountryName == "Spain"] <- 1

df_all <- df_all[order(df_all$CountryName,df_all$RegionName,df_all$Date),]
write.csv(df_all,output_file, row.names = F)


