## script needs file for country and country population.
library(tidyverse)
library(readxl)
library(httr)

# Downlod the data from UMD repository to data/UMD_updated/Full_Survey_Data/
# try(source("script-import-UMD-onlyfullcountry.R"), silent = F)
# try(source("script-import-UMD-onlyfullregion.R"), silent = F)

# Generate past_smooth columns for UMD data, in data/estimates-umd-unbatched/PlotData/
# NOTE: Takes several hours (past_smoothing is slow)
# try(source("UMD_country_past_smoothing_fromOriAll.R"), silent = F)



# Download data from the Oxford site
try(source("script-get-oxford-data.R"), silent = T)


# Download data from the UMD site using the API. Includes past smoothing
# NOTE: Takes several hours (past_smoothing is slow)
try(source("script-get-umd-data-country.R"), silent = T)

# Download the data about confirmed cases, deaths, hospital, icu, etc. and accumulate for weeks
try(source("script-confirmed2.R"), silent = T) # Downloads all country cases and deaths from ECDC
try(source("script-confirmed-hospital.R"), silent = T) # Downloads hospital and ICU occupancy from ECDC

# Compute CCFR estimates
try(source("script-ccfr-based3.R"), silent = T) # Generates CCFR estimates for all countries from Oxford data

# Compute estimates from the CoronaSurveys responses
try(source("script-W-v2.R"), silent = T)
try(source("script-W-past-smooth.R"), silent = T)  # Uses smooth_column-v2.R

# Merge data into giant CSV files per country
try(source("script-stitch-data-v2.R"), silent = T)



