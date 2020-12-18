# load library
library(dplyr)
library(ggplot2)
library(httr)
library(jsonlite)
library(stringr)

DATA_URL = "https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv"
country_file <- "../data/common-data/oxford-countries.csv"
region_file <- "../data/common-data/oxford-regions.csv"
output_path = "../data/oxford/"
IPS_output_path = "../work/"

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
country_list <- read.csv(country_file)
all_countries <- country_list$CountryName

for (country in all_countries) {
  cat("Processing", country, "\n")
  df <- df_country[df_country$CountryName == country,]
  df$cases <- c(NA,diff(df$ConfirmedCases))
  df$deaths <- c(NA,diff(df$ConfirmedDeaths))
  geoid <- c_data[c_data$CountryName == country,"geo_id"]
  write.csv(df, paste0(output_path, "country/", geoid, "-estimate.csv"),
            row.names = FALSE)
}

# df_country <- df_country %>%
#   select(CountryName, CountryCode)  %>%
#   distinct()
# write.csv(df_country, file = "../data/common-data/country_oxford.csv",
#           row.names = FALSE)

df_region <- data_ox[data_ox$Jurisdiction == "STATE_TOTAL",]

region_list <- read.csv(region_file)
all_regions <- region_list$RegionName
for (region in all_regions) {
  cat("Processing", region, "\n")
  df <- df_region[df_region$RegionName == region,]
  # df <- df %>% mutate(Date = paste0( str_sub(Date, 1, 4), "-",
  #                                    str_sub(Date, 5, 6), "-",
  #                                    str_sub(Date, 7, 8))) %>% mutate(Date = as.Date(Date))
  df$cases <- c(NA,diff(df$ConfirmedCases))
  df$deaths <- c(NA,diff(df$ConfirmedDeaths))
  region_code <- df$RegionCode[1]
  write.csv(df, paste0(output_path, "region/", region_code, "-estimate.csv"),
            row.names = FALSE)
}

# df_region <- df_region %>%
#   select(RegionName, RegionCode)  %>%
#   distinct()
# write.csv(df_region, file = "../data/common-data/region_oxford.csv",
#           row.names = FALSE)

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

write.csv(data_ox, paste0(IPS_output_path, "IPS-latest.csv"),
          row.names = FALSE)

