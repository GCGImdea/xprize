# load library
library(tidyverse)
# library(readxl)
# library(httr)

hammer_file <- "./hammer_full.csv"
dance_file <- "./dance_full.csv"
hammer_length <- 30 # days

args <- commandArgs(trailingOnly = T)

cat("Arguments:", args, "\n")

start_date <- as.Date(args[1])
end_date <- as.Date(args[2])
path_to_ips_file <- args[3]
path_to_cost_file <- args[4]
output_file_path <- args[5]

change_date <- min(start_date + hammer_length, end_date)

df <- read.csv(hammer_file)
df$Date <- as.Date(df$Date)
df <- df[df$Date >= start_date,]
df <- df[df$Date <= change_date,]

dfd <- read.csv(dance_file)
dfd$Date <- as.Date(dfd$Date)
dfd <- dfd[dfd$Date > change_date,]
dfd <- dfd[dfd$Date <= end_date,]

df <- bind_rows(df, dfd)

df <- df[order(df$CountryName,df$RegionName,df$Date),]
write.csv(df, output_file_path, row.names = FALSE)
