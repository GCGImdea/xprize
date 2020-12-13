# Script to prepare the data
library(tidyverse)
library(readxl)
library(httr)

# Download daat from the Oxford site
try(source("script-get-oxford-data.R"), silent = T)
