# load library
library(dplyr)
library(ggplot2)
library(httr)
library(jsonlite)
library(stringr)
library(data.table)
library(lubridate)
library(R0) # reproductive number

# Parse the arguments
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("process_simulation input_file output_file",
       call. = FALSE)
}

input_file <- args[1]
output_file <- args[2]

dance_end_date <- ymd("2020-12-31")

# 
# DATA_URL = "https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv"
# country_file <- "../data/common-data/oxford-countries.csv"
# region_file <- "../data/common-data/oxford-regions-population.csv"
# data_file <- "https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/common-data/oxford-umd-country-population.csv"
# output_path = "../data/oxford/"
# IPS_output_path = "../work/"




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

df <- read.csv(input_file)
df$Date <- as.Date(df$Date)
df$RegionName[is.na(df$RegionName)] <- ""


all_countries <- unique(df[(df$RegionName == ""),"CountryName"])

first_iteration <- TRUE
for (country in all_countries) {
  cat("Processing", country, "\n")
  
  dfc <- df[(df$CountryName == country) & (df$RegionName == ""),]
  
  dfc$avgcases7days <- frollmean(dfc$PredictedDailyNewCases, 7)
  dfc$avgcases7days_ratio <- dfc$avgcases7days/lag(dfc$avgcases7days,1)

  #Coumputing the parameters of the ratio
  n <- nrow(dfc[(dfc$Date <= dance_end_date),])
  dfc$avg_dance_ratio <- mean(dfc$avgcases7days_ratio[(n-29):n])
  dfc$sd_dance_ratio <- sd(dfc$avgcases7days_ratio[(n-29):n])
  dfc$dance_ratio15days <- dfc$avgcases7days[n] / dfc$avgcases7days[n-14]
  
  n <- nrow(dfc)
  dfc$avg_ratio <- mean(dfc$avgcases7days_ratio[(n-29):n])
  dfc$sd_ratio <- sd(dfc$avgcases7days_ratio[(n-29):n])
  dfc$ratio15days <- dfc$avgcases7days[n] / dfc$avgcases7days[n-14]
  
  # Compute the Rt:
  # tryCatch(
  #   expr = {
  #     dfc <- do_Rt(dfc, var_to_Rt = var_to_Rt)
  #   },
  #   error = function(e){
  #     cat("Error while computing Rt for", 
  #         unique(country), "\n")
  #     errors_Rt_country <- c(errors_Rt_country, country)
  #   }
  # )
  
  if (first_iteration) {
    df_all <- dfc
    first_iteration <- FALSE
  }
  else {
    df_all <- bind_rows(df_all, dfc)
  }
}

all_regions <- unique(df$RegionName)
all_regions <- all_regions[all_regions != ""]
for (region in all_regions) {
  cat("Processing", region, "\n")
  
  dfc <- df[(df$RegionName == region),]
  
  dfc$avgcases7days <- frollmean(dfc$PredictedDailyNewCases, 7)
  dfc$avgcases7days_ratio <- dfc$avgcases7days/lag(dfc$avgcases7days,1)

  #Coumputing the parameters of the ratio
  n <- nrow(dfc[(dfc$Date <= dance_end_date),])
  dfc$avg_dance_ratio <- mean(dfc$avgcases7days_ratio[(n-29):n])
  dfc$sd_dance_ratio <- sd(dfc$avgcases7days_ratio[(n-29):n])
  dfc$dance_ratio15days <- dfc$avgcases7days[n] / dfc$avgcases7days[n-14]
  
  n <- nrow(dfc)
  dfc$avg_ratio <- mean(dfc$avgcases7days_ratio[(n-29):n])
  dfc$sd_ratio <- sd(dfc$avgcases7days_ratio[(n-29):n])
  dfc$ratio15days <- dfc$avgcases7days[n] / dfc$avgcases7days[n-14]
  
    # Compute the Rt:
  # tryCatch(
  #   expr = {
  #     dfc <- do_Rt(dfc, var_to_Rt = var_to_Rt)
  #   },
  #   error = function(e){
  #     cat("Error while computing Rt for", 
  #         unique(dfc$CountryName),  region, "\n")
  #     errors_Rt_region <- c(errors_Rt_region, region)
  #   }
  # )
  
  df_all <- bind_rows(df_all, dfc)
}

df_all <- df_all[order(df_all$CountryName,df_all$RegionName,df_all$Date),]
write.csv(df_all, output_file, row.names = F)
