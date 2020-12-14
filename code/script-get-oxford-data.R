# load library
library(dplyr)
library(ggplot2)
library(httr)
library(jsonlite)
library(stringr)

DATA_URL = "https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv"
output_path = "../data/oxford/"

data_ox <- read.csv(DATA_URL)
cat("::- script-confirmed: Oxford data available! ::\n")
jurisdictions <- unique(data_ox$Jurisdiction)
if (length(jurisdictions) != 2) {
  cat("Something wrong with jurisdictions", jurisdictions, "\n")
}

write.csv(data_ox, paste0(output_path, "whole-data-latest.csv"))

df_country <- data_ox[data_ox$Jurisdiction == "NAT_TOTAL",]
all_geo_ids <- unique(df_country$CountryCode)
for (country in all_geo_ids) {
  cat("Processing", country, "\n")
  df <- df_country[df_country$CountryCode == country,]
  df <- df %>% mutate(Date = paste0( str_sub(Date, 1, 4), "-",
                                     str_sub(Date, 5, 6), "-",
                                     str_sub(Date, 7, 8))) %>% mutate(Date = as.Date(Date))
  write.csv(df, paste0(output_path, "country/", country, "-estimate.csv"))
}

df_region <- data_ox[data_ox$Jurisdiction == "STATE_TOTAL",]
all_geo_ids <- unique(df_region$RegionCode) 
for (region in all_geo_ids) {
  cat("Processing", region, "\n")
  df <- df_region[df_region$RegionCode == region,]
  df <- df %>% mutate(Date = paste0( str_sub(Date, 1, 4), "-",
                                     str_sub(Date, 5, 6), "-",
                                     str_sub(Date, 7, 8))) %>% mutate(Date = as.Date(Date))
  write.csv(df, paste0(output_path, "region/", region, "-estimate.csv"))
}

  

