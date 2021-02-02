# load library
library(dplyr)
# library(ggplot2)
# library(httr)
# library(jsonlite)
# library(stringr)
# library(data.table)
library(lubridate)
library(tidyverse)

ratios_folder <- "./ips-ratios"
start_date <- ymd("2020-03-01")
end_date <- ymd("2021-02-28")
output_path <- "./ratios-per-date/"

step_lenght <- 7
duration <- 30

d <- start_date
while (d <= end_date) {
  first_file <- TRUE
  pat <- paste0(d, "-.*.csv")
  cat("Pattern: ", pat, "\n")
  ips_ratios <- list.files(path = ratios_folder, pattern = pat, full.names = TRUE)
  print(ips_ratios)
  for (f in ips_ratios) {
    cat("File: ", f, "\n")
    df <- read.csv(f, check.names = FALSE)
    df$Date <- as.Date(d)
    df$RegionName[is.na(df$RegionName)] <- ""
    if (first_file) {
      df_all <- df
      first_file <- FALSE
    }
    else {
      df_all <- bind_rows(df_all, df)
    }
  }
  if (!first_file) {
    df_all <- df_all[order(df_all$CountryName,df_all$RegionName,df_all$Date),]
    write.csv(df_all, paste0(output_path, d, "-ratios.csv"), row.names = F)
  }
  d <- d + step_lenght
}

stop()



df_all <- df_all %>% 
  complete(Date = seq.Date(start_date, end_date, by="day")) %>% 
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
       "H6_Facial Coverings",
       avg_ratio, sd_ratio, ratio15days)


  
  

stop()

