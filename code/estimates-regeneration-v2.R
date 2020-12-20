## script needs file for country and country population.
library(tidyverse)
library(readxl)
library(httr)

# Uncomment these if there is new UMD data available:
# 1.- Downlod the data from UMD repository to data/UMD_updated/Full_Survey_Data/
# try(source("script-import-UMD-onlyfullcountry.R"), silent = F)
# try(source("script-import-UMD-onlyfullregion.R"), silent = F)
# 2.-Generate smooth columns for UMD data, in data/estimates-umd-unbatched/PlotData/
#try(source("UMD_country_smoothing_fromOriAll.R"), silent = F)




# Download data from the Oxford site
try(source("script-get-oxford-data.R"), silent = T)

# Download data from the Our World in Data site
try(source("script-get-owid-data.R"), silent = T)

# Download data from the UMD site using the API. Includes smoothing (not past smoothing, too slow)
try(source("script-get-umd-data-country.R"), silent = T)

# Download the data about confirmed cases, deaths, hospital, icu, etc. and accumulate for weeks
try(source("script-confirmed2.R"), silent = T) # Downloads all country cases and deaths from ECDC
try(source("script-confirmed-hospital.R"), silent = T) # Downloads hospital and ICU occupancy from ECDC

# Compute CCFR estimates
try(source("script-ccfr-based3.R"), silent = T) # Generates CCFR estimates for all countries from Oxford data
try(source("script-ccfr-based-region.R"), silent = T) # Generates CCFR estimates for all countries from Oxford data

# Compute estimates from the CoronaSurveys responses
try(source("script-W-v2.R"), silent = T)
#try(source("script-W-past-smooth.R"), silent = T)  # Uses smooth_column-v2.R
try(source("script-W-smooth.R"), silent = T)  # Uses smooth_column-v2.R

# Download data from the CMU Covidcast site: US states data
try(source("script-get-CMU-covidcast-data2.R"), silent = T)

# Merge data into giant CSV files per country and region
try(source("script-stitch-country-data.R"), silent = T)
try(source("script-stitch-region-data.R"), silent = T)


