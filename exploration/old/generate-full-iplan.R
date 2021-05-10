library(dplyr)
library(stringr)
library(tidyverse)
library(lubridate)

# dance_plan <- "./dance_iplan.csv"
# 
# dance_file <- "./dance_full.csv"
# 
# start_date <- ymd("2020-11-01")
# mid_date <- ymd("2020-12-31")
# end_date <- ymd("2021-01-28")
# #end_date <- ymd("2020-01-03")

args <- commandArgs(trailingOnly = T)

cat("Arguments:", args, "\n")

# if (length(args) < 5) {
cat("usage: command start_date mid_date duration pre_file post_file output_file\n")
#   quit(save="no")
# }

start_date <- as.Date(args[1])
mid_date <- as.Date(args[2])
duration <- as.integer(args[3]) 
pre_file <- args[4]
post_file <- args[5]
output_file <- args[6]


process_country_region <- function(df, dancedf) {
  
  country <- df$CountryName[1]
  region <- df$RegionName[1]
  
  cat("\n working on ", country, region, "\n")
  
  dfd <- dancedf[(dancedf$CountryName == country) & (dancedf$RegionName == region),]
  dfd <- dfd[(dancedf$Date >= start_date) & (dancedf$Date <= mid_date),]

  df$Date <- mid_date + 1
  end_date <- mid_date + duration
  df <- df %>% 
    complete(Date = seq.Date(mid_date + 1, end_date, by="day")) %>% 
    fill(CountryName, RegionName, 
         "C1_School closing", 
         "C2_Workplace closing",
         "C3_Cancel public events",
         "C4_Restrictions on gatherings",
         "C5_Close public transport",
         "C6_Stay at home requirements",
         "C7_Restrictions on internal movement",
         "C8_International travel controls",
         "H1_Public information campaigns",
         "H2_Testing policy",
         "H3_Contact tracing",
         "H6_Facial Coverings")
  
  df <- bind_rows(dfd, df)
  
  return(df)
}

dancedf <- read.csv(pre_file, check.names = FALSE)
dancedf$Date <- as.Date(dancedf$Date)
dancedf$RegionName[is.na(dancedf$RegionName)] <- ""

cat("rows pre ", nrow(dancedf), "\n")

df <- read.csv(post_file, check.names = FALSE)
df$Date <- as.Date(df$Date)
df$RegionName[is.na(df$RegionName)] <- ""

cat("rows input ", nrow(df), "\n")

n <- nrow(df)

df2 <- process_country_region(as.data.frame(df[1,]), dancedf)

if (n>1) {
  for (i in 2:n) {
    df2 <- bind_rows(df2, process_country_region(as.data.frame(df[i,]), dancedf))
  }
}

df2 <- df2[order(df2$CountryName,df2$RegionName,df2$Date),]
write.csv(df2, output_file, row.names = F)
