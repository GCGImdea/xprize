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

data_ox <- data_ox %>% mutate(Date = paste0( str_sub(Date, 1, 4), "-",
                                   str_sub(Date, 5, 6), "-",
                                   str_sub(Date, 7, 8))) %>% mutate(Date = as.Date(Date))

write.csv(data_ox, paste0(output_path, "whole-data-latest.csv"),
          row.names = FALSE)

c_data <- read.csv("../data/common-data/oxford-umd-country-population.csv")

df_country <- data_ox[data_ox$Jurisdiction == "NAT_TOTAL",]
all_geo_ids <- unique(df_country$CountryCode)
for (country in all_geo_ids) {
  cat("Processing", country, "\n")
  df <- df_country[df_country$CountryCode == country,]
  geoid <- c_data[c_data$CountryCode == country,"geo_id"]
  write.csv(df, paste0(output_path, "country/", geoid, "-estimate.csv"),
            row.names = FALSE)
}

df_country <- df_country %>%
  select(CountryName, CountryCode)  %>%
  distinct()
write.csv(df_country, file = "../data/common-data/country_oxford.csv",
          row.names = FALSE)

df_region <- data_ox[data_ox$Jurisdiction == "STATE_TOTAL",]
all_geo_ids <- unique(df_region$RegionCode) 
for (region in all_geo_ids) {
  cat("Processing", region, "\n")
  df <- df_region[df_region$RegionCode == region,]
  # df <- df %>% mutate(Date = paste0( str_sub(Date, 1, 4), "-",
  #                                    str_sub(Date, 5, 6), "-",
  #                                    str_sub(Date, 7, 8))) %>% mutate(Date = as.Date(Date))
  write.csv(df, paste0(output_path, "region/", region, "-estimate.csv"),
            row.names = FALSE)
}

df_region <- df_region %>%
  select(RegionName, RegionCode)  %>%
  distinct()
write.csv(df_region, file = "../data/common-data/region_oxford.csv",
          row.names = FALSE)

#Generate IP file

colnames(data_ox)<-str_replace_all(colnames(data_ox), c(" " = "."))

data_ox <- data_ox %>%
  select(CountryName, RegionName, Date, C1_School.closing,	C2_Workplace.closing,
         C3_Cancel.public.events,	C4_Restrictions.on.gatherings, C5_Close.public.transport,
         C6_Stay.at.home.requirements,	C7_Restrictions.on.internal.movement,
         C8_International.travel.controls, H1_Public.information.campaigns,
         H2_Testing.policy,	H3_Contact.tracing, H6_Facial.Coverings)

colnames(data_ox)<- c("CountryName", "RegionName", "Date", "C1_School closing",	"C2_Workplace closing",
                      "C3_Cancel public events",	"C4_Restrictions on gatherings", "C5_Close public transport",
                      "C6_Stay at home requirements",	"C7_Restrictions on internal movement",
                      "C8_International travel controls", "H1_Public information campaigns",
                      "H2_Testing policy",	"H3_Contact tracing", "H6_Facial Coverings")

write.csv(data_ox, paste0(output_path, "IPS-latest.csv"),
          row.names = FALSE)

