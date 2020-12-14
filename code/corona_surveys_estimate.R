# Script to prepare the data
library(tidyverse)
library(readxl)
library(httr)

# Download data from the Oxford site
try(source("script-get-oxford-data.R"), silent = T)

# Download data from the UMD site
try(source("script-get-umd-data-country.R"), silent = T)
