# load library
library(dplyr)
library(ggplot2)
library(httr)
library(jsonlite)
library(stringr)
library(data.table)
library(lubridate)
library(tidyverse)
#library(reticulate) # To use Python
#library(R0) # reproductive number

# vectors_folder <- "./ips-vectors/"
vectors_folder <- "./ips-vectors-aux/"
ratios_folder <- "./ips-ratios/"
#start_date <- ymd("2020-03-01")
#end_date <- ymd("2021-02-28")
start_date <- ymd("2020-07-01")
end_date <- ymd("2020-07-18")
step_lenght <- 7
duration <- 30
pre_file <- "./IPS-latest-full.csv"


process_country_region <- function(df, dancedf, start_date, mid_date, duration) {
  country <- df$CountryName[1]
  region <- df$RegionName[1]
  cat("\n working on ", country, region, "\n")
  
  dfd <- dancedf[(dancedf$CountryName == country) & (dancedf$RegionName == region),]
  dfd <- dfd[(dfd$Date >= start_date) & (dfd$Date <= mid_date),]
  
  df$Date <- mid_date + 1
  end_date <- mid_date + duration
  df <- df %>% 
    complete(Date = seq.Date(mid_date + 1, end_date, by="day")) %>% 
    fill(CountryName, RegionName, 
         "C1_School closing", 
         "C2_Workplace closing",
         "C3_Cancel public events",
         "C4_Restrictions on gatherings",
         "C5_Close public transport",
         "C6_Stay at home requirements",
         "C7_Restrictions on internal movement",
         "C8_International travel controls",
         "H1_Public information campaigns",
         "H2_Testing policy",
         "H3_Contact tracing",
         "H6_Facial Coverings")
 
  cat("Lenght country region ", nrow(dfd), nrow(df), "\n")
  
  df <- bind_rows(dfd, df)
  
  cat("Lenght country region ", nrow(df), "\n")
  
  return(df)
}

generate_full_iplan <- function(start_date, mid_date, duration, 
                    pre_file, post_file, output_file) {
  dancedf <- read.csv(pre_file, check.names = FALSE)
  dancedf$Date <- as.Date(dancedf$Date)
  dancedf$RegionName[is.na(dancedf$RegionName)] <- ""
  
  df <- read.csv(post_file, check.names = FALSE)
  df$Date <- as.Date(df$Date)
  df$RegionName[is.na(df$RegionName)] <- ""
  
  n <- nrow(df)
  df2 <- process_country_region(as.data.frame(df[1,]), dancedf, start_date, mid_date, duration)
  if (n>1) {
    for (i in 2:n) {
      df2 <- bind_rows(df2, process_country_region(as.data.frame(df[i,]), dancedf, start_date, mid_date, duration))
    }
  }
  df2 <- df2[order(df2$CountryName,df2$RegionName,df2$Date),]
  write.csv(df2, output_file, row.names = F)
}


compute_ratios <- function(ds, de, ratio_file, prediction_file, file_path) {
  df <- read.csv(file_path, check.names = FALSE)
  print(paste("filepath",file_path))
  df$RegionName[is.na(df$RegionName)] <- ""
  df$avg_ratio <- 0
  
  dfp <- read.csv(prediction_file)
  
  n <- nrow(df)
  for (i in 1:n) {
    country <- df[i,"CountryName"]
    region <- df[i,"RegionName"]
    dfc <- dfp[(dfp$CountryName == country) & (dfp$RegionName == region),]
    
    dfc$avgcases7days <- frollmean(dfc$PredictedDailyNewCases, 7)
    dfc$avgcases7days_ratio <- dfc$avgcases7days/lag(dfc$avgcases7days,1)
    dfc$avgcases7days_ratio[is.na(dfc$avgcases7days_ratio)] <- 0
    
    n <- nrow(dfc)
    dfc$avg_ratio <- mean(dfc$avgcases7days_ratio[(n-duration+1):n])
    dfc$sd_ratio <- sd(dfc$avgcases7days_ratio[(n-duration+1):n])
    dfc$ratio15days <- dfc$avgcases7days[n] / dfc$avgcases7days[n-14]
    dfc$ratio15days[is.na(dfc$ratio15days)] <- 0
    
    print (nrow(df))
    print (nrow(dfc))
    df[i,"avg_ratio"] <- dfc$avg_ratio[1]
    df[i,"sd_ratio"] <- dfc$sd_ratio[1]
    df[i,"ratio15days"] <- dfc$ratio15days[1]
  }
  
  df <- df[order(df$CountryName,df$RegionName,df$Date),]
  write.csv(df, ratio_file, row.names = F)
}

generate_ratio_file <- function(d, duration, file_path, filen, ratio_file) {
  cat ("generating ", d, filen, ratio_file, "\n")
  full_iplan_file <- paste0("/tmp/", d, "-full-iplan-", filen)
  prediction_file <- paste0("/tmp/", d, "-predictions-", filen)
  
  generate_full_iplan(ymd("2020-01-01"), d, duration, pre_file, file_path, full_iplan_file)
  
  
  # call_string <- paste0("python3 standard_predictor/predict.py -s ", d, " -e ", d+duration,
  #                       " -ip ", full_iplan_file, " -o ", prediction_file)
  
  call_string <- paste("bash ./run-predict.sh ", d, d+duration, full_iplan_file, prediction_file)
  cat(call_string, "\n")
  
  system(call_string)
  
  compute_ratios(d, d+duration, ratio_file, prediction_file, file_path)
}
  
  
ips_vectors <- list.files(path = vectors_folder)

for (filen in ips_vectors) {
  file_path <- paste0(vectors_folder, filen)
  d <- start_date
  while (d <= end_date) {
    ratio_file <- paste0(ratios_folder, d, "-", filen)
    if (!file.exists(ratio_file)) {
      generate_ratio_file(d, duration, file_path, filen, ratio_file)
    }
    d <- d + step_lenght
  }
}

