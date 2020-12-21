# load library
library(dplyr)
library(ggplot2)
library(httr)
library(jsonlite)
library(stringr)
library(data.table)

DATA_URL = "https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv"
#DATA_URL = "/Users/anto/Downloads/Global_Mobility_Report.csv"
output_path = "../data/google-mobility/"

df_country <- read.csv(DATA_URL)
cat("::- script-confirmed: Google Mobility data is available! ::\n")
df_country <- df_country[!is.na(df_country$country_region_code),] # There are rows with (country_region_code = NA)

all_countries <- unique(df_country$country_region_code)
all_countries <- all_countries[!is.na(all_countries)]

for (country in all_countries) {
  cat("Processing", country)
  df <- df_country[df_country$country_region_code == country,]
  df <- df[df$sub_region_1 == "",]
  df <- df[df$sub_region_2 == "",]
  df <- df[df$metro_area == "",]
  df <- df[df$iso_3166_2_code == "",]
  cat(" rows: ", nrow(df), "\n")
  write.csv(df, paste0(output_path, country, "-estimate.csv"),
            row.names = FALSE)
}

df_country$iso_3166_2_code <- gsub("-", "_", df_country$iso_3166_2_code)
all_regions <- unique(df_country$iso_3166_2_code)
all_regions <- all_regions[all_regions != ""]
all_regions <- all_regions[!is.na(all_regions)]

for (region in all_regions) {
  cat("Processing", region)
  df <- df_country[df_country$iso_3166_2_code == region,]
  cat(" rows: ", nrow(df), "\n")
  write.csv(df, paste0(output_path, region, "-estimate.csv"),
            row.names = FALSE)
}




