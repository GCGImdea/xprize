library(dplyr)
library(stringr)
library(tidyverse)
library(lubridate)

ox_country_path <- "../data/oxford/country/" # Oxford data
ox_region_path <- "../data/oxford/region/"

output_file <- "../work/whole-forecast.csv"

start_date <- ymd("2020-01-01")
end_date <- ymd("2021-12-31")


process_country_region <- function(code, file_path) {
  
  cat("\n working on ", code, "\n")
  
  # Initialize with Oxford data
  df <- read.csv(paste0(file_path, code, "-estimate.csv"))
  df <- df %>%
    select(CountryName, RegionName, Date, 
           PredictedDailyNewCases = avgcases7days)
  df$Date <- as.Date(df$Date)
  df$RegionName[is.na(df$RegionName)] <- ""
  
  first_non_NA <- min(which(!is.na(df$PredictedDailyNewCases)))
  df$PredictedDailyNewCases[1:first_non_NA] <- 0
  df <- df[!is.na(df$PredictedDailyNewCases),]
  
  df <- df %>% 
    complete(Date = seq.Date(start_date, end_date, by="day")) %>% 
    fill(CountryName, RegionName, PredictedDailyNewCases)
  
  return(df)
}


df <- data.frame(CountryName=character(),
                 RegionName=character(),
                 Date=as.Date(character()),
                 PredictedDailyNewCases=double(),
                 stringsAsFactors=FALSE) 
  
#  data.frame(column.names = c("CountryName", "RegionName", "Date", "PredictedDailyNewCases"))
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
df$isSpecialty[df$CountryName == "Spain"] <- 1

df <- df[order(df$CountryName,df$RegionName,df$Date),]
write.csv(df,output_file, row.names = F)

#dd <- sapply(interest, load_and_combine_country, nsum = F)


