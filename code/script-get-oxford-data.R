# load library
library(dplyr)
library(ggplot2)
library(httr)
library(jsonlite)
library(stringr)
library(data.table)
# library(R0) # reproductive number

# # Function to compute R:
# errors_Rt_country <- c()
# errors_Rt_region <- c()
# var_to_Rt = "avgcases7days"
# # var_to_Rt = "cases"
# 
# do_Rt <- function(df, var_to_Rt = "cases", gamma_mean = 5.20, gamma_sd = 1.72) {
#   
#   # generation and serial interval distributions, taken from:
#   # https://www.eurosurveillance.org/content/10.2807/1560-7917.ES.2020.25.17.2000257
#   # Dataset	        Scenario	Interval	Estimate (95% credible interval) (days)
#   #                               Mean	                  SD
#   # Singapore	      Baseline	GI	5.20 (3.78 - 6.78)	  1.72 (0.91 - 3.93)
#   #                           SI	5.21 (???3.35 - 13.94)	4.32 (4.06 - 5.58)
#   # Tianjin (China)	Baseline	GI	3.95 (3.01 - 4.91)	  1.51 (0.74 - 2.97)
#   #                           SI	3.95 (???4.47 - 12.51)	4.24 (4.03 - 4.95)
#   
#   cat("-> computing Rt: using signal", var_to_Rt, "\n")
#   
#   # select the target to compute Rt
#   temp_for_R0 <- df[, var_to_Rt]
#   
#   # assign dates to rows
#   names(temp_for_R0) <- df$Date
#   
#   # first non-zero elements:
#   indx <- which(temp_for_R0 != 0)
#   temp_for_R0 <- temp_for_R0[indx[1L]:indx[length(indx)]]
#   
#   # generation time function
#   GT_covid <- generation.time("gamma", c(gamma_mean,gamma_sd))
#   
#   res_R <- estimate.R(temp_for_R0, 
#                       GT = GT_covid, 
#                       t = as.Date(names(temp_for_R0)),
#                       begin = (head(temp_for_R0, 1) %>%  names()), 
#                       end = (tail(temp_for_R0, 1) %>%  names()),
#                       pop.size = max(df$population),
#                       # methods = c("EG","ML","SB","TD"))
#                       methods = c("TD"))
#   
#   # save the results to a single data frame:
#   Rt_CI <- res_R[["estimates"]][["TD"]][["conf.int"]] %>% 
#     transmute(Rt = res_R[["estimates"]][["TD"]][["R"]],
#               Rt_lower = lower,
#               Rt_upper = upper,
#               Date = as.Date(rownames(res_R[["estimates"]][["TD"]][["conf.int"]])))
#   colnames(Rt_CI)[1:3] <- paste0(colnames(Rt_CI)[1:3], "_", var_to_Rt)
#   
#   df_out <- left_join(df, Rt_CI, by = "Date")
#   
#   return(df_out)
# }


DATA_URL = "https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv"
country_file <- "../data/common-data/oxford-countries.csv"
region_file <- "../data/common-data/oxford-regions-population.csv"
data_file <- "https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/common-data/oxford-umd-country-population.csv"
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

c_data <- read.csv(data_file)

df_country <- data_ox[data_ox$Jurisdiction == "NAT_TOTAL",]
country_list <- read.csv(country_file)
all_countries <- country_list$CountryName

for (country in all_countries) {
  cat("Processing", country, "\n")
  df <- df_country[df_country$CountryName == country,]

  
  df$cases <- c(0,diff(df$ConfirmedCases))
  df$deaths <- c(0,diff(df$ConfirmedDeaths))
  df$cases <- pmax(df$cases,0)
  df$deaths <- pmax(df$deaths,0)

  df$avgcases7days <- frollmean(df$cases, 7)
  df$avgdeaths7days <- frollmean(df$deaths, 7)
  
  df$cases_delta <- c(0,diff(df$cases))
  df$deaths_delta <- c(0,diff(df$deaths))
  df$avgcases7days_delta <- c(0,diff(df$avgcases7days))
  df$avgdeaths7days_delta <- c(0,diff(df$avgdeaths7days))
  
  
  geoid <- c_data[c_data$CountryName == country,"geo_id"]
  df$population <- c_data[c_data$CountryName == country,"population"]
  df$iso2 <- geoid
   
    # # Compute the Rt:
    # tryCatch(
    #   expr = {
    #     df <- do_Rt(df, var_to_Rt = var_to_Rt)
    #   },
    #   error = function(e){ 
    #     
    #     cat("Error while computing Rt for", 
    #         unique(country), "\n")
    #     errors_Rt_country <- c(errors_Rt_country, country)
    #     
    #   }
    # )
  
  
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
  
  df$cases <- c(0, diff(df$ConfirmedCases))
  df$deaths <- c(0, diff(df$ConfirmedDeaths))
  df$avgcases7days <- frollmean(df$cases, 7)
  df$avgdeaths7days <- frollmean(df$deaths, 7)
  
  df$cases_delta <- c(0,diff(df$cases))
  df$deaths_delta <- c(0,diff(df$deaths))
  df$avgcases7days_delta <- c(0,diff(df$avgcases7days))
  df$avgdeaths7days_delta <- c(0,diff(df$avgdeaths7days))
  
  region_code <- df$RegionCode[1]
  df$population <- region_list[region_list$RegionName == region,"Population"]
  df$iso2 <- region_code
  
  # # Compute the Rt:
  # tryCatch(
  #   expr = {
  #     df <- do_Rt(df, var_to_Rt = var_to_Rt)
  #   },
  #   error = function(e){ 
  #     
  #     cat("Error while computing Rt for", 
  #         unique(df$CountryName),  region, "\n")
  #     errors_Rt_region <- c(errors_Rt_region, region)
  #     
  #   }
  # )
  
  write.csv(df, paste0(output_path, "region/", region_code, "-estimate.csv"),
            row.names = FALSE)
}

# df_region <- df_region %>%
#   select(RegionName, RegionCode)  %>%
#   distinct()
# write.csv(df_region, file = "../data/common-data/region_oxford.csv",
#           row.names = FALSE)

#Generate IP file

# colnames(data_ox)<-str_replace_all(colnames(data_ox), c(" " = "."))

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

