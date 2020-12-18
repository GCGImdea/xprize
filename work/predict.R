# load library
# library(tidyverse)
# library(readxl)
# library(httr)

forecasting_file <- "whole-forecast.csv"
args <- commandArgs(trailingOnly = T)

cat("Arguments:", args, "\n")

start_date <- args[1]
end_date <- args[2]
path_to_ips_file <- args[3]
output_file_path <- args[4]

df <- read.csv(forecasting_file)
df$Date <- as.Date(df$Date)
df <- df[df$Date >= start_date,]
df <- df[df$Date <= end_date,]
write.csv(df, output_file_path, row.names = FALSE)

